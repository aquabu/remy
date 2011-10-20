module Remy
  class Configuration
    attr_accessor :yml_files, :cookbook_path
  end

  class << self
    include ::Remy::Shell
    include FileUtils

    def configure
      @config_instance = Configuration.new
      yield @config_instance
      @configuration = Mash.new(:yml_files => @config_instance.yml_files, :cookbook_path => @config_instance.cookbook_path)

      @config_instance.yml_files.each do |filename|
        configuration.deep_merge!(YAML::load(IO.read(filename)))
      end
    end

    def configuration
      @configuration
    end

    def tar
      olddir = pwd
      begin
        full_cookbook_path = configuration.cookbook_path.map{|p| File.expand_path(p) }
        tmpdir = Dir.mktmpdir
        chdir tmpdir
        mkdir 'chef'
        full_cookbook_path.each do |cookbook_path|
          cp_r cookbook_path, 'chef'
        end
        solo_rb = <<-EOF
file_cache_path "/var/chef"
cookbook_path ["/var/chef/cookbooks"]
EOF
        File.open(File.join('chef', 'solo.rb'), 'w+') do |f|
          f.write(solo_rb)
        end
        File.open(File.join('chef', 'node.json'), 'w+') do |f|
          f.write(to_json)
        end
        execute "tar czvf /tmp/chef.tar.gz chef"
      ensure
        chdir olddir
      end
    end

    def run_chef_remote(public_ip)
      @public_ip = public_ip
      tar
      remote_execute "rm -rf /var/chef /var/chef.tar.gz"
      `scp /tmp/chef.tar.gz #{user}@#{public_ip}:/var`
      remote_execute "cd /var; tar xvzf chef.tar.gz"
      #remote_execute "cd /var/chef ; rvm use 1.8.7 ; chef-solo -j node.json -c solo.rb"
    end

    def public_ip
      @public_ip
    end

    def to_json
      configuration.to_json
    end
  end
end
