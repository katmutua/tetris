require_relative 'shape_l'

class ShapeJ < ShapeL
  
  BLUE_COLOR = 0xff0000ff

  def get_blocks
    old_rotation = @rotation
    @rotation = 0

    super
    reverse

    @rotation = old_rotation
    apply_rotation

    @blocks.each { |block| block.color = BLUE_COLOR }
  end

end
