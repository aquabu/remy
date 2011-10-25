module Remy
  class LittleChef
    include ::Remy::Shell
    include FileUtils

    def initialize(options)
      options = JSON.parse(options).symbolize_keys! if options.is_a?(String)
      @public_ip = options[:public_ip]
      @configuration = Remy.configuration.dup
      @configuration.deep_merge!(options)
    end

    def run
      create_temp_dir_which_contains_cookbooks_and_scripts
      rsync_temp_dir_with_cookbooks_to_remote_host
      run_chef_solo_on_remote_host
    end

    def configuration
      @configuration
    end

    private

    def create_temp_dir_which_contains_cookbooks_and_scripts
      create_temp_dir_and_copy_cookbook_dirs
      create_solo_rb
      create_bash_script_which_runs_chef
      create_node_json_from_remy_config
    end

    def rsync_temp_dir_with_cookbooks_to_remote_host
      remote_execute "mkdir -p #{remote_chef_dir}"
      olddir = pwd
      begin
        chdir(tmp_dir)
        `rsync -av * #{user}@#{public_ip}:#{remote_chef_dir}`
      ensure
        chdir(olddir)
      end
    end

    def run_chef_solo_on_remote_host
      `ssh -t #{user}@#{public_ip} bash --login -c '#{remote_chef_dir}/#{run_chef_solo_bash_script}'`
    end

    def create_temp_dir_and_copy_cookbook_dirs
      full_cookbook_path = Remy.configuration.cookbook_path.map{|p| File.expand_path(p) }
      @tmpdir = Dir.mktmpdir
      full_cookbook_path.each do |cookbook_path|
        cp_r cookbook_path, tmp_dir
      end
    end

    def create_solo_rb
      solo_rb_contents = <<-EOF
file_cache_path "#{remote_chef_dir}"
cookbook_path ["#{remote_chef_dir}/cookbooks"]
cache_options({ :path => "#{remote_chef_dir}/cache/checksums", :skip_expires => true })
EOF
      File.open(File.join(tmp_dir, solo_rb), 'w+') do |f|
        f.write(solo_rb_contents)
      end
    end

    def create_bash_script_which_runs_chef
      run_chef = <<-EOF
#!/bin/bash
chef-solo -j #{remote_chef_dir}/#{node_json} -c #{remote_chef_dir}/#{solo_rb}
EOF
      File.open(File.join(tmp_dir, run_chef_solo_bash_script), 'w+') do |f|
        f.write(run_chef)
      end
      chmod(0755, File.join(tmp_dir, run_chef_solo_bash_script))
    end

    def create_node_json_from_remy_config
      File.open(File.join(tmp_dir, node_json), 'w+') do |f|
        f.write(configuration.to_json)
      end
    end

    def public_ip
      @public_ip
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
  end
end
