require 'active_support/core_ext/object/to_json'
require 'active_support/core_ext/object/try'
require 'active_support/core_ext/hash'
require 'fog'
require 'erb'
require 'json'
require 'mash'
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
