require 'which_works'

module RSpec::PageRegression
  RSpec::Matchers.define :match_reference_screenshot do |args|

    match do |page|
      args ||= {}
      verify_arguments(args)

      @responsive_filepaths = FilePaths.responsive_file_paths(RSpec.current_example, args)

      opt = args.select { |k,_| RENDER_ARGS.include?(k) }

      Renderer.render_responsive(page, @responsive_filepaths, opt)
      @comparisons = @responsive_filepaths.map{ |filepaths| ImageComparison.new(filepaths) }
      @comparisons.each { |comparison| return false unless comparison.result == :match }
    end

    failure_message do |page|
      msg = ''
      @comparisons.each do |comparison|
        next if comparison.result == :match
        msg +=  case comparison.result
                  when :missing_reference_screenshot then "\nMissing reference screenshot #{comparison.filepaths.reference_screenshot}\n"
                  when :missing_test_screenshot then "\nMissing test screenshot #{comparison.filepaths.test_screenshot}\n"
                  when :size_mismatch then "\nTest screenshot size #{comparison.test_size.join('x')} does not match reference screenshot size #{comparison.expected_size.join('x')}\n"
                  when :difference then "\nTest screenshot does not match reference screenshot\n"
                end

        msg += "    $ cd #{Pathname.getwd}; #{viewer} #{comparison.filepaths.all.select(&:exist?).join(' ')}\n"

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

    def verify_arguments(args)
      return if args.is_a?(Hash) && (args.keys - ALLOWED_ARGS).empty?
      raise ArgumentError, "Invalid argument: Allowed arguments are #{ALLOWED_ARGS}"
    end
  end
end
