# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'remy/version'

Gem::Specification.new do |s|
  s.name        = 'remy'
  s.version     = Remy::VERSION
  s.authors     = ['Greg Woodward & Ryan Dy']
  s.email       = ['pair+gwoodward+rdy@pivotallabs.com']
  s.homepage    = 'http://sharespost.com'
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = 'remy'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  # specify any dependencies here; for example:
  s.add_development_dependency 'rspec', '~> 2.7.0'
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'bourne'
  s.add_runtime_dependency 'fog'
end
