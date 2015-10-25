class Viewport
  attr_accessor :name, :size
  def initialize(name, size)
    @name = name
    @size = size
  end

  def is_included_in?(args)
    Array(args).include?(self.name)
  end
end
