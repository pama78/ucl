require "minitest/autorun"
require_relative "boolean_array"

# Contains tests of BooleanArray implementation
class BooleanArrayTest < MiniTest::Test

  def setup
    @x = BooleanArray.new(20)
    @x << true
    @x << true
    @x << false

    @y = BooleanArray.new(3)
  end

  def test_get
    assert_equal true, @x[0]
    assert_equal true, @x[1]
    assert_equal false, @x[2]
    assert_equal [true, true, false], @x.to_a
    assert_raises(IndexOutOfBoundsException) { @x[-1] }
    assert_raises(IndexOutOfBoundsException) { @x[3] }
  end

  def test_set
    @x[1] = false
    @x[2] = true
    assert_equal true, @x[0]
    assert_equal false, @x[1]
    assert_equal true, @x[2]
    assert_equal [true, false, true], @x.to_a
    assert_raises(IndexOutOfBoundsException) { @x[-1] = true }
    assert_raises(IndexOutOfBoundsException) { @x[20] = true }
    assert_raises(BooleanExpectedException) { @x[0] = 1 }
    assert_raises(BooleanExpectedException) { @x[0] = "" }
  end

  def test_find
    assert_equal 0, @x.find(true)
    assert_equal 2, @x.find(false)
    @x[2] = true
    assert_nil @x.find(false)
  end

  def test_insert
    assert_equal [true, true, true, false], @x.insert(0, true).to_a
    assert_equal [false, true, true, true, false], @x.insert(0, false).to_a
    assert_equal [false, true, true, true, false, false], @x.insert(5, false).to_a
    assert_equal [false, true, true, true, false, false, true], @x.insert(6, true).to_a
    assert_equal [false, true, false, true, true, false, false, true], @x.insert(2, false).to_a
    assert_equal [false, true, true, false, true, true, false, false, true], @x.insert(1, true).to_a
    assert_raises(IndexOutOfBoundsException) { @x.insert(-1, true) }
    assert_raises(IndexOutOfBoundsException) { @x.insert(20, true) }
    assert_raises(BooleanExpectedException) { @x.insert(0, 1) }
    assert_raises(BooleanExpectedException) { @x.insert(0, "") }

    @y.insert(0, true)
    @y.insert(0, true)
    @y.insert(0, true)
    assert_raises(IndexOutOfBoundsException) { @y.insert(0, true) }
  end

  def test_delete_at
    @x << false
    @x << true
    assert_equal true, @x.delete_at(0)
    assert_equal [true, false, false, true], @x.to_a
    assert_equal false, @x.delete_at(1)
    assert_equal [true, false, true], @x.to_a
    assert_equal true, @x.delete_at(2)
    assert_equal [true, false], @x.to_a
    assert_raises(IndexOutOfBoundsException) { @x.delete_at(-1) }
    assert_raises(IndexOutOfBoundsException) { @x.delete_at(20) }

    @y << true
    @y << true
    @y << true
    @y.delete_at(0)
    @y.delete_at(0)
    @y.delete_at(0)
    assert_raises(IndexOutOfBoundsException) { @y.delete_at(0) }
  end

  def test_append
    assert_equal [true, true, false, false], (@x << false).to_a
    assert_equal [true, true, false, false, true], (@x << true).to_a
    assert_raises(BooleanExpectedException) { @x << 1 }
    assert_raises(BooleanExpectedException) { @x << "" }

    @y << true
    @y << true
    @y << true
    assert_raises(IndexOutOfBoundsException) { @y << true }
  end

  def test_unshift
    assert_equal [false, true, true, false], @x.unshift(false).to_a
    assert_equal [true, false, true, true, false], @x.unshift(true).to_a
    assert_raises(BooleanExpectedException) { @x.unshift(1) }
    assert_raises(BooleanExpectedException) { @x.unshift("") }

    @y.unshift(true)
    @y.unshift(true)
    @y.unshift(true)
    assert_raises(IndexOutOfBoundsException) {@y.unshift(true) }
  end

end
