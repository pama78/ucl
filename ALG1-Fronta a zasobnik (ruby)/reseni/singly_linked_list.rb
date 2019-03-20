require_relative "index_out_of_bounds_exception"
require_relative "wrong_list_exception"

class SinglyLinkedListItem
  attr_accessor :object, :next
  attr_reader :list
  def initialize(object, list)
    @object = object
    @list = list
  end
end

class SinglyLinkedList
  attr_reader :length

  def initialize
    @length = 0
    @head = nil
    @tail = nil
  end

  private

  # get_item(i)
  # returns the SinglyLinkedListItem at given index (similar to get_i, just not return item.value)
  def get_item(index)
    raise IndexOutOfBoundsException.new(index, @length) if (index < 0 || index >= @length)
    item = @head
    (index).times do
      item = item.next
      #p index
    end
    return item
  end


  public

  # get(i)
  # returns the value
  def [](index)
    raise IndexOutOfBoundsException.new(index, @length) if (index < 0 || index >= @length)
    item=get_item(index)  #loop in ext method
    return item.object
  end

  # set(i, value)
  # always returns value
  # if (index == length) is used, new item is inserted at the end
  def []=(index, object)
    raise IndexOutOfBoundsException.new(index, @length) if (index < 0 || index >= @length)
    item=get_item(index)  #do loop in ext method
    item.object = object
    return object
  end

  # find(value)
  # returns the first list item, or nil if value is not found
 def find(object)
    return nil if @length == 0
    item = @head
    while item != nil do
      if item.object == object
        return item
      end
      item=item.next if item != nil
    end
    return nil
  end


  # iterate(callback)
  # as you have not covered yield in the Ruby course, this
  # is already done -- you can just ignore it
  def each
    if @length > 0
      item = @head
      begin
        yield item.object
        item = item.next
      end until item.nil?
    end
  end

  # insert_before(item, value)
  # returns the new list item
      def insert_before(item, object)
        raise WrongListException.new(item, self) if (item == nil || item.list !=  self)
        if item == @head
          self.unshift(object)
        else
          new_item = SinglyLinkedListItem.new(object, self)
          cur_item = @head
          while cur_item.next != item
            cur_item = cur_item.next
          end
          cur_item.next = new_item
          new_item.next = item
          @length += 1
        end
        return new_item
      end

  # insert_after(item, value)
  # returns the new list item
  def insert_after(item, object)
    raise WrongListException.new(item, self) if (item == nil || item.list !=  self)
    if item == @tail
      then
          self << object
        else
          insert_before(item.next, object)
   end
   return object
  end

  # insert(i, value)
  # always returns self
  def insert(index, object)
    raise IndexOutOfBoundsException.new(index, @length) if (index < 0 || index > @length)
    if index < @length
      then
        insert_before(get_item(index),object)
    else
      self << object #put to the end
    end
    return self
end

def remove_item(item)
  raise WrongListException.new(item, self) if (item == nil || item.list !=  self)
  if @head==item
    @head=@head.next
  else
    next_item=item.next
    cur_item = @head
    while cur_item.next != item
      cur_item = cur_item.next
    end
    cur_item.next = next_item
  end
  #destroy item done by garbage collector
  item_val=item.object
  @length -= 1
  return item_val
end


  # remove(i)
  # returns the removed value
def delete_at(index)
    raise IndexOutOfBoundsException.new(index, @length) if (index < 0 || index >= @length )
    item=get_item(index)
    item_val=item.object
    remove_item(item)
    return item_val
end


  # append(value)
  # always returns self
  def <<(object)
    item = SinglyLinkedListItem.new(object, self)
    if @head == nil
      @head = item
    else
      #last_item=get_item(@length-1) #revize1: nahrazeno dalsi radkou, zpusobovalo narocnost n^2
      last_item=@tail
      last_item.next=item
    end
    @tail = item
    @length += 1
    return self
  end

  # prepend(value)
  # always returns self
def unshift(object)
  item = SinglyLinkedListItem.new(object, self)
  if @head == nil
    @head = item
    @tail = item
  else
    item.next = @head
    @head = item
    end
  @length += 1
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
