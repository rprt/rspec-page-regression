require "rspec/page-regression/file_paths"
require "rspec/page-regression/image_comparison"
require "rspec/page-regression/matcher"
require "rspec/page-regression/renderer"
require "rspec/page-regression/version"

module RSpec::PageRegression
  def self.configure
    yield self
  end

  def self.viewports= (viewports)
    @@viewports = viewports
  end

  def self.viewports
    @@viewports ||= [1024, 768]
  end

  def self.threshold= (threshold)
    @@threshold = threshold
  end

  def self.threshold
    @@threshold ||= 0.0
  end
end
