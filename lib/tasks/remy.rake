require 'remy/bootstrap_chef'

namespace :remy do
  namespace :chef do
    desc 'bootstrap chef'
    task :bootstrap, :ip_address, :password do |task, options|
      Remy::BootstrapChef.new(options).bootstrap
    end
  end
end
