class ShapeCube < Shape
  
  def get_blocks
    @blocks[0].x = @x
    @blocks[1].x = @x
    @blocks[2].x = @x + @game.block_width
    @blocks[3].x = @x + @game.block_width
    @blocks[0].y = @y
    @blocks[1].y = @blocks[0].y + @game.block_height
    @blocks[2].y = @blocks[0].y
    @blocks[3].y = @blocks[2].y + @game.block_height

    @blocks.each { |block| block.color = 0xffffff00 }
  end
  
end