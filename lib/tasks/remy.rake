require 'remy'

namespace :remy do
  namespace :chef do
    desc 'run chef solo'
    task :run, :ip_address do |task, options|
      begin
        Rake::Task[:environment].invoke
      rescue RuntimeError
      end

      if options[:ip_address] =~ /:/
        options = options[:ip_address].split(' ').inject({}) do |result, pair|
          key, value = pair.split(':')
          result[key] = value
          result
        end.symbolize_keys

        Remy.find_servers(options).each do |(server_name, server_config)|
          Remy::Chef.new(:ip_address => server_config.ip_address).run
        end
      else
        if options[:ip_address] && (server_config = Remy.find_server_config_by_name(options[:ip_address]))
          Remy::Chef.new({:ip_address => server_config.ip_address}).run
        else
          Remy::Chef.new(options).run
        end
      end
    end
  end

  namespace :server do
    desc 'create a server'
    task :create, :server_name, :flavor_id, :cloud_api_key, :cloud_username, :cloud_provider, :image_id do |task, options|
      begin
        Rake::Task[:environment].invoke
      rescue RuntimeError
      end

      Remy::Server.new(options).create
    end

    desc 'bootstrap chef'
    task :bootstrap, :ip_address, :password do |task, options|
      begin
        Rake::Task[:environment].invoke
      rescue RuntimeError
      end

      Remy::BootstrapChef.new(options).bootstrap
    end

    desc 'create a server and bootstrap chef'
    task :create_and_bootstrap, :server_name, :flavor_id, :cloud_api_key, :cloud_username, :cloud_provider, :image_id do |task, options|
      begin
        Rake::Task[:environment].invoke
      rescue RuntimeError
      end

      begin
        result = Remy::Server.new({:raise_exception => true}.merge(options)).create
        Rake::Task[:'remy:server:bootstrap'].invoke(result[:ip_address], result[:password])
      rescue Exception => e
      end
    end
  end
end
