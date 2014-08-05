require 'gosu'
require_relative 'shape'

class ShapeT < Shape
  
  RED_1_COLOR = 0xffff0000
  def initialize(game)
    super(game)
    @rotation_block = @blocks[1]
    @rotation_cycle = 4
  end

  def get_blocks
    @blocks[0].x = @x
    @blocks[1].x = @x + @game.block_width
    @blocks[2].x = @x + @game.block_width*2
    @blocks[3].x = @x + @game.block_width
    @blocks[0].y = @y
    @blocks[1].y = @y
    @blocks[2].y = @y
    @blocks[3].y = @y + @game.block_height

    apply_rotation
    @blocks.each { |block| block.color = RED_1_COLOR }
  end

end
