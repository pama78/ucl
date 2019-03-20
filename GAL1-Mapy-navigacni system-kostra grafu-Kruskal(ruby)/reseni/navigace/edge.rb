class Edge
  #(last_osm_id, nd_osm_id, last_internal_number, v_nr, name, max_speed, is_oneway)
  attr_reader :osm_from, :osm_to, :v1_nr, :v2_nr, :name, :maxspeed, :is_oneway, :length, :edge_nr, :is_valid, :time_distance, :is_bold

  def initialize(osm_from, osm_to, v1_nr, v2_nr, name, max_speed, is_oneway, time_distance)
    @osm_from   = osm_from.to_i
    @osm_to     = osm_to.to_i
    @v1_nr      = v1_nr.to_i         # internal node's number of the first vertex
    @v2_nr      = v2_nr.to_i         # internal node's number of the second vertex
    @name       = name
    @maxspeed   = max_speed.to_i
    @is_oneway  = is_oneway
    @length     = 0
    @edge_nr    = -1
    @is_valid   = true
    @time_distance   = time_distance
    @is_bold     = false
  end

  def set_number(i)
    @edge_nr = i
  end

  def set_bold()
    @is_bold=true
  end

  def invalidate()
    @is_valid=false
  end

end
