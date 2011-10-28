require 'remy'

namespace :remy do
  namespace :chef do
    desc 'bootstrap chef'
    task :bootstrap, :ip_address, :password do |task, options|
      Remy::BootstrapChef.new(options).bootstrap
    end

    desc 'run chef solo'
    task :run, :ip_address do |task, options|
      Rake::Task[:environment].invoke
      Remy::Chef.new(options).run
    end
  end

  namespace :server do
    desc 'create a server'
    task :create, :server_name, :cloud_api_key, :cloud_username, :flavor_id, :image_id do |task, options|
      Remy::Server.new(options).create
    end

    desc 'create a server and bootstrap chef'
    task :create_and_bootstrap_chef, :server_name, :cloud_api_key, :cloud_username, :flavor_id, :image_id do |task, options|
      begin
        result = Remy::Server.new({:raise_exception => true}.merge(options)).create
        Rake::Task[:'remy:chef:bootstrap'].invoke(result[:ip_address], result[:password])
      rescue Exception => e
      end
    end
  end
end
