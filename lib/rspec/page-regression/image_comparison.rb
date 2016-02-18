require 'imatcher'

module RSpec::PageRegression
  class ImageComparison
    attr_reader :filepaths

    def initialize(filepaths, compare_options)
      @filepaths = filepaths
      @matcher = Imatcher::Matcher.new(compare_options)
    end

    def expected_size
      [@iexpected.width, @iexpected.height]
    end

    def test_size
      [@itest.width, @itest.height]
    end

    def result
      @result ||= compare
    end

    private

    def compare
      @filepaths.difference_image.unlink if @filepaths.difference_image.exist?

      return :missing_reference_screenshot unless @filepaths.reference_screenshot.exist?
      return :missing_test_screenshot unless @filepaths.test_screenshot.exist?

      @iexpected = Imatcher::Image.from_file @filepaths.reference_screenshot
      @itest = Imatcher::Image.from_file @filepaths.test_screenshot

      begin
        matcher_result = @matcher.compare(@iexpected, @itest)
      rescue Imatcher::SizesMismatchError
        return :size_mismatch
      end

      return :match if matcher_result.match?

      matcher_result.difference_image.save @filepaths.difference_image
      :difference
    end
  end
end
