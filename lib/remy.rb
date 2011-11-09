begin
  require 'active_support/core_ext/object/to_json'
rescue LoadError
  require 'active_support/json/encoders/object'
end

begin
  require 'active_support/core_ext/object/try'
rescue LoadError
  require 'active_support/core_ext/try'
end

require 'active_support/core_ext/hash'
require 'fog'
require 'erb'
require 'json'
require 'hashie'
require 'tmpdir'
require 'remy/shell'
require 'yaml'
dir = File.dirname(__FILE__)
Dir[File.join(File.dirname(__FILE__), 'remy', '**', '*.rb')].each {|f| require f.gsub(dir, '')[1, f.length] }

module Remy
  begin
    class Railtie < ::Rails::Railtie
      rake_tasks do
        load 'tasks/remy.rake'
      end
    end
  rescue LoadError, NameError
  end
end
