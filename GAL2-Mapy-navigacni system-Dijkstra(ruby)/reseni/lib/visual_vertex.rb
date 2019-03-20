# Class representing visual representation of a vertex.

class VisualVertex
  # ID of +self+ as well as +vertex+
  attr_reader :id
  # Corresponding vertex
  attr_reader :vertex
  # Lattitude of visual vertex
  attr_reader :lat
  # Longitute of visual vertex
  attr_reader :lon
  # X-axis position of +self+
  attr_reader :x
  # Y-axis position of +self+
  attr_reader :y
  attr_reader :degree  #each use of vertex will increase its degree
  attr_reader :neighbours #each vertex remembers his neighbours (for easier cleaning)
  attr_reader :neighbour_edges #each vertex remembers his neighbour_edges (for easier cleaning)

  # Boolean value emphasize character - drawn differently on output
  attr_reader :emphesized
 # attr_reader :emphesized_big

  attr_accessor :predecessor
  #attr_accessor :predecessor_edge

  attr_accessor :path_length
  attr_accessor :status

  # create instance of +self+ by simple storing of all parameters
  def initialize(id, vertex, lat, lon, x, y)
    @id = id
    @vertex = vertex
    @lat = lat
    @lon = lon
    @x = x
    @y = y
    @degree = 0
    @neighbours = Set[]
    @neighbour_edges = Set[]
    @emphesized = 0    #0=not, 1=small red, 2=big red (start-stop)
    #Dijkstra related:
    @status = TEMPORARY
    #@predecessor_edge = nil
    @predecessor = EMPTY
    @path_length = INFINITY
  end

  def set_permanent()
    status=PERMANENT
  end

  def set_path_length(iLength)
    path_length=iLength
  end
  #Dijsktra end

  #for determining nodes with weight 2 or 0, to be removed
  def increment_degree
    @degree += 1
  end

  def print_degree
    return @degree
  end

  def add_neighbour(nb_vertex, nb_edge)
    @neighbours << nb_vertex
    @neighbour_edges << nb_edge
  end

  def get_neighbours
    return @neighbours
  end

  def get_neighbour_edges
    return @neighbour_edges
  end

  def get_id
    return @id
  end

  def get_lat
    return @lat
  end

  def get_lon
    return @lon
  end

  def set_emphesized(i_emp)
    @emphesized = i_emp
  end

end

