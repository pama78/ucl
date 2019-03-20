require_relative "boolean_array"
require_relative "singly_linked_list"

class QueueEmptyException < Exception
  def initialize(queue)
    @queue = queue
  end

  def message
    "Queue is empty"
  end
end

class QueueFullException < Exception
  def initialize(queue)
    @queue = queue
  end

  def message
    "Queue is full"
  end
end

class SinglyListQueue
  def initialize
    # TODO
  end

  def queue(x)
    # returns self
    # TODO
  end

  def dequeue
    # returns the removed value
    # raises QueueEmptyException if queue is empty
    # TODO
  end
end

class BooleanArrayQueue
  def initialize(size)
    # TODO
  end

  def queue(x)
    # returns self
    # raises QueueFullException if queue is already full
    # TODO
  end

  def dequeue
    # returns the removed value
    # raises QueueEmptyException if queue is empty
    # TODO
  end
end
