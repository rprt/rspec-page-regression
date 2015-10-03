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
    suffix ||= RSpec::PageRegression.viewports.first.first
    "#{name}-#{suffix}"
  end
end
