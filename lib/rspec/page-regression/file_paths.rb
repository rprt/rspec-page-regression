require 'active_support/core_ext/string/inflections'

module RSpec::PageRegression
  class FilePaths
    attr_reader :reference_screenshot
    attr_reader :test_screenshot
    attr_reader :difference_image
    attr_reader :viewport

    def initialize(example, viewport, options = {})
      descriptions = description_ancestry(example.metadata[:example_group])
      descriptions.push example.description unless example.description.parameterize('_') =~ %r{
        ^
        (then_+)?
        ( (expect_+) (page_+) (to_+) (not_+)? | (page_+) (should_+)? )
        match_reference_screenshot
        $
      }xi
      canonical_path = descriptions.map{|s| s.parameterize('_')}.inject(Pathname.new(''), &:+)

      app_root = Pathname.new(example.metadata[:file_path]).realpath.each_filename.take_while{|c| c != 'spec'}.inject(Pathname.new('/'), &:+)
      reference_root = app_root + 'spec' + 'reference_screenshots'
      test_root = app_root + 'tmp' + 'spec' + 'reference_screenshots'
      cwd = Pathname.getwd

      @viewport = viewport
      @reference_screenshot = (reference_root + canonical_path + file_name('expected', options)).relative_path_from(cwd)
      @test_screenshot = (test_root + canonical_path + file_name('test', options)).relative_path_from cwd
      @difference_image = (test_root + canonical_path + file_name('difference', options)).relative_path_from cwd
    end

    def all
      [test_screenshot, reference_screenshot, difference_image]
    end

    def self.responsive_file_paths(example, args)
      viewports(args).map do |viewport|
        new(example, viewport, args)
      end
    end


    private

    def self.viewports(args)
      all = RSpec::PageRegression.viewports
      if only = args[:viewport]
        all.select { |vp| vp.is_included_in?(only) }
      elsif except = args[:except_viewport]
        all.reject { |vp| vp.is_included_in?(except) }
      else
        RSpec::PageRegression.default_viewports
      end
    end

    def description_ancestry(metadata)
      return [] if metadata.nil?
      description_ancestry(metadata[:parent_example_group]) << metadata[:description].parameterize("_")
    end

    def file_name(name, options = {})
      #require 'byebug'
      #byebug
      filename = "#{name}"
      filename = filename + "-#{options[:label]}" if options.key?(:label)
      filename = filename + "-#{@viewport.name}" if RSpec::PageRegression.viewports.size > 1
      filename + '.png'
    end
  end
end
