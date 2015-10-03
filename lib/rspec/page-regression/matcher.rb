require 'which_works'

module RSpec::PageRegression

  RSpec::Matchers.define :match_reference_screenshot do |reference_screenshot_path|

    match do |page|
      @responsive_filepaths = FilePaths.responsive_file_paths(RSpec.current_example, reference_screenshot_path)
      Renderer.render_responsive(page, @responsive_filepaths)
      @comparisons = @responsive_filepaths.map{ |filepaths| ImageComparison.new(filepaths) }
      @comparisons.each { |comparison| return false unless comparison.result == :match }
    end

    failure_message do |page|
      msg = ''
      @comparisons.each do |comparison|
        next if comparison.result == :match
        msg +=  case comparison.result
                  when :missing_reference_screenshot then "\nMissing expectation image #{comparison.filepaths.reference_screenshot}\n"
                  when :missing_test_screenshot then "\nMissing test image #{comparison.filepaths.test_screenshot}\n"
                  when :size_mismatch then "\nTest image size #{comparison.test_size.join('x')} does not match expectation #{comparison.expected_size.join('x')}\n"
                  when :difference then "\nTest image does not match expected image\n"
                end

        msg += "    $ #{viewer} #{comparison.filepaths.all.select(&:exist?).join(' ')}\n"

        case comparison.result
        when :missing_reference_screenshot
          msg += "Create it via:\n    $ mkdir -p #{comparison.filepaths.reference_screenshot.dirname} && cp #{comparison.filepaths.test_screenshot} #{comparison.filepaths.reference_screenshot}\n"
        end
      end

      msg
    end

    failure_message_when_negated do |page|
      'Test screenshot expected to not match reference screenshot'
    end

    def viewer
      File.basename(Which.which('open', 'feh', 'display', array: true).first || 'viewer')
    end
  end
end
