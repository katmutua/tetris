require_relative 'shape'

class ShapeI < Shape

  LIGHT_PINK_COLOR = 0xffb2ffff
  
  def initialize(game)
    super(game)
    @blocks = []
    @rotation_block = @blocks[1]
    @rotation_cycle = 2
  end

  def get_blocks
    @blocks[0].x = @x
    @blocks[1].x = @x
    @blocks[2].x = @x
    @blocks[3].x = @x
    @blocks[0].y = @y
    @blocks[1].y = @blocks[0].y + @blocks[0].height
    @blocks[2].y = @blocks[1].y + @blocks[1].height
    @blocks[3].y = @blocks[2].y + @blocks[2].height

    apply_rotation

    @blocks.each { |block| block.color = LIGHT_PINK_COLOR }
  end

end