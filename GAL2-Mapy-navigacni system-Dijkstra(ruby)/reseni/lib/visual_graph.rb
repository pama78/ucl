require 'ruby-graphviz'
require_relative 'visual_edge'
require_relative 'visual_vertex'
# rubocop:disable all

# Visual graph storing representation of graph for plotting.
class VisualGraph
  # Instances of +VisualVertex+ classes
  attr_reader :visual_vertices
  # Instances of +VisualEdge+ classes
  attr_reader :visual_edges
  # Corresponding +Graph+ Class
  attr_reader :graph
  # Scale for printing to output needed for GraphViz
  attr_reader :scale

  # Create instance of +self+ by simple storing of all given parameters.
  def initialize(graph, visual_vertices, visual_edges, bounds)
    @graph = graph
    @visual_vertices = visual_vertices
    @visual_edges = visual_edges
    @bounds = bounds
    @scale = ([bounds[:maxlon].to_f - bounds[:minlon].to_f, bounds[:maxlat].to_f - bounds[:minlat].to_f].min).abs / 10.0
  end

  # Export +self+ into Graphviz file given by +export_filename+.
  def export_graphviz(export_filename)
    puts "  -output map file: #{export_filename}"
    # create GraphViz object from ruby-graphviz package
    graph_viz_output = GraphViz.new(:G,
                                    use: :neato,
                                    truecolor: true,
                                    inputscale: @scale,
                                    margin: 0,
                                    bb: "#{@bounds[:minlon]},#{@bounds[:minlat]},
                                  		    #{@bounds[:maxlon]},#{@bounds[:maxlat]}",
                                    outputorder: :nodesfirst)

    # append all vertices
    @visual_vertices.each {|k, v|
      style = "filled"
      fixedsize = "true"
      if (v.emphesized == 2)
        shape = "circle"
        fillcolor = "yellow"
      elsif(v.emphesized == 1)
        shape = "point"
        fillcolor = "red"
      else
        shape = "point"
        fillcolor = "black"
      end

      graph_viz_output.add_nodes(
          v.id, :shape => shape,
          :comment => "#{v.lat},#{v.lon}!",
          :pos => "#{v.y},#{v.x}!",
          :style => style,
          :fillcolor => fillcolor,
          :fixedsize => fixedsize
      )
    }

    #append all edges
    @visual_edges.each {|edge|
      #orig: graph_viz_output.add_edges( edge.v1.id, edge.v2.id, 'arrowhead' => 'none' )

      if (edge.hidden == true) #technical two way roads - hide the helping edge (so it is not on output)
          next
      end

      #set defaults
      edge_arrowsize=0.4; edge_color = "black"; edge_label = ""; edge_fontsize = 8; edge_arrowhead = "none";  edge_penwidth = 1

      if (edge.emphesized == 1)  #show path, for it show meters, and ids for all vertices
        edge_label = "#{edge.name} [#{edge.distance}m, #{edge.v1.id}->#{edge.v2.id} ]"
        edge_color = "red"
        edge_arrowhead = "normal"
        edge_penwidth = 3
      else
        #not on the way, smaller font, black
          edge_label = "#{edge.name} [#{edge.v1.id}->#{edge.v2.id}]"
          edge_fontsize = 6
          if (edge.edge.one_way == "true")                 #for oneway show arrows, for the other dont
            edge_arrowhead = "normal"
          end
      end

      graph_viz_output.add_edges(edge.v1.id, edge.v2.id,
                                 'arrowhead' => edge_arrowhead,
                                 'color' => edge_color,
                                 'label' => edge_label,
                                 'fontsize' => edge_fontsize,
                                  'arrowsize' => edge_arrowsize,
                                  'penwidth' => edge_penwidth)
    }

    # # append all edges - original method
    # @visual_edges.each { |edge|
    #   graph_viz_output.add_edges( edge.v1.id, edge.v2.id, 'arrowhead' => 'none' )
    # }


    # export to a given format
    format_sym = export_filename.slice(export_filename.rindex('.') + 1, export_filename.size).to_sym
    graph_viz_output.output(format_sym => export_filename)
  end

  def show_nodes
    puts "Printing all vertexes and its' ID, latitude and longitude"
    puts "in following format ID: latitude, longitude"
    @visual_vertices.each do |vertex|
      puts "#{vertex[1].id}: #{vertex[1].lat}, #{vertex[1].lon}"
    end
    puts "All vertexes printed out."
  end

  def show_nodes_with_ids(start_id, stop_id)
    puts "  -printing selected vertices and its' ID, latitude and longitude (ID: latitude, longitude)"
    starting_vertex = @visual_vertices[start_id]
    ending_vertex = @visual_vertices[stop_id]

    if starting_vertex == nil
      puts "  -user data entry error: starting vertex id #{start_id} not found on the map. The start vertex is not emphasized on the map."
    else
      puts "  -found starting vertex: #{starting_vertex.id} - lat/lon #{starting_vertex.lat}/#{starting_vertex.lon}"
      starting_vertex.set_emphesized(2)
    end

    if  ending_vertex == nil
      puts "  -user data entry error: ending vertex id #{stop_id} not found on the map. The end vertex is not emphasized on the map."
    else
      puts "  -found ending vertex:   #{ending_vertex.id} - lat/lon #{ending_vertex.lat}/#{ending_vertex.lon}"
      ending_vertex.set_emphesized(2)
    end

    if ( ending_vertex != nil and starting_vertex != nil )
      puts "  -hint- to navigate call: --load #{$map_file} --midist  #{starting_vertex.lat} #{starting_vertex.lon} #{ending_vertex.lat} #{ending_vertex.lon} #{$out_file}"
    end

   end

  def find_node_with_lat_lon(lat, lon)
    if ((lat.to_f).between?(@bounds[:minlat].to_f, @bounds[:maxlat].to_f) &&
        (lon.to_f).between?(@bounds[:minlon].to_f, @bounds[:maxlon].to_f)    )
    else
      puts "  -warning: lat/lon #{lat}/#{lon} NOT in boundaries in input file: #{@bounds[:minlat]}-#{@bounds[:maxlat]}/#{@bounds[:minlon]}-#{@bounds[:maxlon]}"
    end

    increment = 0.0001
    for i in 0..1000
      @visual_vertices.each do |vertex|
        #puts "is #{(vertex[1].lat).to_f} in range (#{(lat.to_f - (increment * i))} - #{lat.to_f + (increment * i)} )"
        if (
            (vertex[1].lat).to_f <= (lat.to_f + (increment * i)) &&
            (vertex[1].lat).to_f >= (lat.to_f - (increment * i)) &&
            (vertex[1].lon).to_f <= (lon.to_f + (increment * i)) &&
            (vertex[1].lon).to_f >= (lon.to_f - (increment * i))
           )
          return vertex[0]
        end
      end
      #i=i+1
    end
    puts "  -error: didn't find the node nearby input lat/lon #{lat}/#{lon} +-0.1) in the input osm file. Exiting...  "
    exit 1
  end

  def show_nodes_with_lat_lon(start_lat, start_lon, end_lat, end_lon)
    #find start/end vertex according to lat/lon
     @starting_vertex=find_node_with_lat_lon(start_lat, start_lon)
     @ending_vertex=find_node_with_lat_lon(end_lat, end_lon)

     #find start/end vertex according to lat/lon
     if !(@starting_vertex == nil || @ending_vertex == nil)  #if start or end is nill - finish
       puts "  -found starting vertex: #{@starting_vertex}: #{@visual_vertices[@starting_vertex].lat}, #{@visual_vertices[@starting_vertex].lon}}"
       puts "  -found ending vertex: #{@ending_vertex}:  #{@visual_vertices[@ending_vertex].lat}, #{@visual_vertices[@ending_vertex].lon}}"
       puts "  -marked starting and ending vertex on the map"
       @visual_vertices[@starting_vertex].set_emphesized(2)
       @visual_vertices[@ending_vertex].set_emphesized(2)
         puts "  -hint- to navigate call: --load #{$map_file} --midist  #{@visual_vertices[@starting_vertex].lat} #{@visual_vertices[@starting_vertex].lon} #{@visual_vertices[@ending_vertex].lat} #{@visual_vertices[@ending_vertex].lon} #{$out_file}"
     else
       puts "\n  -requested start/end vertex was not found on the map. "
     end
  end

end
