class Vertex
  attr_reader :osm_id, :lat, :lon, :degree, :vertex_nr, :degree, :neighbours, :edges, :is_valid, :mst_head, :mst_tail, :mst_next

  def initialize(osm_id, lat, lon)
    @osm_id = osm_id.to_i
    @lat    = lat.to_f
    @lon    = lon.to_f
    @degree = 0
    @vertex_nr = -1
    @neighbours = []  #DU2
    @edges = []
    @is_valid = true
    @mst_head = 0  #for linked lists implementation of the selected nodes for minimum span tree
    @mst_tail = 0  #for linked lists implementation of the selected nodes for minimum span tree
    @mst_next = -1
  end

  def set_number(i)
    @vertex_nr = i
  end

  def invalidate()
    @is_valid=false
  end

  def increment_degree()
    @degree=@degree+1
  end

  def disconnect_neighbour(n)
    @neighbours.delete(n)
    #   @degree=@degree-1
  end

  def disconnect_edge(e)
    @edges.delete(e)
  end

  def add_edge(e)
    @edges <<e
  end

  def connect_neighbour(n)
    @neighbours<< n
  end

  ##difference between to gps coordinates - downloaded from Stack overflow
  #http://stackoverflow.com/questions/12966638/how-to-calculate-the-distance-between-two-gps-coordinates-without-using-google-m
  def get_distance(nd2)
    lat1=@lat
    lon1=@lon
    lat2=nd2.lat
    lon2=nd2.lon
    rad_per_deg = Math::PI / 180
    rm = 6371000 # Earth radius in meters
    lat1_rad, lat2_rad = lat1 * rad_per_deg, lat2 * rad_per_deg
    lon1_rad, lon2_rad = lon1 * rad_per_deg, lon2 * rad_per_deg
    a = Math.sin((lat2_rad - lat1_rad) / 2) ** 2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin((lon2_rad - lon1_rad) / 2) ** 2
    c = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1 - a))
    (rm * c).round(2) # Delta in meters
  end

  ##DU2, methods supporting mst solution
  def set_node_head_mst(head_osm)
    @mst_head=head_osm
  end

  def set_node_tail_mst(tail_osm)
    @mst_tail=tail_osm
  end

  def set_next_node_mst(next_osm)
    @mst_next=next_osm
  end
end
