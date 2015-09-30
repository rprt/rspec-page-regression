require 'active_support/core_ext/string/inflections'

module RSpec::PageRegression
  class FilePaths
    attr_reader :reference_screenshot
    attr_reader :test_screenshot
    attr_reader :difference_image

    def initialize(example, reference_screenshot_path = nil)
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
      canonical_path = descriptions.map{|s| s.parameterize('_')}.inject(Pathname.new(""), &:+)

      app_root = Pathname.new(example.metadata[:file_path]).realpath.each_filename.take_while{|c| c != "spec"}.inject(Pathname.new("/"), &:+)
      reference_root = app_root + "spec" + "reference_screenshots"
      test_root = app_root + "tmp" + "spec" + "reference_screenshots"
      cwd = Pathname.getwd

      @reference_screenshot = reference_screenshot_path || (reference_root + canonical_path + "expected.png").relative_path_from(cwd)
      @test_screenshot = (test_root + canonical_path + "test.png").relative_path_from cwd
      @difference_image = (test_root + canonical_path + "difference.png").relative_path_from cwd
    end

    def all
      [test_screenshot, reference_screenshot, difference_image]
    end


    private

    def description_ancestry(metadata)
      return [] if metadata.nil?
      description_ancestry(metadata[:parent_example_group]) << metadata[:description].parameterize("_")
    end
  end
end
