module Remy
  class BootstrapChef
    attr_reader :ip_address, :ruby_version, :password, :quiet

    def initialize(options = { })
      @ruby_version = options[:ruby_version] || '1.8.7'
      @ip_address = options[:ip_address]
      @password = options[:password]
      @quiet = options[:quiet] || false
    end

    def bootstrap
      ssh_copy_id
      update_linux_distribution
      rvm_install
      install_minimal_gems_to_bootstrap_chef
    end

    def user
      'root'
    end

    private
    def apt_get_rvm_packages
      # This list of required packages came from doing "rvm requirements"
      remote_apt_get 'build-essential openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-0 libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison'
    end

    def execute(command)
      puts "command: #{command}"
      if quiet
        `#{command} 2>&1`
        $?.success?
      else
        system command
      end
    end

    def install_minimal_gems_to_bootstrap_chef
      remote_gem 'bundler'
      remote_gem 'chef'
    end

    def rvm_install
      remote_execute rvm_multi_user_install
      apt_get_rvm_packages
      remote_execute "/usr/local/rvm/bin/rvm install #{ruby_version}"
      remote_execute "/usr/local/rvm/bin/rvm #{ruby_version} --default"
    end

    def rvm_multi_user_install
      'curl -s https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer -o rvm-installer ; chmod +x rvm-installer ; sudo -s ./rvm-installer --version latest'
    end

    def ssh_copy_id
      is_ssh_key_in_local_known_hosts_file = `grep "#{ip_address}" ~/.ssh/known_hosts`.length > 0
      if is_ssh_key_in_local_known_hosts_file
        execute %Q{expect -c 'spawn ssh-copy-id #{user}@#{ip_address}; expect assword ; send "#{password}\\n" ; interact'}
      else
        execute %Q{expect -c 'spawn ssh-copy-id #{user}@#{ip_address}; expect continue; send "yes\\n"; expect assword ; send "#{password}\\n" ; interact'}
      end
    end

    def remote_gem(gem_name, options={ })
      if options[:version]
        version = options[:version]
        raise ArgumentError.new unless version.match(/^\d[.\d]+\d/)
        version_info = "-v #{version}"
      end
      remote_execute "/usr/local/rvm/bin/gem install #{gem_name} #{version_info} --no-rdoc --no-ri"
    end

    def remote_apt_get(package_name)
      remote_execute "apt-get install -y #{package_name}"
    end

    def remote_execute(cmd)
      raise ArgumentError.new unless ip_address
      execute "ssh #{user}@#{ip_address} '#{cmd.strip}'"
    end

    def update_linux_distribution
      remote_execute 'apt-get update && yes | apt-get upgrade'
    end
  end
end
