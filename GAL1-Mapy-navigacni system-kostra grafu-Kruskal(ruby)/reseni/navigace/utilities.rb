#
# static helping methods
#
# 1. areConnected -- to find, that nodes are already connected, to avoid loops and duplicities
# 2. omitDegree2Nodes
# 3. kruskalMst --
#
#

require_relative 'edge'
require_relative 'vertex'

#
# areConnected
#
    def are_connected(node1, node2, node_osm)
      #puts "areConnected entered with: #{node1} #{node2}"
      #nodes cannot be connected, if have no neighbours
      if node1.neighbours.length==0 or node2.neighbours.length==0
        puts "areConnected #{node1.osm_id} (#{node1.neighbours}or #{node2.osm_id} (#{node2.neighbours})  has empty neigbours. "
        return false
      end

      #store node1 neighbour osms to the array
      node1_neighbour_osms=[]
      node1.neighbours.each do |neighbour|
        node1_neighbour_osms << neighbour.osm_id
      end

      #store node2 neighbour osms to different array
      node2_neighbour_osms=[]
      node2.neighbours.each do |neighbour|
        node2_neighbour_osms << neighbour.osm_id
      end

      connected_times=0
      node2.neighbours.each do |neighbour|
        connected_times=connected_times=+1 if node1_neighbour_osms.include? neighbour.osm_id
      end

      # if there is a connectected triangle, and we would omit one of those two lines, the line would be doubled
      # N1 and N2 are always connected over the middle node with degree 2. always with 1 edge.
      #          N1 ----- N2
      #            \     /
      #             \  /
      #              N3

      if connected_times>1
        return true  #side nodes are already connected, not connecting again
        puts "warning. the nodes <#{node_osm}> left node <#{node1_neighbour_osms}> and right node <#{node2_neighbour_osms}> are already connected #{connected_times}x. going to keep the node "
      else
        return false  #one connection expected
      end
    end

#
# omitDegree2Nodes - after running this function on the nodes, only the crossing(3+) or starting nodes(1) should remain
#
    def omit_degree_2_nodes
      # add all nodes into a queue
      #  queue = put all nodes from @nodes into the queue
      # puts "#{@vertices}"
      queue = Queue.new
      @vertices.each do |node|
        queue << node
      end

      # iterate through all nodes until queue is not empty
      while ! queue.empty?
        # take the first node number from the queue
        # i = queue.deque()
        # take the first node itself
         node=queue.pop

        # puts "osm_id=#{node.osm_id} degree=#{node.degree}"
        # puts "node neighbours #{node.neighbours}"
        # do anything only iff this node's degree == 2
        if node.degree == 2
          # take the node's neighbours and the two edges going from the node
          # we would like to shrink these two edges into only one while isolating
          # the _node_
          v1_nr = node.neighbours[0]
          e1_nr = node.edges[0]
          v2_nr = node.neighbours[1]
          e2_nr = node.edges[1]

          #puts "actual node: #{node.osm_id} , actual neighbours #{v1_nr} , #{v1_nr}"
          #puts "neigbours of #{node.osm_id}: #{v1_nr.osm_id} #{v2_nr.osm_id}" if (node.neighbours.length==2)
          next if node.neighbours.length!=2

          # IMPORTANT!
          # however, if there was a cycle, which means that the node's neighbours
          # ARE already connected, do nothing and leave this degree-2-node _i_ as
          # it is!

          #puts "are connected #{v1_nr}, #{v2_nr} of #{node.osm_id}?"
           next if are_connected(v1_nr, v2_nr, node.osm_id)

          #puts "handling #{node.osm_id} - has 2 and is not cyclic, going to delete neighbours!"
          #puts "cur_node is: #{node.osm_id}"

          #puts "# this is not needed, but just for sure: record the neighbours' degrees before the shrinkage"
          #v1_deg = v1_nr.degree ; v2_deg = v2_nr.degree
          #puts "  -> neighbours degree: v1:#{v1_deg} v2:#{v2_deg}"

          #puts "# record the neighbours' OSM/id, for future use"
          #v1_osm = v1_nr.osm_id ; v2_osm = v2_nr.osm_id
          #puts "  -> v1_osm: #{v1_osm} deg: #{v1_deg} :: v2_osm #{v2_osm} deg: #{v2_deg}"

          #puts "# invalidate the two edges -- particularly, do not output them into Graphviz output"
          e1_nr.invalidate
          e2_nr.invalidate
          e_distance=e1_nr.time_distance+e2_nr.time_distance

          #puts "  -> invalidated edges - #{e1_nr} #{e1_nr.osm_from}-#{e1_nr.osm_to}(#{e1_nr.is_valid}) #{e2_nr} #{e2_nr.osm_from}-#{e2_nr.osm_to}(#{e2_nr.is_valid})"
          #puts "# disconnect the triple v1--i--v2, i.e. leave out the neighbours from
          # the nodes' own neighbours' lists"
           #ns=[] ; v1_nr.neighbours.each do |n|  ns << "#{n.osm_id}"  end;   puts "old v1 neighbours : #{ns}"
           #ns=[] ; v2_nr.neighbours.each do |n|  ns << "#{n.osm_id}"  end;   puts "old v2 neighbours : #{ns}"
           #ns=[] ; node.neighbours.each do |n|  ns << "#{n.osm_id}"  end;   puts "old v neighbours : #{ns}"

          node.disconnect_neighbour(v1_nr)
          node.disconnect_neighbour(v2_nr)
          v2_nr.disconnect_neighbour(node)
          v1_nr.disconnect_neighbour(node)
          node.invalidate

         #puts "Disconnect edges from nodes"
          #ns=[] ; v1_nr.edges.each do |n|  ns << "#{n.osm_from}-#{n.osm_to}(#{n.is_valid})"  end;   puts "  -> old v1 neighbours : #{ns}"
          #ns=[] ; v2_nr.edges.each do |n|  ns << "#{n.osm_from}-#{n.osm_to}(#{n.is_valid})"  end;   puts "  -> old v2 neighbours : #{ns}"
          v1_nr.disconnect_edge(e1_nr)
          v2_nr.disconnect_edge(e2_nr)

         #puts " # create a new edge going from v1 into v2 (it does not matter in which direction, it is anyway an artificial/virtual edge"
          # save this Edge into the array @edges
          v_nr = @vertices.length
          e = Edge.new(v1_nr.osm_id, v2_nr.osm_id, 0, v_nr, e1_nr.name, e1_nr.maxspeed, e1_nr.is_oneway, e_distance)

         #puts ("new edge from #{v1_nr.osm_id} to #{v2_nr.osm_id}")
          @edges.push(e)

         #puts "#add edge to vertex"
          #ns=[] ; v1_nr.edges.each do |n|  ns << "#{n.osm_from}-#{n.osm_to}(#{n.is_valid})"  end;   puts "old v1 edges : #{ns}"
          #ns=[] ; v2_nr.edges.each do |n|  ns << "#{n.osm_from}-#{n.osm_to}(#{n.is_valid})"  end;   puts "old v2 edges : #{ns}"
          v1_nr.add_edge(e)
          v2_nr.add_edge(e)

         #add linkeds to vetexes
          v1_nr.connect_neighbour(v2_nr)
          v2_nr.connect_neighbour(v1_nr)
        end
      end
    end

