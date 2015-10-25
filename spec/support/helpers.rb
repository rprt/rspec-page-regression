module Helpers

  def test_path(suffix = nil)
    getpath(TestDir, file_name('test', suffix))
  end

  def reference_screenshot_path(suffix = nil)
    getpath(SpecDir, file_name('expected', suffix))
  end

  def difference_path(suffix = nil)
    getpath(TestDir, file_name('difference', suffix))
  end

  def getpath(root, base)
    (root + "reference_screenshots" + example_path(RSpec.current_example) + "#{base}.png").relative_path_from Pathname.getwd
  end

  def example_path(example)
    group_path(example.metadata[:example_group]) + example.description.parameterize("_")
  end

  def group_path(metadata)
    return Pathname.new("") if metadata.nil?
    group_path(metadata[:parent_example_group]) + metadata[:description].parameterize("_")
  end

  def file_name(name, suffix = nil)
    return name unless RSpec::PageRegression.viewports.size > 1
    suffix ||= RSpec::PageRegression.viewports.first.name
    "#{name}-#{suffix}"
  end

  def fixture_screenshot(name)
    FixturesDir + "#{name}.png"
  end

  def use_fixture_screenshot(name, path)
    path.dirname.mkpath unless path.dirname.exist?
    FileUtils.cp fixture_screenshot(name), path
  end

  def use_test_screenshot(name, suffix = nil)
    use_fixture_screenshot(name, test_path(suffix))
  end

  def use_reference_screenshot(name, suffix = nil)
    use_fixture_screenshot(name, reference_screenshot_path(suffix))
  end

  def preexisting_difference_image
    difference_path.dirname.mkpath unless difference_path.dirname.exist?
    FileUtils.touch difference_path
  end

  def viewer_pattern(*paths)
    %r{
      \b
      (open|feh|display|viewer)
      \s
      #{paths.map{|path| Regexp.escape(path.to_s)}.join('\s')}
      \s*$
    }x
  end

  def with_config_viewports(args)
    pre_config = RSpec::PageRegression.viewports
    begin
      RSpec::PageRegression.configure do |config|
        config.viewports = args[:viewports]
        config.default_viewports = args[:default_viewports] || args[:viewports].keys
      end
      yield
    ensure
      RSpec::PageRegression.configure do |config|
        config.viewports = viewports_to_hash(pre_config)
        config.default_viewports = pre_config.map(&:name)
      end
    end
  end

  def viewports_to_hash(viewports)
    viewports.map{ |vp| Hash[vp.name, vp.size] }.reduce(:merge)
  end
end
