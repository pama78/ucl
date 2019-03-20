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
    #implementace si potom mus� vysta?it s metodami [] a []= za pomoci
    #udr�ov�n� dvou index? ozna?uj�c�ch za?�tek a konec fronty zp?sobem popsan�m na p?edn�ce (jin�mi slovy implementace nesm�
    #pou��vat metody jako << nebo delete_at). V p?�pad? p?epln?n� fronty BooleanArrayQueue dojde k v�jimce t?�dy QueueFullException.
    #P?i obou implementac�ch vyvolejte v�jimku t?�dy QueueEmptyException v p?�pad? operace dequeue na pr�zdn� front?.
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
