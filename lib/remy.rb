require 'active_support/core_ext/class/attribute_accessors'
require 'mash'

Dir[File.join(File.dirname(__FILE__), 'remy', '**', '*.rb')].each { |f| require f }

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
