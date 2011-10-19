require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'remy/emile'

desc 'Run specs'
RSpec::Core::RakeTask.new do |t|
end

task :default => :spec


namespace :emile do
  desc 'Build emile'
  task :build do
    Emile.new.run
  end
end
