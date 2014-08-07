class Block
  attr_accessor :falling
  attr_accessor :x, :y, :width, :height, :color

  @@image = nil

  def initialize(game)
  	if @@image == nil
		@@image = Gosu::Image.new(game, "brick.png", false) 
	end
	
	@x = 0
	@y = 0
	@width  = @@image.width;
	@height = @@image.height
	@game = game
	@color = 0xffffffff
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