#
# kruskalMst - go over edges and mark those, which match the definition of minimum spanning tree
#
  def apply_kruskal
    #sort the edges by its time-distance (sec)
    #then go over each edge, check if its borders vertices belong to the same group, if not , connect it,
    #groups are the lowest id

     edges_counter=0

    #1. sort edges
     @valid_edges.sort! { |a,b| a.time_distance <=> b.time_distance }

    #2. initialize head and inks nodes. each is his own head and points to null. (we maintaint information only for the selected ones (saving))
     @valid_vertices.each do |n|
        n.set_node_head_mst(n.osm_id)
        n.set_node_tail_mst(n.osm_id)
       #puts "#{n.osm_id}, #{n.mst_head} "
     end

    #3. go over valid (filtered)edges, join if possible. lower id will always be n1
      @valid_edges.each do |e|
        #lower id to be first of the selected two nodes
        if e.osm_from<e.osm_to
          then
            n1osm=e.osm_from
            n2osm=e.osm_to
        else
            n1osm=e.osm_to
            n2osm=e.osm_from
        end

        #get object, its current head and next
        n1=@nodes_hash[n1osm]
        n2=@nodes_hash[n2osm]
        n1_head_osm=n1.mst_head
        n2_head_osm=n2.mst_head

    #4. if the head1 != head2, nodes can be connected and marked bold red
        if n1_head_osm != n2_head_osm
          #mark the edge as bold
           e.set_bold
           edges_counter=edges_counter + 1

         #get head object of both lists
           n1_tail_osm=n1.mst_tail
           n2_tail_osm=n2.mst_tail
           n1_head=@nodes_hash[n1_head_osm]
           n1_tail=@nodes_hash[n1_tail_osm]

         #join two lists (if they are lists)
           #puts "n1: H1:#{n1_head.mst_head} T1:#{n1_head.mst_tail} H1N:#{n1_head.mst_next} ## n2: H2:#{n2Head.mst_head} T2:#{n2Head.mst_tail} H2N:#{n2Head.mst_next}"
           n1_tail.set_next_node_mst(n2_head_osm)
           n1_head.set_node_tail_mst(n2_tail_osm)

         #fix links to head and tail on all their children
           child_node_osm=n1_head.mst_next
           until child_node_osm==-1 do
               child_node=@nodes_hash[child_node_osm]
               child_node.set_node_head_mst(n1_head_osm)
               child_node.set_node_tail_mst(n2_tail_osm)
               child_node_osm=child_node.mst_next
           end

          #puts "n1: H1:#{n1_head.mst_head} T1:#{n1_head.mst_tail} H1N:#{n1_head.mst_next} ## n2: H2:#{n2Head.mst_head} T2:#{n2Head.mst_tail} H2N:#{n2Head.mst_next}"
        end
      end

     #validations

     puts "Validation error. In mst should be less edges then vertices" if @valid_vertices.length <= edges_counter
     puts "Validation passed. Minimum spanning tree has less edges (#{edges_counter}) than vertices (#{@valid_vertices.length}). Graph has more components. " if @valid_vertices.length > edges_counter+1
     puts "Validation passed. Minimum spanning tree has one edge less (#{edges_counter}) than vertices (#{@valid_vertices.length}). Graph has one component. " if @valid_vertices.length == edges_counter+1
  end