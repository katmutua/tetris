require 'gosu'
require_relative 'shape'

class ShapeL < Shape
  
  def initialize(game)
    super(game)
    @rotation_block = @blocks[1]
    @rotation_cycle = 4
  end

  def get_blocks
    @blocks[0].x = @x
    @blocks[1].x = @x
    @blocks[2].x = @x
    @blocks[3].x = @x + @game.block_width
    @blocks[0].y = @y
    @blocks[1].y = @blocks[0].y + @game.block_height
    @blocks[2].y = @blocks[1].y + @game.block_height
    @blocks[3].y = @blocks[2].y

    apply_rotation

    @blocks.each { |block| block.color = 0xffff7f00 }
  end
  
end