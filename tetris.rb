require 'gosu'

class Block
  attr_accessor :falling
  attr_accessor :x, :y, :width, :height, :color
  
  @@image = nil
  
  def initialize(game)
   require 'gosu'

class Block
  attr_accessor :falling
  attr_accessor :x, :y, :width, :height, :color
  
  @@image = nil
  
  def initialize(game)
    # Image is loaded only once for all blocks
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
    # Two blocks collide only when they are at the same position, since the world is a grid
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

class Shape
  attr_accessor :rotation
  def initialize(game)
    @game = game
    @last_fall_update = Gosu::milliseconds 
    @last_move_update = Gosu::milliseconds 
	
	@blocks = [Block.new(game), Block.new(game), Block.new(game), Block.new(game) ]

	@x = @y = 0
	@falling = true
	
	# Rotation is done about this block
	@rotation_block = @blocks[1]
	# How many rotations we can do before a full cycle?
	@rotation_cycle = 1
	# Current rotation state
	@rotation = 0
  end
  
  def apply_rotation
    # Each rotation is a 90 degree in the clockwise direction
    if @rotation_block != nil
		(1..@rotation.modulo(@rotation_cycle)).each do |i|
		  @blocks.each do |block|
			old_x = block.x
			old_y = block.y
			block.x = @rotation_block.x + (@rotation_block.y - old_y)
			block.y = @rotation_block.y - (@rotation_block.x - old_x)
		  end
		end
    end
  end
  
  # Note that the following function is defined properly only when the object is unrotated
  # Otherwise the line of symmetry will be misplaced and wrong results will be produced
  def reverse
    # Mirror the shape by the y axis, effectively creating shape counterparts such as 'L' and 'J'
    center = (get_bounds[2] + get_bounds[0]) / 2.0
    @blocks.each do |block|
	  block.x = 2*center - block.x - @game.block_width
	end
  end
  
  def get_bounds
    # Go throug all blocks to find the bounds of this shape
    x_min = []
	y_min = []
	x_max = []
	y_max = []
    @blocks.each do |block| 
	  x_min << block.x
	  y_min << block.y
	  
	  x_max << block.x + block.width
	  y_max << block.y + block.height
	end

	return [x_min.min, y_min.min, x_max.max, y_max.max]
  end
  
  # Updates to movement are done periodically to allow the player time for reaction
  def needs_fall_update?
    if ( @game.button_down?(Gosu::KbDown) )
      updateInterval = 100
	else
	  updateInterval = 500 - @game.level*50
	end
	if ( Gosu::milliseconds - @last_fall_update > updateInterval )
      @last_fall_update = Gosu::milliseconds 
	end
  end
  
  def needs_move_update?
	if ( Gosu::milliseconds - @last_move_update > 100 )
	  @last_move_update = Gosu::milliseconds 
    end
  end
  
  def draw
    get_blocks.each { |block| block.draw }
  end
  
  def update
    if ( @falling ) 
	  # After a movement or gravity update, we check if the moved shape collides with the world.
	  # If it does, we restore its position to the last known good position
	  old_x = @x
	  old_y = @y
	  
	  if needs_fall_update?
		@y = (@y + @game.block_height)
	  end
	  
	  # Important to note is that we do 2 collision checks - once we moved on the x axis and once we moved on the y axis
	  # This way we can determine which of the 2 movements is responisble for the collision and learn on which side of the colliding block
	  # the collision occured.
	  if ( collide )
	    @y = (old_y)
		@falling = false
		@game.spawn_next_shape
		@game.delete_lines_of(self)
	  else  
	    if needs_move_update?
		  if (@game.button_down?(Gosu::KbLeft))
		    @x =  (@x - @game.block_width)
		  end
		  if (@game.button_down?(Gosu::KbRight))
			@x = ( @x + @game.block_width)
		  end
		  
		  if ( collide )
		    @x = (old_x)
		  end 
		end  
	  end
	end
  end
  
  def collide
    get_blocks.each do |block|
	  collision = block.collide_with_other_blocks;
	  if (collision)
	    return true
	  end
    end

    bounds = get_bounds
  
    if ( bounds[3] > @game.height )
	  return true
    end
  
    if ( bounds[2] > @game.width )
	  return true
    end
  
    if ( bounds[0] < 0 )
	  return true
    end	
    return false
  end
  
end

class ShapeI < Shape
  def initialize(game)
    super(game)
	
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
	
	@blocks.each { |block| block.color = 0xffb2ffff }
  end
end

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

class ShapeJ < ShapeL
  def get_blocks
    # Reverse will reverse also the direction of rotation that's applied in apply_rotation
	# This will temporary disable rotation in the super method, so we can handle the rotation here after the reverse
    old_rotation = @rotation
    @rotation = 0  
	
    super
	reverse
	
	@rotation = old_rotation
	apply_rotation
	
	@blocks.each { |block| block.color = 0xff0000ff}
  end
