require_relative '../process_logger'
require 'nokogiri'
require_relative 'graph'
require_relative 'visual_graph'
require_relative 'graph_util'

# Class to load graph from various formats. Actually implemented is Graphviz formats. Future is OSM format.
class GraphLoader
	attr_reader :highway_attributes

	# Create an instance, save +filename+ and preset highway attributes
	def initialize(filename, highway_attributes)
		@filename = filename
		@highway_attributes = highway_attributes
	end

	# Load graph from Graphviz file which was previously constructed from this application, i.e. contains necessary data.
	# File needs to contain
	# => 1) For node its 'id', 'pos' (containing its re-computed position on graphviz space) and 'comment' containig string with comma separated lat and lon
	# => 2) Edge (instead of source and target nodes) might contains info about 'way_speed' and 'one_way'
	# => 3) Generaly, graph contains parametr 'bb' containing array withhou bounds of map as minlon, minlat, maxlon, maxlat
	#
	# @return [+Graph+, +VisualGraph+]
	def load_graph_viz()
		ProcessLogger.log("Loading graph from GraphViz file #{@filename}.")
		gv = GraphViz.parse(@filename)

		# aux data structures
		hash_of_vertices = {}
		list_of_edges = []
		hash_of_visual_vertices = {}
		list_of_visual_edges = []

		# process vertices
		ProcessLogger.log("Processing vertices")
		gv.node_count.times { |node_index|
			node = gv.get_node_at_index(node_index)
			vid = node.id
     p "gvnodecounttimes: Vid=#{vid} node=#{node}"

			v = Vertex.new(vid) unless hash_of_vertices.has_key?(vid)
			ProcessLogger.log("\t Vertex #{vid} loaded")
			hash_of_vertices[vid] = v
      p "Vertex #{vid} loaded"

			geo_pos = node["comment"].to_s.delete("\"").split(",")
			pos = node["pos"].to_s.delete("\"").split(",")
			hash_of_visual_vertices[vid] = VisualVertex.new(vid, v, geo_pos[0], geo_pos[1], pos[1], pos[0])
			ProcessLogger.log("\t Visual vertex #{vid} in ")
		}

		# process edges
		gv.edge_count.times { |edge_index|
			link = gv.get_edge_at_index(edge_index)
			vid_from = link.node_one.delete("\"")
			vid_to = link.node_two.delete("\"")
			speed = 50
			one_way = false                    #in osm it is yes/no/empty
			link.each_attribute { |k,v|
				speed = v if k == "way_speed"
				one_way = true if k == "oneway"
			}
			p "vid_from #{vid_from} vid_to #{vid_to} way_speed #{speed} one_way=#{one_way} "
			e = Edge.new(vid_from, vid_to, speed, one_way)
			list_of_edges << e
			list_of_visual_edges << VisualEdge.new(e, hash_of_visual_vertices[vid_from], hash_of_visual_vertices[vid_to])
		}

		# Create Graph instance
		g = Graph.new(hash_of_vertices, list_of_edges)
		# Create VisualGraph instance
		bounds = {}
		bounds[:minlon], bounds[:minlat], bounds[:maxlon], bounds[:maxlat] = gv["bb"].to_s.delete("\"").split(",")
		vg = VisualGraph.new(g, hash_of_visual_vertices, list_of_visual_edges, bounds)
		return g, vg
	end

	# Method to load graph from OSM file and create +Graph+ and +VisualGraph+ instances from +self.filename+
	#
	# @return [+Graph+, +VisualGraph+]

	def load_graph()
		ProcessLogger.log("Loading graph from OSM file #{@filename}.")

		# aux data structures
		hash_of_vertices = {}
		#nodes_hash
		list_of_edges = []
		hash_of_visual_vertices = {}
		list_of_visual_edges = []

		File.open(@filename, 'r') do |file|
			doc = Nokogiri::XML::Document.parse(file)

			# process vertices => get data from source file, create an instance of Vertex and add it to the hash of all vertices. The same for VisualVertex
			puts "\n1. open file and create hash_of_vertices (nodes_hash): "
				doc.root.xpath('node').each do |node_element|
				lat=node_element.attr('lat')
				lon=node_element.attr('lon')
				pos0=((lat.to_f))
				pos1=((lon.to_f))   #in dot file the position is given, in osm file it is not, so it's set to take the value based on gps
				vid = node_element.at_xpath('@id').content   #osm_id
				v = Vertex.new(vid)
				hash_of_vertices[vid] = v
				hash_of_visual_vertices[vid] = VisualVertex.new(vid, v, lat, lon ,  pos0 , pos1 )  #visual possition is switched to avoid 90degree turn of the map
				ProcessLogger.log("\t Visual vertex #{vid} in lat=#{lat} lon=#{lon} pos0=#{pos0} pos1=#{pos1} ")
			end
			puts ("  - nodes loaded: #{hash_of_vertices.length} to hash_of_vertices" )
			puts ("  - visual nodes loaded: #{hash_of_visual_vertices.length} to hash_of_visual_vertices" )


			# get data from source file, create an instance of Edge and add it to the array of all edges. The same for VisualEdge
			puts "\n2. go over each way"
			doc.root.xpath("way/tag[@k='highway']").each do |way_element|
				way_visible=''; way_speed=''; name=''; way_type=''; way_id=''; way_name=''; one_way=''; way_junction=''

				filtered_way=way_element.parent
					filtered_way.xpath('tag').each do |tag_element|                   #find xml elements with signature tag, there is stored for each way the way_speed, name, one_way...
				   	one_way=tag_element['v'] if (tag_element['k']=='oneway')        #each way could be one_way or twoways
					  way_speed=tag_element['v'].to_i if (tag_element['k']=='maxspeed')   #each way has its own max way_speed, if not default is 50
					  way_type=tag_element['v'].to_s if (tag_element['k']=='highway') #helper variable to find, if it is highway (not pavement, etc..)
					  way_visible=filtered_way.attr('visible')											 	 #helper variable to find, if the way is not visible (should be filtered out)
					  way_name=tag_element['v'] if (tag_element['k']=='name')         #name for logging purposes, not in structures
						way_junction=tag_element['v'] if (tag_element['k']=='junction') #roundabout is oneway	<tag k="junction" v="roundabout"/>
						#way_id=filtered_way.attr('id').to_i                             #for tracing purposes
					end

				#set defaults
  				one_way != "yes" ? one_way="false" : one_way="true" #if it is not defined, it is twoway
	  			way_speed=50 if (way_speed.nil? || way_speed=="")    #so it will be 50, or original value

				#filter specific way_types, must be in list, must be visible, for each find all nd elements (links to vertices)
				nd_list=[]
				if  @highway_attributes.include?(way_type) && (way_visible.nil? || way_visible == 'true')
					filtered_way.xpath('nd').each do |nd_element|                    #filter only the <nd ref="..." elements
						nd_id_value=nd_element['ref']                                  #show the relevant vertexes/node elements for the given way
						nd_list << nd_id_value                                         #store the vertices mentioned under the way to the list for the next step
         end
					nd_list.each_with_index do |nd_entity, i|
						if nd_list.to_a[i+1] != nil
							vid_from=nd_list.to_a[i]
							vid_to = nd_list.to_a[i+1]
							e = Edge.new(vid_from, vid_to, way_speed, one_way)
							list_of_edges << e
							ve=VisualEdge.new(e, hash_of_visual_vertices[vid_from], hash_of_visual_vertices[vid_to])
							ve.set_edge_name(way_name)
							list_of_visual_edges << ve
					 	  #if (one_way != "true" && way_junction != "roundabout") #directed graph, twoway means two edge. roundabout is special oneway
							if (one_way == "false" && way_junction != "roundabout") #directed graph, twoway means two edge. roundabout is special oneway
								e = Edge.new( vid_to,vid_from, way_speed, one_way)
								 list_of_edges << e
								 ve=VisualEdge.new(e, hash_of_visual_vertices[vid_to], hash_of_visual_vertices[vid_from])
						 	   ve.set_edge_name(way_name)
		 						 ve.hidden=true                #to hide the helping edge from the output (there is already the original )
                list_of_visual_edges << ve
              end
            end
					end
				end
			end
			puts "  - list_of_edges: #{list_of_edges.length} list_of_visual_edges: #{list_of_visual_edges.length}  hash_of_vertices: #{hash_of_vertices.length} hash_of_visual_vertices=#{hash_of_visual_vertices.length} "

		  puts "\n3. CLEAN VERTICES, WHICH DONT LAY ON THE WAYS"
			hash_of_visual_vertices.each do |vert|
        if (vert[1].print_degree) == 0
					hash_of_visual_vertices.delete(vert[0])
					hash_of_vertices.delete(vert[0])
				end
			end
			p "  - loaded objects, list_of_edges: #{list_of_edges.length} list_of_visual_edges: #{list_of_visual_edges.length}  hash_of_vertices: #{hash_of_vertices.length} hash_of_visual_vertices=#{hash_of_visual_vertices.length} "
			if list_of_visual_edges.length == 0
				puts "ERROR DETECTED: problems with map detected. existting..."
				exit -1
			end
			p "  - list_of_edges: #{list_of_edges.length} list_of_visual_edges: #{list_of_visual_edges.length}  hash_of_vertices: #{hash_of_vertices.length} hash_of_visual_vertices=#{hash_of_visual_vertices.length} "


	puts "\n4. DETECT AND CLEAN VERTICES, WHICH BELONG TO SMALLER DISCONNECTED COMPONENTS"
			#helping structure which holds original vertices and will substract the sets
			pending_vertices=Set[]
			processed_vertices=Set[]
			g_component=[]
			processed_edges=[]
			g_component_edges=[]

      #fill the all vertices to the helping structure of type Set - for easier manipulation (arithmetics)
			hash_of_visual_vertices.each do | pv |
				pending_vertices<<pv[1].get_id
			end

			#loop over pending vertices and each subset (component of the graph) store to different index of the
			i=0; 	biggest_idx=0
			while pending_vertices.length > 0
			find_neighbours_recursive(pending_vertices.first(), processed_vertices, hash_of_visual_vertices, processed_edges)
				g_component[i]=processed_vertices.flatten
				pending_vertices=pending_vertices-processed_vertices
			  g_component_edges[i]=processed_edges

				#find if this iterration is the biggest component
				if g_component[i].length > g_component[biggest_idx].length
					biggest_idx=i
				end
				processed_vertices=[]
			  processed_edges=[]
				i=i+1
			end
			p "  - loaded objects, list_of_edges: #{list_of_edges.length} list_of_visual_edges: #{list_of_visual_edges.length}  hash_of_vertices: #{hash_of_vertices.length} hash_of_visual_vertices=#{hash_of_visual_vertices.length} "

			puts "\n5. CLEAN EDGES (or other/smaller graph components)"
			puts "  -before clean"
			g_component.each_with_index do |compgroup, idx|
				puts "  g component #{idx} - vertices: #{g_component[idx].length} edges: #{g_component_edges[idx].length}"
			end
			puts "  g component biggest - vertices: #{g_component[biggest_idx].length} edges: #{g_component_edges[biggest_idx].length}"

			g_component_edges.each_with_index do |edges_group, idx|
				if idx != biggest_idx
					#visual edges for subtrees
					edges_group.each do |one_visual_edge_arr|
						one_visual_edge_arr.each do |one_visual_edge|
  						list_of_visual_edges.delete(one_visual_edge)
            	list_of_edges.delete(one_visual_edge.edge)
						end
					end
				else
				#those are real edges - calculate distance on them
					edges_group.each do |one_visual_edge_arr|
						one_visual_edge_arr.each do |one_visual_edge|
							one_visual_edge.calculate_and_store_length
						end
					end
				end
			end
			puts "  -after edges clean- list_of_edges: #{list_of_edges.length} list_of_visual_edges: #{list_of_visual_edges.length}  hash_of_vertices: #{hash_of_vertices.length} hash_of_visual_vertices=#{hash_of_visual_vertices.length} "

		puts "\n5. DELETE VERTICES "
			#delete vertices
			puts " -visual vertices before clean- #{hash_of_visual_vertices.length}"
			g_component.each_with_index do |cmprem, idx|
				if idx != biggest_idx
					g_component[idx].each do |one_vertex|
						hash_of_vertices.delete(one_vertex)
						hash_of_visual_vertices.delete(one_vertex)
					end
				end
			end
			puts " -visual vertices after clean- #{hash_of_visual_vertices.length}"

			puts "\n5. CREATE GRAPH"
			g = Graph.new(hash_of_vertices, list_of_edges)

			# Create VisualGraph instance
			bounds = {}
			bounds[:minlon]=doc.root.xpath('bounds').attr('minlon').to_s
			bounds[:minlat]=doc.root.xpath('bounds').attr('minlat').to_s
			bounds[:maxlon]=doc.root.xpath('bounds').attr('maxlon').to_s
			bounds[:maxlat]=doc.root.xpath('bounds').attr('maxlat').to_s

			vg = VisualGraph.new(g, hash_of_visual_vertices, list_of_visual_edges, bounds)
			return g, vg
		end
  end
end
