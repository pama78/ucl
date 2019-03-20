# Class representing visual representation of edge
#require_relative 'constants';  ##TBD nejak to nejde. konstanty chci vystrcit do souboru (pak vypnout duplikovanou inicializaci nasledujicch 4 konstant
TEMPORARY=1
PERMANENT=2
EMPTY=-1
INFINITY=999999

class VisualEdge
  # Starting +VisualVertex+ of this visual edge
  attr_reader :v1
  # Target +VisualVertex+ of this visual edge
  attr_reader :v2
  # Corresponding edge in the graph
  attr_reader :edge
  # Boolean value given directness
  attr_accessor :directed
  # Boolean value emphasize character - drawn differently on output (TODO)
  attr_accessor :emphesized
  attr_accessor :edge
  attr_accessor :distance
  attr_reader   :name
  attr_accessor :hidden  #workaround, to hide helping pseudo nodes (quick and dirty, later to use directed attribute)


  # create instance of +self+ by simple storing of all parameters
  def initialize(edge, v1, v2)
  	@edge = edge  ##child (orignial Edge, it is first parameter)
    @v1 = v1
    @v2 = v2

   #each use increase degree, later it will help to find ofphans and junctions
    @v1.increment_degree
    @v2.increment_degree

    #store on each vertex his neighbours and related edges - to fasten the finding connected trees and
    # and for easier deleting of the disconneced subtrees/graph componets
    @v1.add_neighbour(@v2.get_id, self)
    @v2.add_neighbour(@v1.get_id, self)
    #@emphesized = false
    @hidden = false

  end

  def get_edge_id
    return @edge
  end

  def get_visual_edge_id
    return object_id
  end

 def calculate_and_store_length
   @distance = get_distance(@v1.lat.to_f, @v1.lon.to_f, @v2.lat.to_f, @v2.lon.to_f)
 end

  def set_edge_name(edge_name)
    @name = "#{edge_name} (#{edge.max_speed} km/h)";
  end

 def set_emphesized(i_emp)
    @emphesized = i_emp
  end


end

