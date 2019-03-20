# omitDegree2Nodes
#
# author: Lukas Bajer
#
# date: 2016-12-21

def omitDegree2Nodes
  # add all nodes into a queue
  queue = put all nodes from @nodes into the queue

  # iterate through all nodes until queue is not empty
  while (! queue.empty?)

    # take the first node number from the queue
    i = queue.deque()

    # take the first node itself
    node = @nodes[i]

    # do anything only iff this node's degree == 2
    if (node.degree == 2)

      # take the node's neighbours and the two edges going from the node
      # we would like to shrink these two edges into only one while isolating
      # the _node_
      v1_nr = node.neighbours[0]
      e1_nr = node.edges[0]
      v2_nr = node.neighbours[1]
      e2_nr = node.edges[1]

      # IMPORTANT!
      # however, if there was a cycle, which means that the node's neighbours
      # ARE already connected, do nothing and leave this degree-2-node _i_ as
      # it is!
      next if areConnected(v1_nr, v2_nr)

      # this is not needed, but just for sure: record the neighbours'
      # degrees before the shrinkage
      v1_deg = @nodes[v1_nr].degree
      v2_deg = @nodes[v2_nr].degree

      # record the neighbours' OSM/id
      v1_osm = @nodes[v1_nr].osm_id
      v2_osm = @nodes[v2_nr].osm_id

      # invalidate the two edges -- particularly, do not output them into
      # Graphviz output
      @edges.invalidate(e1_nr)
      @edges.invalidate(e2_nr)

      # disconnect the triple v1--i--v2, i.e. leave out the neighbours from
      # the nodes' own neighbours' lists
      node.disconnect(v1_nr)
      @nodes[v1_nr].disconnect(i)
      node.disconnect(v2_nr)
      @nodes[v2_nr].disconnect(i)

      # create a new edge going from v1 into v2 (it does not matter in which
      # direction, it is anyway an artificial/virtual edge
      edge = Edge.new(a_new_OSM_id, v1_osm, v2_osm, @edges[e1_nr].name, @edges[e1_nr].maxspeed, @edges[e1_nr].is_oneway)
      @edges.add(edge)
      # and connect the nodes v1--v2 according to this edge in their
      # own neighbours lists
      @edges.connect(edge)

      # this should not happen, but just for sure:
      #
      # if the degree of the node v1 or v2 changed, report it
      # and if it changed to degree==2, add this node into (possibly again)
      # the queue to shrinkage processing
      #
      if (@nodes[v1_nr].degree != v1_deg)
        puts "Node #{v1_osm} changed degree #{v1_deg} --> #{@nodes[v1_nr].degree}!" 
        queue.push(v1_nr) if (@nodes[v1_nr].degree == 2)
      end
      if (@nodes[v2_nr].degree != v2_deg)
        puts "Node #{v2_osm} changed degree #{v2_deg} --> #{@nodes[v2_nr].degree}!" 
        queue.push(v2_nr) if (@nodes[v2_nr].degree == 2)
      end
    end 
  end
end
