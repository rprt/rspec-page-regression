module Helpers

  def test_path
    getpath(TestDir, "test")
  end

  def expected_path
    getpath(SpecDir, "expected")
  end

  def difference_path
    getpath(TestDir, "difference")
  end

  def getpath(root, base)
    (root + "expectation" + example_path(RSpec.current_example) + "#{base}.png").relative_path_from Pathname.getwd
  end

  def example_path(example)
    group_path(example.metadata[:example_group]) + example.description.parameterize("_")
  end

  def group_path(metadata)
    return Pathname.new("") if metadata.nil?
    group_path(metadata[:parent_example_group]) + metadata[:description].parameterize("_")
  end

end
