require_relative "index_out_of_bounds_exception"
require_relative "boolean_expected_exception"

class BooleanArray
  attr_reader :length
  attr_reader :used_length

  # constructor (already done)
  def initialize(length)
    @length = length
    @used_length = 0
    @inner = Array.new((length - 1) / 8 + 1, 0)
  end

  private

  # returns indices of the greater/outer byte and smaller/inner bit (already done)
  def get_byte_bit(index)
    return [index / 8, index % 8]
  end

  public

  # get(i)
  # returns bit (true/false value) at given outer index (already done)
  def [](index)
    raise IndexOutOfBoundsException.new(index, @length) if (index < 0 || index >= @used_length)
    byte, bit = get_byte_bit(index)
    return ((@inner[byte]) & (1 << bit)) != 0
  end

  # set(i, value)
  # sets bit (true/false value) at given outer index (already done)
  # always returns value (already done)
  def []=(index, value)
    raise IndexOutOfBoundsException.new(index, @length) if (index < 0 || index >= @length)
    raise BooleanExpectedException.new(value) unless value.instance_of?(TrueClass) || value.instance_of?(FalseClass)
    byte, bit = get_byte_bit(index)
    if value
      @inner[byte] |= 1 << bit
    else
      @inner[byte] &= 255 - (1 << bit)
    end
    @used_length = index + 1 if index >= @used_length
    return value
  end

  # find(value)
  # returns (outer) index of the first found value, or nil when value is not found
  def find(value)
    # TODO
  end

  # iterate(callback)
  # as you have not covered 'yield' in the Ruby course, this is already done
  def each
    @used_length.times do |i|
      yield self[i]
    end
  end

  # insert(i, value)
  # always returns self
  def insert(index, value)
    # raises IndexOutOfBoundsException.new(index, @length) if the index is out of the correct bounds [0, @length), or if insert into the full array
    # raises BooleanExpectedException.new(value) if the value is not an instance of TrueClass or FalseClass
    # TODO
  end

  # remove(i)
  # returns the removed value
  def delete_at(index)
    # raises IndexOutOfBoundsException.new(index, @length) if the index is out of the correct bounds [0, @used_length)
    # TODO
  end

  # append(value)
  # always returns self
  def <<(value)
    # raises IndexOutOfBoundsException.new(index, @length) if the array is full
    # raises BooleanExpectedException.new(value) if the value is not an instance of TrueClass or FalseClass
    # TODO
  end

  # prepend(value)
  # always returns self
  def unshift(value)
    # raises IndexOutOfBoundsException.new(index, @length) if the array is full
    # raises BooleanExpectedException.new(value) if the value is not an instance of TrueClass or FalseClass
    # TODO
  end

  # converts self to a standard Ruby Array (already done)
  def to_a
    result = []
    self.each do |item|
      result << item
    end
    return result
  end

end