end

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
	
	@blocks.each { |block| block.color = 0xffffff00}
  end
end

class ShapeZ < Shape
  def initialize(game)
    super(game)
	
	@rotation_block = @blocks[1]
	@rotation_cycle = 2
  end
  
  def get_blocks
	@blocks[0].x = @x
	@blocks[1].x = @x + @game.block_width
	@blocks[2].x = @x + @game.block_width
	@blocks[3].x = @x + @game.block_width*2
	@blocks[0].y = @y
  	@blocks[1].y = @y
	@blocks[2].y = @y + @game.block_height
	@blocks[3].y = @y + @game.block_height
	
	apply_rotation
	@blocks.each { |block| block.color = 0xffff0000}
  end
end

class ShapeS < ShapeZ
  def get_blocks
    # Reverse will reverse also the direction of rotation that's applied in apply_rotation
	# This will temporary disable rotation in the super method, so we can handle the rotation here after the reverse
    old_rotation = @rotation
    @rotation = 0  
	
    super
	reverse
	
	@rotation = old_rotation
	apply_rotation
	
	@blocks.each { |block| block.color = 0xff00ff00}
  end
end

class ShapeT < Shape
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
	@blocks.each { |block| block.color = 0xffff00ff}
  end
end

class TetrisGameWindow < Gosu::Window
  attr_accessor :blocks
  attr_reader :block_height, :block_width
  attr_reader :level
  attr_reader :falling_shape
  
  STATE_PLAY = 1
  STATE_GAMEOVER = 2
  
  def initialize
    super(320, 640, false)
	
	@block_width = 32
	@block_height = 32
	
	@blocks = []
	
	@state = STATE_PLAY
	
	spawn_next_shape
	
	@lines_cleared = 0
	@level = 0
	
	self.caption = "Tetris : #{@lines_cleared} lines"
	
    @song = Gosu::Song.new("TetrisB_8bit.ogg")
  end
  
  def update
    if ( @state == STATE_PLAY )
      if ( @falling_shape.collide )
        @state = STATE_GAMEOVER
	  else
        @falling_shape.update
	  end

	  @level = @lines_cleared / 10
	  self.caption = "Tetris : #{@lines_cleared} lines"
	else 
	  if ( button_down?(Gosu::KbSpace) )
	    @blocks = []
		@falling_shape = nil
		@level = 0
		@lines_cleared = 0
		spawn_next_shape
		
		@state = STATE_PLAY
	  end
	end
	
	if ( button_down?(Gosu::KbEscape) )
	  close
	end
	@song.play(true)
  end
  
  def draw
    @blocks.each { |block| block.draw }
	@falling_shape.draw
	
	if @state == STATE_GAMEOVER
	   text = Gosu::Image.from_text(self, "Game Over", "Arial", 40)
	   text.draw(width/2 - 90, height/2 - 20, 0, 1, 1)
	end
  end
  
  def button_down(id)
    # Rotate shape when space is pressed
    if ( id == Gosu::KbSpace && @falling_shape != nil )
      @falling_shape.rotation += 1
	  if ( @falling_shape.collide )
	    @falling_shape.rotation -= 1
	  end
	end
  end
  
  def spawn_next_shape
    # Spawn a random shape and add the current falling shape' blocks to the "static" blocks list
    if (@falling_shape != nil )
	  @blocks += @falling_shape.get_blocks 
	end
	 
	generator = Random.new
	shapes = [ShapeI.new(self), ShapeL.new(self), ShapeJ.new(self), ShapeCube.new(self), ShapeZ.new(self), ShapeT.new(self), ShapeS.new(self)]
	shape = generator.rand(0..(shapes.length-1))
    @falling_shape = shapes[shape]
  end
  
  def line_complete(y)
    # Important is that the screen resolution should be divisable by the block_width, otherwise there would be gap
	# If the count of blocks at a line is equal to the max possible blocks for any line - the line is complete
	i = @blocks.count{|item| item.y == y}
	if ( i == width / block_width )
		return true;
	end
	return false;
  end
  
  def delete_lines_of( shape )
    # Go through each block of the shape and check if the lines they are on are complete
    deleted_lines = []
    shape.get_blocks.each do |block|
		if ( line_complete(block.y) )
		   deleted_lines.push(block.y)
		   @blocks = @blocks.delete_if { |item| item.y == block.y }
		end
	end
	
	@lines_cleared += deleted_lines.length
	
	# This applies the standard gravity found in classic Tetris games - all blocks go down by the 
	# amount of lines cleared
	@blocks.each do |block|
	  i = deleted_lines.count{ |y| y > block.y }
	  block.y += i*block_height
	end
	
  end
  
