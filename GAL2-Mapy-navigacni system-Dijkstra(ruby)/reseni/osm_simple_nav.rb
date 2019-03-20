require_relative 'lib/graph_loader';
require_relative 'process_logger';
#rubocop:disable all

# Class representing simple navigation based on OpenStreetMap project
class OSMSimpleNav

	# Creates an instance of navigation. No input file is specified in this moment.
	def initialize
		# register
		@load_cmds_list = ['--load','--load-comp']
		@actions_list = ['--export', '--show-nodes', '--midist']
		@num_of_args = ARGV.length

		@usage_text = <<-END.gsub(/^ {6}/, '')
	  	Usage:\truby osm_simple_nav.rb <load_command> <input.IN> <action_command> <output.OUT> 
      \tLoad commands: 
      \t\t --load ... load map from file <input.IN>, IN can be ['OSM','DOT']
      \tAction commands: 
      \t\t --export ... export graph into file <output.OUT>, OUT can be ['PDF','PNG','DOT']
      \t\t   f.e. --load data/ortenovo.osm --export data/ortenovo.pdf
      \t\t --show-nodes ... show nodes from the input files
      \t\t   f.e. --load data/ortenovo.osm --show-nodes 
      \t\t --show-nodes ... show nodes on the map (according to node ids or nearest gps coordinates)
      \t\t   f.e. --load data/ortenovo.osm --show-nodes 25681692 25665702  data/ortenovo.pdf
      \t\t   f.e. --load data/ortenovo.osm --show-nodes 50.1046044 14.4582325 50.1088580 14.4428390  data/ortenovo.pdf
      \t\t --midist 
      \t\t   f.e. --load data/ortenovo.osm --midist 50.1046044 14.4582325 50.1088580 14.4428390  data/ortenovo.pdf

		END
	end

	# Prints text specifying its usage
	def usage
		puts @usage_text
	end

	# Command line handling
	def process_args
		# not enough parameters - at least load command, input file and action command must be given
		unless ARGV.length >= 3
		  puts "Not enough parameters!"
		  puts usage
		  exit 1
		end

		# read load command, input file and action command
		@load_cmd = ARGV[0]
		unless @load_cmds_list.include?(@load_cmd)
		  puts "Load command not registred!"
		  puts usage
		  exit 1			
		end
		$map_file = ARGV[1]                     #global variable for nicer hint
		unless File.file?($map_file)
		  puts "File #{$map_file} does not exist!"
		  puts usage
		  exit 1						
		end

		@operation = ARGV[2]
		unless @actions_list.include?(@operation)
		  puts "Action command <#{@operation}> not registred!"
		  puts usage
		  exit 1			
		end

		# possibly load other parameters of the action
		if @operation == '--export'
		end

		# load output file, IDs of vertices, lat a lon of vertices
		case @num_of_args
		when 4
			$out_file = ARGV[3]         #global variable for nicer hint
			return
		when 6
			$out_file = ARGV[5]         #global variable for nicer hint
			@start_id = ARGV[3]
			@end_id = ARGV[4]
			return
		when 8
			$out_file = ARGV[7]         #global variable for nicer hint
			@start_lat = ARGV[3]
			@start_lon = ARGV[4]
			@end_lat = ARGV[5]
			@end_lon = ARGV[6]
			return
		end
	end

	# Determine type of file given by +file_name+ as suffix.
	#
	# @return [String]
	def file_type(file_name)
		return file_name[file_name.rindex(".")+1,file_name.size]
	end

	# Specify log name to be used to log processing information.
	def prepare_log
		ProcessLogger.construct('log/logfile.log')
	end

	# Load graph from OSM file. This methods loads graph and create +Graph+ as well as +VisualGraph+ instances.
	def load_graph
		graph_loader = GraphLoader.new($map_file, @highway_attributes)
		@graph, @visual_graph = graph_loader.load_graph()
	end

	# Load graph from Graphviz file. This methods loads graph and create +Graph+ as well as +VisualGraph+ instances.
	def import_graph
		graph_loader = GraphLoader.new($map_file, @highway_attributes)
		@graph, @visual_graph = graph_loader.load_graph_viz
	end

	# Run navigation according to arguments from command line
	def run
		# prepare log and read command line arguments
		prepare_log
	    process_args

	    # load graph - action depends on last suffix
	    #@highway_attributes = ['residential', 'motorway', 'trunk', 'primary', 'secondary', 'tertiary', 'unclassified']
	    #@highway_attributes = ['residential', 'motorway', 'trunk', 'primary', 'secondary', 'tertiary', 'unclassified']
	    #@highway_attributes = ['residential']
			@highway_attributes=['residential','primary', 'secondary', 'tertiary']
	    if file_type($map_file) == "osm" or file_type($map_file) == "xml" then
				load_graph
	    elsif file_type($map_file) == "dot" or file_type($map_file) == "gv" then
	      puts "calling import_graph from dot"
	    	import_graph
				puts "returned back from dot"
			else
	    	puts "Imput file type not recognized!"
	    	usage
	    end
		
		# perform the operation
	    case @operation
			when '--export'
				 	@visual_graph.export_graphviz($out_file)
	      	return
			when '--show-nodes'
				 case @num_of_args
				 	when 3
						@visual_graph.show_nodes
						return
				 when 6
						@visual_graph.show_nodes_with_ids(@start_id, @end_id)
						@visual_graph.export_graphviz($out_file)
					 	return
				 when 8
					 	@visual_graph.show_nodes_with_lat_lon(@start_lat, @start_lon, @end_lat, @end_lon)
					 	@visual_graph.export_graphviz($out_file)
						return
				 end
			when '--midist'
				@start_id=@visual_graph.find_node_with_lat_lon(@start_lat, @start_lon)
				@end_id=@visual_graph.find_node_with_lat_lon(@end_lat, @end_lon)
				puts "  -start lat/lon/id #{@start_lat}/#{@start_lon}/#{@start_id} end lat/lon/id #{@end_lat}/#{@end_lon}/#{@end_id}"
				puts "  -Call Dijkstra for shortest path between: #{@start_id} -> #{@end_id}"
        Dijkstra(@visual_graph, @start_id, @end_id )
				@visual_graph.export_graphviz($out_file)
				return
			else
	        usage
	        exit 1
	    end	
	end	
end

osm_simple_nav = OSMSimpleNav.new
osm_simple_nav.run
