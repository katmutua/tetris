require 'gosu'
require_relative 'shape_l'

class ShapeJ < ShapeL
  def get_blocks
    old_rotation = @rotation
    @rotation = 0

    super
    reverse

    @rotation = old_rotation
    apply_rotation

    @blocks.each { |block| block.color = 0xff0000ff }
  end
end
