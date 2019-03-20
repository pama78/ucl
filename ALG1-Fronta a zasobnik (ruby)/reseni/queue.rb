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
    @slq = SinglyLinkedList.new
    end

  def queue(x)
   return  @slq << x
  end

  def dequeue
    # returns the removed value
    raise QueueEmptyException.new(@slq.length) if (@slq.length == 0 )
    return @slq.delete_at(0)
  end
end

class BooleanArrayQueue
  def initialize(size)
    #implementace si potom musí vysta?it s metodami [] a []= za pomoci
    #udržování dvou index? ozna?ujících za?átek a konec fronty zp?sobem popsaným na p?ednášce (jinými slovy implementace nesmí
    #používat metody jako << nebo delete_at). V p?ípad? p?epln?ní fronty BooleanArrayQueue dojde k výjimce t?ídy QueueFullException.
    #P?i obou implementacích vyvolejte výjimku t?ídy QueueEmptyException v p?ípad? operace dequeue na prázdné front?.
    @baq = BooleanArray.new(size)
    @first=0
    @queue_size=0     #last dopocitavam, protoze se s pomoci queue_size pak lepe rozlisi plne pole a ruzne krajni pripady pri rotaci fronty
    @array_size=size
  end

  def queue(x)
    # returns self
    raise QueueFullException.new("@queue_size") if ( @array_size == @queue_size )
    if @queue_size == 0                                #posledni element nechci posouvat vpred
      last=@first
      else
       last=@first+@queue_size
    end
    @queue_size+=1
    last-=@array_size if last >=  @array_size          #po prekroceni velikosti, recykluji
    #p "ENQ_a: last = #{last} = #{x} array_size= #{@array_size} queue size=#{@queue_size}"
    @baq.[]=last,x
    return self
  end

  def dequeue
    # returns the removed value
    # TODO
    raise QueueEmptyException.new("@queue_size") if ( @queue_size == 0 )
    cur_val=@baq[@first]
    @queue_size-=1
    @first+=1 if ( @queue_size != 0 )             #posledni element by nemel zpusobit zvyseni prvniho ukazatele
    @first-=@array_size if @first >= @array_size  #po prekroceni hranice, navrat k 0
    #p "DEQ_b: queue size reduce to #{@queue_size} new first=#{@first} cur_val=#{cur_val}"
    return cur_val
  end
end
