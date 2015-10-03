require 'which_works'

module RSpec::PageRegression

  RSpec::Matchers.define :match_reference_screenshot do |reference_screenshot_path|

    match do |page|
      @responsive_filepaths = FilePaths.responsive_file_paths(RSpec.current_example, reference_screenshot_path)
      Renderer.render_responsive(page, @responsive_filepaths)
      @filepaths = @responsive_filepaths.first
      @comparison = ImageComparison.new(@filepaths)
      @comparison.result == :match
    end

    failure_message do |page|
      msg = case @comparison.result
            when :missing_reference_screenshot then "Missing reference screenshot #{@filepaths.reference_screenshot}"
            when :missing_test_screenshot then "Missing test screenshot #{@filepaths.test_screenshot}"
            when :size_mismatch then "Test screenshot size #{@comparison.test_size.join('x')} does not match reference screenshot size #{@comparison.expected_size.join('x')}"
            when :difference then "Test screenshot does not match reference screenshot"
            end

      msg += "\n    $ #{viewer} #{@filepaths.all.select(&:exist?).join(' ')}"

      case @comparison.result
      when :missing_reference_screenshot
        msg += "\nCreate it via:\n    $ mkdir -p #{@filepaths.reference_screenshot.dirname} && cp #{@filepaths.test_screenshot} #{@filepaths.reference_screenshot}"
      end

      msg
    end

    failure_message_when_negated do |page|
      "Test screenshot expected to not match reference screenshot"
    end

    def viewer
      File.basename(Which.which('open', 'feh', 'display', array: true).first || 'viewer')
    end
  end
end
