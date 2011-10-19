require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

Dir['lib/tasks/**/*.rake'].each {|file| load file }

desc 'Run specs'
RSpec::Core::RakeTask.new do |t|
end

task :default => :spec
