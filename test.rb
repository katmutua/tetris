$testing = true

require "./tetris.rb"
require "test/unit"
 
class TestTetris < Test::Unit::TestCase
  def setup
    @game = TetrisGameWindow.new
	@w = @game.block_width
	@h = @game.block_height
  end
  
  def test_shapes_construction
    assert_equal(4, ShapeI.new(@game).get_blocks.length, "ShapeI must be constructed of 4 blocks")
	assert_equal(4, ShapeT.new(@game).get_blocks.length, "ShapeT must be constructed of 4 blocks")
	assert_equal(4, ShapeJ.new(@game).get_blocks.length, "ShapeJ must be constructed of 4 blocks")
	assert_equal(4, ShapeZ.new(@game).get_blocks.length, "ShapeZ must be constructed of 4 blocks")
	assert_equal(4, ShapeCube.new(@game).get_blocks.length, "ShapeO must be constructed of 4 blocks")
	assert_equal(4, ShapeS.new(@game).get_blocks.length, "ShapeS must be constructed of 4 blocks")
	assert_equal(4, ShapeL.new(@game).get_blocks.length, "ShapeL must be constructed of 4 blocks")
	
	assert_not_equal(nil, @game.falling_shape, "Falling shape shoudn't be nil")
  end
  
  def test_shapes_rotation
    shape = ShapeI.new(@game)
	shape.rotation = 1
	assert(shape_contain_block(shape, -2*@w, @h), "Rotation of I failed!")
	assert(shape_contain_block(shape, -@w, @h), "Rotation of I failed!")
	assert(shape_contain_block(shape, 0, @h), "Rotation of I failed!")
	assert(shape_contain_block(shape, @w, @h), "Rotation of I failed!")
	
    shape = ShapeL.new(@game)
	shape.rotation = 2
	assert(shape_contain_block(shape, -@w, 0), "Rotation of L failed!")
	assert(shape_contain_block(shape, 0, 0), "Rotation of L failed!")
	assert(shape_contain_block(shape, 0, @h), "Rotation of L failed!")
	assert(shape_contain_block(shape, 0, 2*@h), "Rotation of L failed!")
	
    shape = ShapeJ.new(@game)
	shape.rotation = 2
	assert(shape_contain_block(shape, 2*@w, 0), "Rotation of J failed!")
	assert(shape_contain_block(shape, @w, 0), "Rotation of J failed!")
	assert(shape_contain_block(shape, @w, @h), "Rotation of J failed!")
	assert(shape_contain_block(shape, @w, 2*@h), "Rotation of J failed!")
	
	shape = ShapeZ.new(@game)
	shape.rotation = 2
	assert(shape_contain_block(shape, 0, 0), "Rotation of Z failed!")
	assert(shape_contain_block(shape, @w, 0), "Rotation of Z failed!")
	assert(shape_contain_block(shape, @w, @h), "Rotation of Z failed!")
	assert(shape_contain_block(shape, 2*@w, @h), "Rotation of Z failed!")
	
	shape = ShapeS.new(@game)
	shape.rotation = 1
	assert(shape_contain_block(shape, 0, -@h), "Rotation of S failed!")
	assert(shape_contain_block(shape, 0, 0), "Rotation of S failed!")
	assert(shape_contain_block(shape, @w, 0), "Rotation of S failed!")
	assert(shape_contain_block(shape, @w, @h), "Rotation of S failed!")
	
	shape = ShapeT.new(@game)
	shape.rotation = 3
	assert(shape_contain_block(shape, @w, -@h), "Rotation of T failed!")
	assert(shape_contain_block(shape, @w, 0), "Rotation of T failed!")
	assert(shape_contain_block(shape, 2*@w, 0), "Rotation of T failed!")
	assert(shape_contain_block(shape, @w, @h), "Rotation of T failed!")
  end

  def test_block_collision
    block1   = Block.new(@game)
	block2   = Block.new(@game)
	block2.x = @w
	block2.y = 0
	
	assert_equal(false, block1.collide(block2), "Blocks should not collide")
	
	block2.x = 0
	block2.y = 0
	
	assert_equal(true, block1.collide(block2), "Blocks should collide")
  end  
  
  def test_line_complete
    (0.. (@game.width/@w - 1)).each do |i|
      add_block(i*@w, 0)
	end
	
	(0.. (@game.width/@w - 2)).each do |i|
      add_block(i*@w, @h)
	end
	
	assert_equal(true, @game.line_complete(0), "Line should be complete")
	assert_equal(false, @game.line_complete(@h), "Line should not be complete")
	
	shapeI = ShapeI.new(@game)
	@game.delete_lines_of(shapeI)
	
	(0.. (@game.width/@w - 1)).each do |i|
      assert_equal(false, contain_block(@game.blocks, i*@w, 0), "Line 0 should be deleted ")
	end
	
  end
  
  def add_block(x,y)
    block = Block.new(@game)
	block.x = x
	block.y = y
    @game.blocks << block
  end
  
  def contain_block(array, x, y)
    array.index { |block| block.x == x && block.y == y } != nil
  end
  
  def shape_contain_block(shape, x, y)
    contain_block(shape.get_blocks,x, y)
  end
 
end