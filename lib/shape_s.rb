require 'gosu'
require_relative 'shape_z'

class ShapeS < ShapeZ
  
  MAGENTA_COLOR  = 0xff00ff00

  def get_blocks
    old_rotation = @rotation
    @rotation = 0

    super
    reverse

    @rotation = old_rotation
    apply_rotation

    @blocks.each { |block| block.color = MAGENTA_COLOR }
  end

end