require 'active_support/core_ext/string/inflections'

module RSpec::PageRegression
  class FilePaths
    attr_reader :expected_image
    attr_reader :test_image
    attr_reader :difference_image

    def initialize(example, expected_path = nil)
      expected_path = Pathname.new(expected_path) if expected_path

      descriptions = description_ancestry(example.metadata)
      descriptions.pop if descriptions.last =~ %r{
        ^
        (then_+)? (page_+)? (should_+)? match_expectation
        (_#{Regexp.escape(expected_path.to_s)})?
          $
      }xi
      canonical_path = descriptions.map{|s| s.parameterize('_')}.inject(Pathname.new(""), &:+)

      expected_root = Pathname.new(example.metadata[:file_path]).realpath.dirname + "expectation"
      tmp_root = expected_root.sub %r{\bspec\b}, "tmp/spec"
      cwd = Pathname.getwd

      @expected_image = expected_path || (expected_root + canonical_path + "expected.png").relative_path_from(cwd)
      @test_image = (tmp_root + canonical_path + "test.png").relative_path_from cwd
      @difference_image = (tmp_root + canonical_path + "difference.png").relative_path_from cwd
    end

    def all
      [test_image, expected_image, difference_image]
    end


    private

    def description_ancestry(metadata)
      return [] if metadata.nil?
      description_ancestry(metadata[:example_group]) << metadata[:description].parameterize("_")
    end
  end
end