end

# This global prevents creation of the window and start of the simulation when we are doing testing
if ( !$testing )
	window = TetrisGameWindow.new
	window.show
end # Image is loaded only once for all blocks
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
    # Two blocks collide only when they are at the same position, since the world is a grid
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

class Shape
  attr_accessor :rotation
  def initialize(game)
    @game = game
    @last_fall_update = Gosu::milliseconds 
    @last_move_update = Gosu::milliseconds 
	
	@blocks = [Block.new(game), Block.new(game), Block.new(game), Block.new(game) ]

	@x = @y = 0
	@falling = true
	
	# Rotation is done about this block
	@rotation_block = @blocks[1]
	# How many rotations we can do before a full cycle?
	@rotation_cycle = 1
	# Current rotation state
	@rotation = 0
  end
  
  def apply_rotation
    # Each rotation is a 90 degree in the clockwise direction
    if @rotation_block != nil
		(1..@rotation.modulo(@rotation_cycle)).each do |i|
		  @blocks.each do |block|
			old_x = block.x
			old_y = block.y
			block.x = @rotation_block.x + (@rotation_block.y - old_y)
			block.y = @rotation_block.y - (@rotation_block.x - old_x)
		  end
		end
    end
  end
  
  # Note that the following function is defined properly only when the object is unrotated
  # Otherwise the line of symmetry will be misplaced and wrong results will be produced
  def reverse
    # Mirror the shape by the y axis, effectively creating shape counterparts such as 'L' and 'J'
    center = (get_bounds[2] + get_bounds[0]) / 2.0
    @blocks.each do |block|
	  block.x = 2*center - block.x - @game.block_width
	end
  end
  
  def get_bounds
    # Go throug all blocks to find the bounds of this shape
    x_min = []
	y_min = []
	x_max = []
	y_max = []
    @blocks.each do |block| 
	  x_min << block.x
	  y_min << block.y
	  
	  x_max << block.x + block.width
	  y_max << block.y + block.height
	end

	return [x_min.min, y_min.min, x_max.max, y_max.max]
  end
  
  # Updates to movement are done periodically to allow the player time for reaction
  def needs_fall_update?
    if ( @game.button_down?(Gosu::KbDown) )
      updateInterval = 100
	else
	  updateInterval = 500 - @game.level*50
	end
	if ( Gosu::milliseconds - @last_fall_update > updateInterval )
      @last_fall_update = Gosu::milliseconds 
	end
  end
  
  def needs_move_update?
	if ( Gosu::milliseconds - @last_move_update > 100 )
	  @last_move_update = Gosu::milliseconds 
    end
  end
  
  def draw
    get_blocks.each { |block| block.draw }
  end
  
  def update
    if ( @falling ) 
	  # After a movement or gravity update, we check if the moved shape collides with the world.
	  # If it does, we restore its position to the last known good position
	  old_x = @x
	  old_y = @y
	  
	  if needs_fall_update?
		@y = (@y + @game.block_height)
	  end
	  
	  # Important to note is that we do 2 collision checks - once we moved on the x axis and once we moved on the y axis
	  # This way we can determine which of the 2 movements is responisble for the collision and learn on which side of the colliding block
	  # the collision occured.
	  if ( collide )
	    @y = (old_y)
		@falling = false
		@game.spawn_next_shape
		@game.delete_lines_of(self)
	  else  
	    if needs_move_update?
		  if (@game.button_down?(Gosu::KbLeft))
		    @x =  (@x - @game.block_width)
		  end
		  if (@game.button_down?(Gosu::KbRight))
			@x = ( @x + @game.block_width)
		  end
		  
		  if ( collide )
		    @x = (old_x)
		  end 
		end  
	  end
	end
  end
  
  def collide
    get_blocks.each do |block|
	  collision = block.collide_with_other_blocks;
	  if (collision)
	    return true
	  end
    end

    bounds = get_bounds
  
    if ( bounds[3] > @game.height )
	  return true
    end
  
    if ( bounds[2] > @game.width )
	  return true
    end
  
    if ( bounds[0] < 0 )
	  return true
    end	
    return false
  end
  
end

class ShapeI < Shape
  def initialize(game)
    super(game)
	
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
	
	@blocks.each { |block| block.color = 0xffb2ffff }
  end
end

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

class ShapeJ < ShapeL
  def get_blocks
    # Reverse will reverse also the direction of rotation that's applied in apply_rotation
	# This will temporary disable rotation in the super method, so we can handle the rotation here after the reverse
    old_rotation = @rotation
    @rotation = 0  
	
    super
	reverse
	
	@rotation = old_rotation
	apply_rotation
	
	@blocks.each { |block| block.color = 0xff0000ff}
  end
