# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rspec/page-regression/version'

Gem::Specification.new do |spec|
  spec.name          = 'rspec-page-regression'
  spec.version       = RSpec::PageRegression::VERSION
  spec.authors       = ['ronen barzel']
  spec.email         = ['ronen@barzel.org']
  spec.summary       = %q{Web page rendering (HTML, CSS, and JavasSript) regression for RSpec}
  spec.description   = %q{Rspec-page-regression provides a mechanism for headless regression testing of web page renders in RSpec. It takes into account HTML, CSS, and JavaScript, by virtue of using PhantomJS (via the Poltergeist gem) to render snapshots.  It provides an RSpec matcher that compares the test snapshot to a reference screenshot, and facilitates management of the images.}
  spec.homepage      = 'https://github.com/ronen/rspec-page-regression'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport'
  spec.add_dependency 'imatcher', '~> 0.1.5'
  spec.add_dependency 'rspec', '~> 3.0'
  spec.add_dependency 'which_works'

  spec.add_development_dependency 'bourne'
  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'mocha'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec-given'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'simplecov-gem-adapter'
  spec.add_development_dependency 'coveralls'
end
