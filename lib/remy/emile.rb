class Emile
  attr_reader :ip_address, :ruby_version, :password

  def initialize(options = {})
    @ruby_version = options[:ruby_version] || '1.8.7'
    @ip_address = options[:ip_address]
    @password = options[:password]
  end

  def run
    copy_public_ssh_key_to_new_remote_server
    remote_execute rvm_multi_user_install
    apt_get_rvm_packages
    remote_execute "/usr/local/rvm/bin/rvm install #{ruby_version}"
    remote_execute "/usr/local/rvm/bin/rvm #{ruby_version} --default"
    install_minimal_gems_to_bootstrap_chef
  end

  private
  def user
    'root'
  end

  def rvm_multi_user_install
    'curl -s https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer -o rvm-installer ; chmod +x rvm-installer ; sudo -s ./rvm-installer --version latest'
  end

  def copy_public_ssh_key_to_new_remote_server
    is_ssh_key_in_local_known_hosts_file = `grep "#{ip_address}" ~/.ssh/known_hosts`
    if is_ssh_key_in_local_known_hosts_file.length > 1
      `expect -c 'spawn ssh-copy-id #{user}@#{ip_address}; expect assword ; send "#{password}\\n" ; interact'`
    else
      `expect -c 'spawn ssh-copy-id #{user}@#{ip_address}; expect continue; send "yes\\n"; expect assword ; send "#{password}\\n" ; interact'`
    end
  end

  def apt_get_rvm_packages
    # This list of required packages came from doing "rvm requirements"
    remote_apt_get 'build-essential openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-0 libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison'
  end

  def install_minimal_gems_to_bootstrap_chef
    remote_gem 'bundler'
    remote_gem 'chef'
  end

  def remote_gem(gem_name, options={ })
    if options[:version]
      version = options[:version]
      raise "Unexexpected gem version #{version.inspect}" unless version.match(/^\d[.\d]+\d/)
      version_info = "-v #{version}"
    end
    remote_execute "/usr/local/rvm/bin/gem install #{gem_name} #{version_info} --no-rdoc --no-ri"
  end

  def remote_apt_get(package_name)
    remote_execute "apt-get install -y #{package_name}"
  end

  def remote_execute(cmd)
    raise "Please set ip_address variable" unless ip_address
    `ssh #{user}@#{ip_address} '#{cmd.strip}'`
  end
end