end

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
	
	@blocks.each { |block| block.color = 0xffffff00}
  end
end

class ShapeZ < Shape
  def initialize(game)
    super(game)
	
	@rotation_block = @blocks[1]
	@rotation_cycle = 2
  end
  
  def get_blocks
	@blocks[0].x = @x
	@blocks[1].x = @x + @game.block_width
	@blocks[2].x = @x + @game.block_width
	@blocks[3].x = @x + @game.block_width*2
	@blocks[0].y = @y
  	@blocks[1].y = @y
	@blocks[2].y = @y + @game.block_height
	@blocks[3].y = @y + @game.block_height
	
	apply_rotation
	@blocks.each { |block| block.color = 0xffff0000}
  end
end

class ShapeS < ShapeZ
  def get_blocks
    # Reverse will reverse also the direction of rotation that's applied in apply_rotation
	# This will temporary disable rotation in the super method, so we can handle the rotation here after the reverse
    old_rotation = @rotation
    @rotation = 0  
	
    super
	reverse
	
	@rotation = old_rotation
	apply_rotation
	
	@blocks.each { |block| block.color = 0xff00ff00}
  end
end

class ShapeT < Shape
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
	@blocks.each { |block| block.color = 0xffff00ff}
  end
end

class TetrisGameWindow < Gosu::Window
  attr_accessor :blocks
  attr_reader :block_height, :block_width
  attr_reader :level
  attr_reader :falling_shape
  
  STATE_PLAY = 1
  STATE_GAMEOVER = 2
  
  def initialize
    super(320, 640, false)
	
	@block_width = 32
	@block_height = 32
	
	@blocks = []
	
	@state = STATE_PLAY
	
	spawn_next_shape
	
	@lines_cleared = 0
	@level = 0
	
	self.caption = "Tetris : #{@lines_cleared} lines"
	
    @song = Gosu::Song.new("TetrisB_8bit.ogg")
  end
  
  def update
    if ( @state == STATE_PLAY )
      if ( @falling_shape.collide )
        @state = STATE_GAMEOVER
	  else
        @falling_shape.update
	  end

	  @level = @lines_cleared / 10
	  self.caption = "Tetris : #{@lines_cleared} lines"
	else 
	  if ( button_down?(Gosu::KbSpace) )
	    @blocks = []
		@falling_shape = nil
		@level = 0
		@lines_cleared = 0
		spawn_next_shape
		
		@state = STATE_PLAY
	  end
	end
	
	if ( button_down?(Gosu::KbEscape) )
	  close
	end
	@song.play(true)
  end
  
  def draw
    @blocks.each { |block| block.draw }
	@falling_shape.draw
	
	if @state == STATE_GAMEOVER
	   text = Gosu::Image.from_text(self, "Game Over", "Arial", 40)
	   text.draw(width/2 - 90, height/2 - 20, 0, 1, 1)
	end
  end
  
  def button_down(id)
    # Rotate shape when space is pressed
    if ( id == Gosu::KbSpace && @falling_shape != nil )
      @falling_shape.rotation += 1
	  if ( @falling_shape.collide )
	    @falling_shape.rotation -= 1
	  end
	end
  end
  
  def spawn_next_shape
    # Spawn a random shape and add the current falling shape' blocks to the "static" blocks list
    if (@falling_shape != nil )
	  @blocks += @falling_shape.get_blocks 
	end
	 
	generator = Random.new
	shapes = [ShapeI.new(self), ShapeL.new(self), ShapeJ.new(self), ShapeCube.new(self), ShapeZ.new(self), ShapeT.new(self), ShapeS.new(self)]
	shape = generator.rand(0..(shapes.length-1))
    @falling_shape = shapes[shape]
  end
  
  def line_complete(y)
    # Important is that the screen resolution should be divisable by the block_width, otherwise there would be gap
	# If the count of blocks at a line is equal to the max possible blocks for any line - the line is complete
	i = @blocks.count{|item| item.y == y}
	if ( i == width / block_width )
		return true;
	end
	return false;
  end
  
  def delete_lines_of( shape )
    # Go through each block of the shape and check if the lines they are on are complete
    deleted_lines = []
    shape.get_blocks.each do |block|
		if ( line_complete(block.y) )
		   deleted_lines.push(block.y)
		   @blocks = @blocks.delete_if { |item| item.y == block.y }
		end
	end
	
	@lines_cleared += deleted_lines.length
	
	# This applies the standard gravity found in classic Tetris games - all blocks go down by the 
	# amount of lines cleared
	@blocks.each do |block|
	  i = deleted_lines.count{ |y| y > block.y }
	  block.y += i*block_height
	end
	
  end
  
end

# This global prevents creation of the window and start of the simulation when we are doing testing
if ( !$testing )
	window = TetrisGameWindow.new
	window.show
end