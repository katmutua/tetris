class Tetris::Block
  attr_accessor :falling
  attr_accessor :x, :y, :width, :height, :color
  
  @@image = nil
  
  def initialize(game)
    @@image = Gosu::Image.new(game, "brick.png", false) if @image.nil?
    reset_axes
    reset_length
    @game = game
    @color = 0xffffffff
  end

  def reset_axes
    @x = 0
    @y = 0
  end

  def reset_length
    @width  = @@image.width
    @height = @@image.height
  end
  
  def draw
    @@image.draw(@x, @y, 0, 1, 1, @color)
  end
  
  def collide(block)
    return (block.x == @x && block.y == @y)
  end
  
  def collide_with_other_blocks
    @game.blocks.each do |block|
      if collide(block)
	       return block
	    end
	  end
    nil
  end

end