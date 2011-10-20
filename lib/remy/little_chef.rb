module Remy
  class LittleChef
    include ::Remy::Shell
    include FileUtils

    def initialize(options)
      options = JSON.parse(options).symbolize_keys! if options.is_a?(String)
      @public_ip = options[:public_ip]
      Remy.configuration.deep_merge!(options)
    end

    def run
      delete_all_files_on_remote_host_from_prior_chef_run
      create_tarball_which_contains_cookbooks_and_scripts
      copy_tarball_to_remote_host
      untar_tarball_on_remote_host
      run_chef_solo_on_remote_host
    end

    private

    def delete_all_files_on_remote_host_from_prior_chef_run
      remote_execute "rm -rf #{remote_chef_dir} #{remote_chef_dir}.tar.gz"
    end

    def create_tarball_which_contains_cookbooks_and_scripts
      olddir = pwd
      begin
        create_temp_chef_dir_and_copy_cookbook_dirs
        create_solo_rb
        create_run_chef_bash_script
        create_node_json_from_remy_config
        execute "tar czvf /tmp/chef.tar.gz chef"
      ensure
        chdir olddir
      end
    end

    def copy_tarball_to_remote_host
      remote_execute "mkdir -p #{Remy.configuration.remote_location_of_chef_dir}"
      `scp /tmp/chef.tar.gz #{user}@#{public_ip}:#{Remy.configuration.remote_location_of_chef_dir}`
    end

    def untar_tarball_on_remote_host
      remote_execute "cd #{Remy.configuration.remote_location_of_chef_dir}; tar xvzf chef.tar.gz"
    end

    def run_chef_solo_on_remote_host
      `ssh -t #{user}@#{public_ip} bash --login -c '#{remote_chef_dir}/run_chef.bash'`
    end

    def create_temp_chef_dir_and_copy_cookbook_dirs
      full_cookbook_path = Remy.configuration.cookbook_path.map{|p| File.expand_path(p) }
      tmpdir = Dir.mktmpdir
      chdir tmpdir
      mkdir 'chef'

      full_cookbook_path.each do |cookbook_path|
        cp_r cookbook_path, 'chef'
      end
    end

    def create_solo_rb
      solo_rb = <<-EOF
file_cache_path "#{remote_chef_dir}"
cookbook_path ["#{remote_chef_dir}/cookbooks"]
cache_options({ :path => "#{remote_chef_dir}/cache/checksums", :skip_expires => true })
EOF
      File.open(File.join('chef', 'solo.rb'), 'w+') do |f|
        f.write(solo_rb)
      end
    end

    def create_run_chef_bash_script
      run_chef = <<-EOF
#!/bin/bash
chef-solo -j #{remote_chef_dir}/node.json -c #{remote_chef_dir}/solo.rb
EOF
      File.open(File.join('chef', 'run_chef.bash'), 'w+') do |f|
        f.write(run_chef)
      end
      chmod(0755, File.join('chef', 'run_chef.bash'))
    end

    def create_node_json_from_remy_config
      File.open(File.join('chef', 'node.json'), 'w+') do |f|
        f.write(Remy.configuration.to_json)
      end
    end

    def public_ip
      @public_ip
    end

    def remote_chef_dir
      Remy.configuration.remote_location_of_chef_dir + "/chef"
    end
  end
end
