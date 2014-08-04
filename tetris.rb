[
  'rubygems',
  'gosu',
].each(&method(:require))

require_relative 'shape'
require_relative 'shape_i'
require_relative 'block'
require_relative 'shape_l'
require_relative 'shape_j'
require_relative 'shape_t'
require_relative 'shape_s'
require_relative 'shape_z'
require_relative 'shape_cube'

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

    @song = Gosu::Song.new("bongz.mp3")
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
    shapes = [ShapeI.new(self), ShapeL.new(self), ShapeJ.new(self), ShapeCube.new(self), ShapeZ.new(self), ShapeT.new(self), ShapeS.new(self)]
    shape = generator.rand(0..(shapes.length-1))
    @falling_shape = shapes[shape]
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
    if (line_complete(block.y))
 				deleted_lines.push(block.y)
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
