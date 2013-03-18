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
    (root + "expectation" + group_path(example.metadata) + "#{base}.png").relative_path_from Pathname.getwd
  end

  def group_path(metadata)
    return Pathname.new("") if metadata.nil?
    group_path(metadata[:example_group]) + metadata[:description].parameterize("_")
  end

end
