require 'pathname'
require 'simplecov'
require 'simplecov-gem-adapter'
SimpleCov.start "gem"

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rspec'
require 'rspec/given'
require 'rspec/page-regression'
require 'bourne'

SpecDir = Pathname.new(__FILE__).dirname
RootDir = SpecDir.dirname
TestDir = RootDir + "tmp/spec"
FixturesDir = SpecDir + "fixtures"

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :mocha
  config.include Helpers
  config.raise_errors_for_deprecations!
end
