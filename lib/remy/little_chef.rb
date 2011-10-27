module Remy
  class LittleChef
    # For chef-solo info, see: http://wiki.opscode.com/display/chef/Chef+Solo
    include ::Remy::Shell
    include FileUtils

    def initialize(options)
      options = JSON.parse(options).symbolize_keys! if options.is_a?(String)
      @remote_chef_ip = options[:remote_chef_ip]
      @chef_args = options.delete(:chef_args)
      @quiet = options.delete(:quiet)
      @configuration = Mash.new(Remy.configuration.to_hash.deep_merge(options))
      server_name, server_config = @configuration.servers.detect {|(server_name, server_config)| server_config.remote_chef_ip == remote_chef_ip}
      configuration.merge!(server_config)
    end

    def run
      create_temp_dir_which_contains_cookbooks_roles_and_scripts
      rsync_temp_dir_with_cookbooks_to_remote_host
      run_chef_solo_on_remote_host
    end

    def configuration
      @configuration
    end

    private

    def create_temp_dir_which_contains_cookbooks_roles_and_scripts
      create_temp_dir
      copy_spec_cookbook_and_role_dirs_to_tmp_dir
      create_solo_rb
      create_bash_script_which_runs_chef
      create_node_json_from_configuration
    end

    # Fix this later
    def public_ip
      remote_chef_ip
    end

    def rsync_temp_dir_with_cookbooks_to_remote_host
      remote_execute "mkdir -p #{remote_chef_dir}"
      olddir = pwd
      begin
        chdir(tmp_dir)
        `rsync -av * #{user}@#{remote_chef_ip}:#{remote_chef_dir}`
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

    def copy_spec_cookbook_and_role_dirs_to_tmp_dir
      [Remy.configuration.roles_path, Remy.configuration.cookbook_path, Remy.configuration.spec_path].each do |path|
        full_path = path.map{|p| File.expand_path(p) }
        full_path.each do |a_path|
          cp_r a_path, tmp_dir
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
        f.write(solo_rb_contents)
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
        f.write(run_chef)
      end
      chmod(0755, File.join(tmp_dir, run_chef_solo_bash_script))
    end

    def create_node_json_from_configuration
      File.open(File.join(tmp_dir, node_json), 'w+') do |f|
        f.write(configuration.to_json)
      end
    end

    def remote_chef_ip
      @remote_chef_ip
    end

    def node_json
      'node.json'
    end

    def solo_rb
      'solo.rb'
    end

    def remote_chef_dir
      Remy.configuration.remote_chef_dir
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
