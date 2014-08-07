[
  'rubygems',
  'gosu',
].each(&method(:require))

[
  'block',
  'shape',
  'shape_cube',
  'shape_i', 
  'shape_j',
  'shape_l', 
  'shape_s', 
  'shape_t', 
  'shape_z'
].each{ |file| require_relative File.expand_path("#{file}.rb") }

class TetrisGameWindow < Gosu::Window
  attr_accessor :blocks
  attr_reader :block_height, :block_width
  attr_reader :level
  attr_reader :falling_shape

  STATE_PLAY = 1
  STATE_GAMEOVER = 2
  DEFAULT_VALUE = 0
  MAX_LINES = 10

  def initialize
    super(320, 640, false)

    @block_width = 32
    @block_height = 32
    @blocks = []
    @state = STATE_PLAY
    spawn_next_shape
    @song = Gosu::Song.new('media/bongz.mp3')
    @lines_cleared = DEFAULT_VALUE
    @level = DEFAULT_VALUE
    self.caption = "Tetris : #{@lines_cleared} lines"
  end

  def update
    if (@state == STATE_PLAY)
      if (@falling_shape.collide)
        @state = STATE_GAMEOVER
      else
        @falling_shape.update
      end

      @level = @lines_cleared / 10
      self.caption = "Tetris : #{@lines_cleared} lines"
    else
      if (button_down?(Gosu::KbSpace))
        @blocks = []
        @falling_shape = nil
        @level = 0
        @lines_cleared = 0
        spawn_next_shape

        @state = STATE_PLAY
      end
    end

    if (button_down?(Gosu::KbEscape))
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
    if (id == Gosu::KbSpace && @falling_shape != nil)
      @falling_shape.rotation += 1
      if (@falling_shape.collide)
        @falling_shape.rotation -= 1
      end
    end
  end

  def spawn_next_shape
    if (@falling_shape != nil)
      @blocks += @falling_shape.get_blocks
    end

    generator = Random.new
    shapes = generate_shapes
    shape = generator.rand(0..(shapes.length-1))
    @falling_shape = shapes[shape]
  end

  def generate_shapes
    shapes = []
    shape_types = ['Cube', 'I', 'J', 'L', 'T','S','Z']
    shape_types.each { |shape| shapes << Kernel.const_get("Shape#{shape}").new(self) }
    shapes
  end

  def line_complete(y)
    i = @blocks.count { |item| item.y == y }
    if (i == width / block_width)
      return true;
    end
    return false;
  end

  def delete_lines_of(shape)
    deleted_lines = []
    if (line_complete(14))
 				deleted_lines.push(14)
      @blocks = @blocks.delete_if { |item| item.y == block.y }
    end
     @lines_cleared += deleted_lines.length

  	@blocks.each do |block|
    	i = deleted_lines.count { |y| y > block.y }
    	block.y += i*block_height
  	end
  end
end

if (!$testing)
  window = TetrisGameWindow.new
  window.show
end
