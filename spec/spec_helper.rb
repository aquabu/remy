ENV["RAILS_ENV"] ||= 'test'

require 'rubygems'
require 'bundler/setup'
require 'active_support'
require 'mocha'
require 'json'
require 'remy'

Dir[File.join(File.dirname(__FILE__), 'spec', 'support', '**' '*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.mock_with :mocha
end

IP_ADDRESS = '50.57.163.233'
