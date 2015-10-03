require 'active_support/core_ext/string/inflections'

module RSpec::PageRegression
  class FilePaths
    attr_reader :reference_screenshot
    attr_reader :test_screenshot
    attr_reader :difference_image
    attr_reader :viewport

    def initialize(example, viewport, reference_screenshot_path = nil)
      reference_screenshot_path = Pathname.new(reference_screenshot_path) if reference_screenshot_path

      descriptions = description_ancestry(example.metadata[:example_group])
      descriptions.push example.description unless example.description.parameterize('_') =~ %r{
        ^
        (then_+)?
        ( (expect_+) (page_+) (to_+) (not_+)? | (page_+) (should_+)? )
        match_reference_screenshot
        (_#{Regexp.escape(reference_screenshot_path.to_s)})?
          $
      }xi
      canonical_path = descriptions.map{|s| s.parameterize('_')}.inject(Pathname.new(''), &:+)

      app_root = Pathname.new(example.metadata[:file_path]).realpath.each_filename.take_while{|c| c != 'spec'}.inject(Pathname.new('/'), &:+)
      reference_root = app_root + 'spec' + 'reference_screenshots'
      test_root = app_root + 'tmp' + 'spec' + 'reference_screenshots'
      cwd = Pathname.getwd

      @viewport = viewport
      @reference_screenshot = reference_screenshot_path || (reference_root + canonical_path + file_name('expected')).relative_path_from(cwd)
      @test_screenshot = (test_root + canonical_path + file_name('test')).relative_path_from cwd
      @difference_image = (test_root + canonical_path + file_name('difference')).relative_path_from cwd
    end

    def all
      [test_screenshot, reference_screenshot, difference_image]
    end

    def self.responsive_file_paths(example, reference_screenshot_path = nil)
      RSpec::PageRegression.viewports.map do |viewport|
        new(example, viewport, reference_screenshot_path)
      end
    end


    private

    def description_ancestry(metadata)
      return [] if metadata.nil?
      description_ancestry(metadata[:parent_example_group]) << metadata[:description].parameterize("_")
    end

    def file_name(prefix)
      "#{prefix}-#{@viewport.first}.png"
    end
  end
end
