require 'which_works'

module RSpec::PageRegression

  RSpec::Matchers.define :match_expectation do |expectation_path|

    match do |page|
      @filepaths = FilePaths.new(example, expectation_path)
      Renderer.render(page, @filepaths.test_image)
      @comparison = ImageComparison.new(@filepaths)
      @comparison.result == :match
    end

    failure_message_for_should do |page|
      msg = case @comparison.result
            when :missing_expected then "Missing expectation image #{@filepaths.expected_image}"
            when :missing_test then "Missing test image #{@filepaths.test_image}"
            when :size_mismatch then "Test image size #{@comparison.test_size.join('x')} does not match expectation #{@comparison.expected_size.join('x')}"
            else "Test image does not match expected image"
            end

      msg += "\n$ #{viewer} #{@filepaths.all.select(&:exist?).join(' ')}"
    end

    failure_message_for_should_not do |page|
      "Test image should not match expectation image"
    end

    def viewer
      File.basename(Which.which("open", "feh", "display", :array => true).first || "viewer")
    end
  end
end
