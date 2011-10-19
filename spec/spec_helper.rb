ENV["RAILS_ENV"] ||= 'test'

require 'rubygems'
require 'bundler/setup'
require 'active_support'
require 'mocha'
require 'remy'

Dir[File.join(File.dirname(__FILE__), 'spec', 'support', '**' '*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.mock_with :mocha
end

#
#
#chef.yml:
#
#common:
#  cookbooks:
#    - chef/cookbooks
#
#
#
#demo:
#  data_files:
#    - config/chef.yml
#    - /Volumes/passwords/password.yml
#    - ... files
#  config_files:
#    - chef/config/chef_config.yml
#    - foobar.yml
#    - etc.
#
#
#
#staging:
#
#production:

