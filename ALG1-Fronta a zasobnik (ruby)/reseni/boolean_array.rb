require_relative "index_out_of_bounds_exception"
require_relative "boolean_expected_exception"

class BooleanArray
  attr_reader :length
  attr_reader :used_length

  def initialize(length)
    @length = length
    @used_length = 0
    @inner = Array.new((length - 1) / 8 + 1, 0)
  end

  private

  def get_byte_bit(index)
    return [index / 8, index % 8]
  end

  public

  # get(i)
  def [](index)
    raise IndexOutOfBoundsException.new(index, @length) if (index < 0 || index >= @used_length)
    byte, bit = get_byte_bit(index)
    return ((@inner[byte]) & (1 << bit)) != 0
  end

  # set(i, value)
  # always returns value
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
  # returns index, and nil when value is not found
  def find(value)
    @used_length.times do |i|
      return i if value==self[i]
    end
    return nil
  end

  # iterate(callback)
  # as you have not covered yield in the Ruby course, this
  # is already done -- you can just ignore it
  def eachnew
    @used_length.times do |i|
      # yield self[i]
     # p "Tady je prvek #{prvek}"
      p "Tady je prvek #{i}"
      self[i] += 1
    end
  end

  # iterate(callback)
  def each
    @used_length.times do |i|
      yield self[i]
    end
  end


  # insert(i, value)
  # always returns self
  def insert(index, value)
    raise IndexOutOfBoundsException.new(index, @length) if (index < 0 || index >= @length)
    raise BooleanExpectedException.new(value) unless value.instance_of?(TrueClass) || value.instance_of?(FalseClass)
    #if index != @used_length                  #pokud pridavam nakonec, posouvaci loop se neprovede
    #then
      @used_length.downto(index+1) do |pos|   #pokud neodstranuju posledni, klesam od poctu prvku az ke zmenenemu - pro pripad, kdy se vklada doprostred pole
        self[pos]=self[pos-1]                 #(used_length je o 1 vic nez pocet hodnot, proto pro presunu +1, odzadu, abych neprepsal soucasne hodnoty)
      end
    #end
    self.[]=index,value                       #nastavim hodnotu na pozici
    return self
  end

  # remove(i)
  # returns the removed value
  def delete_at(index)
    raise IndexOutOfBoundsException.new(index, @length) if (index < 0 || index >= @length)
    i=index
      rv=self[i]
      while i != (@used_length-1) do
        self[i]=self[i+1]
        i+=1
      end
    @used_length-=1   #uriznu posledni
    return rv
  end

  # append(value)
  # always returns self
  def <<(value)
    # raises IndexOutOfBoundsException.new(index, @length) if the array is full
    #raise BooleanExpectedException.new(value) if the value is not an instance of TrueClass or FalseClass
    raise IndexOutOfBoundsException.new(@used_length, @length) if (@used_length >= @length)
    raise BooleanExpectedException.new(value) unless value.instance_of?(TrueClass) || value.instance_of?(FalseClass)
    insert(@used_length, value)
    return self
  end

  # prepend(value)
  # always returns self
  def unshift(value)
    # raises IndexOutOfBoundsException.new(index, @length) if the array is full
    # raises BooleanExpectedException.new(value) if the value is not an instance of TrueClass or FalseClass
    raise IndexOutOfBoundsException.new(@used_length, @length) if (@used_length >= @length)
    raise BooleanExpectedException.new(value) unless value.instance_of?(TrueClass) || value.instance_of?(FalseClass)
    insert(0, value)
    return self
  end

  # converts self to a standard Ruby Array
  def to_a
    result = []
    self.each do |item|
      result << item
    end
    return result
  end

end



