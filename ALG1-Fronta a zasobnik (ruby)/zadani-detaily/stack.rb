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
    # TODO
  end

  def push(x)
    # returns self
    # TODO
  end

  def pop
    # returns the removed value
    # raises StackEmptyException if stack is empty
    # TODO
  end
end

class BooleanArrayStack
  def initialize(size)
    # TODO
  end

  def push(x)
    # returns self
    # raises StackFullException if stack is already full
    # TODO
  end

  def pop
    # returns the removed value
    # raises StackEmptyException if stack is empty
    # TODO
  end
end
