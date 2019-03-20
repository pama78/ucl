require_relative "boolean_array"
require_relative "singly_linked_list"

class StackEmptyException < Exception
  def initialize(stack)
    @stack = stack
  end

  def message
    "Stack is empty"
  end
end

class StackFullException < Exception
  def initialize(stack)
    @stack = stack
  end

  def message
    "Stack is full"
  end
end

class SinglyListStack
  def initialize
    @sls = SinglyLinkedList.new
  end

  def push(x)
    # returns self
    #@sls.unshift(x)
    #return self
    return  @sls.unshift(x)  #unshift vraci self
   end

  def pop
    # returns the removed value
   raise StackEmptyException.new(@sls.length) if (@sls.length == 0 )
     #cur=@sls.delete_at(0)
     #return cur
     return @sls.delete_at(0)
  end
end


class BooleanArrayStack
  def initialize(size)
     @bas = BooleanArray.new(size)
  end

  def push(x)
    raise StackFullException.new(@bas.length) if (@bas.used_length == @bas.length )
    # returns self
    # @bas.<<(x)
    # return self  (<< taky vraci self)
    return @bas.<<(x)
  end

  def pop
    # returns the removed value
    raise StackEmptyException.new(@bas.length) if (@bas.used_length == 0 )
    #cur=@bas.delete_at(@bas.used_length-1)
    #return cur (delete_at taky vraci smazany item)
    return @bas.delete_at(@bas.used_length-1)
  end
end
