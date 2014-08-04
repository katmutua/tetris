require 'gosu'

class ShapeS < ShapeZ
  def get_blocks
    old_rotation = @rotation
    @rotation = 0

    super
    reverse

    @rotation = old_rotation
    apply_rotation

    @blocks.each { |block| block.color = 0xff00ff00 }
  end
end