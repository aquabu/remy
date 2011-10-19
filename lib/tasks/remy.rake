require 'remy/bootstrap_chef'
require 'remy/server'

namespace :remy do
  namespace :chef do
    desc 'bootstrap chef'
    task :bootstrap, :public_ip, :password do |task, options|
      Remy::BootstrapChef.new(options).bootstrap
    end
  end
  namespace :server do
    desc 'create a server'
    task :create, :name, :key, :username, :flavor_id, :image_id do |task, options|
      Remy::Server.new(options).create
    end

    desc 'create a server and bootstrap chef'
    task :create_and_bootstrap_chef, :name, :key, :username, :flavor_id, :image_id do |task, options|
      begin
        result = Remy::Server.new({:raise_exception => true}.merge(options)).create
        Rake::Task[:'remy:chef:bootstrap'].invoke(result)
      rescue
      end
    end
  end
end