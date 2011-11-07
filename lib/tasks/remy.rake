require 'remy'

namespace :remy do
  task :environment do
    begin
      Rake::Task[:environment].invoke
    rescue RuntimeError
    end
  end

  desc 'ssh to a named box'
  task :ssh, :rake_args do |task, options|
    Rake::Task[:'remy:environment'].invoke
    if ip_address = Remy.determine_ip_addresses_for_remy_run(options[:rake_args]).try(:first)
      exec "ssh root@#{ip_address}"
    end
  end

  namespace :chef do
    desc 'run chef solo'
    task :run, :rake_args do |task, options|
      Rake::Task[:'remy:environment'].invoke
      Remy::Chef.rake_run(options[:rake_args])
    end
  end

  namespace :server do
    desc 'create a server'
    task :create, :server_name, :flavor_id, :cloud_api_key, :cloud_username, :cloud_provider, :image_id do |task, options|
      Rake::Task[:'remy:environment'].invoke
      Remy::Server.new(options).create
    end

    desc 'bootstrap chef'
    task :bootstrap, :ip_address, :password do |task, options|
      Rake::Task[:'remy:environment'].invoke
      Remy::Bootstrap.new(options).run
    end

    desc 'create a server and bootstrap chef'
    task :create_and_bootstrap, :server_name, :flavor_id, :cloud_api_key, :cloud_username, :cloud_provider, :image_id do |task, options|
      Rake::Task[:'remy:environment'].invoke
      begin
        result = Remy::Server.new({:raise_exception => true}.merge(options)).create
        Rake::Task[:'remy:server:bootstrap'].invoke(result[:ip_address], result[:password])
      rescue Exception => e
      end
    end
  end
end
