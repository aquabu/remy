require 'remy/version'
Dir['remy', '**', '*.rb'].each {|f| require f }

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
