module Remy
  class Chef
    # For chef-solo info, see: http://wiki.opscode.com/display/chef/Chef+Solo
    include ::Remy::Shell
    include FileUtils
    attr_reader :ip_address

    def initialize(options = {})
      options = JSON.parse(options).symbolize_keys! if options.is_a?(String)
      @chef_args = options.delete(:chef_args)
      @quiet = options.delete(:quiet)
      @node_configuration = Remy.configuration.dup
      @ip_address = options[:ip_address] ? options[:ip_address] : @node_configuration.ip_address
      server_config = Remy.find_server_config(:ip_address => ip_address) || Mash.new
      @node_configuration.deep_merge!(server_config)
      @node_configuration.merge!(options)
    end

    def run
      create_temp_dir_which_contains_cookbooks_roles_and_scripts
      rsync_temp_dir_with_cookbooks_to_remote_host
      run_chef_solo_on_remote_host
    end

    def self.rake_run(rake_options)
      chef_options_for_each_server = Remy.convert_rake_args_to_chef_options(rake_options)
      chef_options_for_each_server.each do |chef_options|
        Remy::Chef.new(chef_options).run
      end
    end

    private

    def create_temp_dir_which_contains_cookbooks_roles_and_scripts
      create_temp_dir
      copy_spec_cookbook_and_role_dirs_to_tmp_dir
      create_solo_rb
      create_bash_script_which_runs_chef
      create_node_json_from_node_configuration
    end

    def rsync_temp_dir_with_cookbooks_to_remote_host
      remote_execute "mkdir -p #{remote_chef_dir}"
      olddir = pwd
      begin
        chdir(tmp_dir)
        execute "rsync -a #{rsync_delete_flag} * #{user}@#{ip_address}:#{remote_chef_dir}"
      ensure
        chdir(olddir)
      end
    end

    def run_chef_solo_on_remote_host
      remote_execute "bash --login -c #{remote_chef_dir}/#{run_chef_solo_bash_script}"
    end

    def create_temp_dir
      @tmpdir = Dir.mktmpdir
    end

    def rsync_delete_flag
      if remote_execute("test -e #{remote_chef_dir}")
        chef_dir_contains_valid_chef_content = remote_execute("test -e #{remote_chef_dir}/#{node_json} && test -e #{remote_chef_dir}/#{solo_rb}")
        chef_dir_contains_valid_chef_content ? '--delete' : nil
      end
    end

    def copy_spec_cookbook_and_role_dirs_to_tmp_dir
      [@node_configuration.roles_path, @node_configuration.cookbook_path, @node_configuration.spec_path].each do |path|
        if path
          full_path = path.map{|p| File.expand_path(p) }
          full_path.each do |a_path|
            cp_r a_path, tmp_dir
          end
        end
      end
    end

    def create_solo_rb
      solo_rb_contents = <<-EOF
file_cache_path "#{remote_chef_dir}"
cookbook_path ["#{remote_chef_dir}/cookbooks"]
role_path "#{remote_chef_dir}/roles"
cache_options({ :path => "#{remote_chef_dir}/cache/checksums", :skip_expires => true })
EOF
      File.open(File.join(tmp_dir, solo_rb), 'w+') do |f|
        f << solo_rb_contents
      end
    end

    def create_bash_script_which_runs_chef
      run_chef = <<-EOF
#!/bin/bash
# Pass "-l debug" to this script to get more debug output

# $@ gets the array of args from Bash
chef-solo $@ #{@chef_args} -j #{remote_chef_dir}/#{node_json} -c #{remote_chef_dir}/#{solo_rb}
EOF
      File.open(File.join(tmp_dir, run_chef_solo_bash_script), 'w+') do |f|
        f << run_chef
      end
      chmod(0755, File.join(tmp_dir, run_chef_solo_bash_script))
    end

    def create_node_json_from_node_configuration
      File.open(File.join(tmp_dir, node_json), 'w+') do |f|
        f << @node_configuration.to_json
      end
    end

    def node_json
      'node.json'
    end

    def solo_rb
      'solo.rb'
    end

    def remote_chef_dir
      @node_configuration.remote_chef_dir
    end

    def tmp_dir
      File.expand_path(@tmpdir)
    end

    def run_chef_solo_bash_script
      'run_chef_solo'
    end

    def quiet?
      @quiet
    end
  end
end
