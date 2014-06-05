require 'which_works'

module RSpec::PageRegression

  RSpec::Matchers.define :match_expectation do |expectation_path|

    match do |page|
      @filepaths = FilePaths.new(RSpec.current_example, expectation_path)
      Renderer.render(page, @filepaths.test_image)
      @comparison = ImageComparison.new(@filepaths)
      @comparison.result == :match
    end

    failure_message do |page|
      msg = case @comparison.result
            when :missing_expected then "Missing expectation image #{@filepaths.expected_image}"
            when :missing_test then "Missing test image #{@filepaths.test_image}"
            when :size_mismatch then "Test image size #{@comparison.test_size.join('x')} does not match expectation #{@comparison.expected_size.join('x')}"
            when :difference then "Test image does not match expected image"
            end

      msg += "\n    $ #{viewer} #{@filepaths.all.select(&:exist?).join(' ')}"

      case @comparison.result
      when :missing_expected
        msg += "\nCreate it via:\n    $ mkdir -p #{@filepaths.expected_image.dirname} && cp #{@filepaths.test_image} #{@filepaths.expected_image}"
      end

      msg
    end

    failure_message_when_negated do |page|
      "Test image expected to not match expectation image"
    end

    def viewer
      File.basename(Which.which("open", "feh", "display", :array => true).first || "viewer")
    end
  end
end
