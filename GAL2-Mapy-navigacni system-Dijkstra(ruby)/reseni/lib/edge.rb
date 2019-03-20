# Class representing edge of a graph
class Edge
  # Staring vertex of an edge
  attr_reader :v1
  # Target vertex of an edge
  attr_reader :v2
  # Maximal speed on this edge
  attr_reader :max_speed
  # Indicator of on direction edge - i.e. can be passed only from +v1+ to +v2+
  attr_reader :one_way

  # create instance of +self+ by simple storing of all parameters
  def initialize(v1, v2, max_speed, one_way)
    @v1 = v1
    @v2 = v2
    @max_speed = max_speed
    @one_way = one_way
  end

end

