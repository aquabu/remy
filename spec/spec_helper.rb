ENV["RAILS_ENV"] ||= 'test'

require 'rubygems'
require 'bundler/setup'
require 'remy'

Dir[File.join(File.dirname(__FILE__), 'spec', 'support', '**' '*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.mock_with :mocha
end
