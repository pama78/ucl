# rubocop:disable all

#use of recursive DFS alg.
def find_neighbours_recursive(vv, in_branch, hash_of_visual_vertices, processed_edges)
  if !in_branch.include?(vv)
    in_branch << vv
    processed_edges << hash_of_visual_vertices[vv].get_neighbour_edges
    list_neigbours=hash_of_visual_vertices[vv.to_s].get_neighbours
    list_neigbours.each do | vv_nb |
      find_neighbours_recursive(vv_nb.to_s , in_branch , hash_of_visual_vertices, processed_edges)
    end
  end

#difference between to gps coordinates - downloaded from Stack overflow
#http://stackoverflow.com/questions/12966638/how-to-calculate-the-distance-between-two-gps-coordinates-without-using-google-m
  def get_distance(lat1, lon1, lat2, lon2)
  rad_per_deg = Math::PI / 180
  rm = 6371000 # Earth radius in meters
  lat1_rad, lat2_rad = lat1 * rad_per_deg, lat2 * rad_per_deg
  lon1_rad, lon2_rad = lon1 * rad_per_deg, lon2 * rad_per_deg
  a = Math.sin((lat2_rad - lat1_rad) / 2) ** 2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin((lon2_rad - lon1_rad) / 2) ** 2
  c = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1 - a))
   return (rm * c ).round(2)
  end


#Dijkstra - get nearest Edge
  def get_vertext_min_PL(i_vertices)
    #puts "  --entered get_vertext_min_PL1"
    #puts "  --input #{i_vertices.length} " #---"[294029732]}"
    min=INFINITY
    x=EMPTY
    i_vertices.each do |cur_vertex|
       #puts "cur_vertex #{cur_vertex[0]} #{cur_vertex[1].status} path length: #{cur_vertex[1].path_length}"
        if (cur_vertex[1].status == TEMPORARY and cur_vertex[1].path_length < min )  #perm=pokus...osledni podminka navic and edge.v1.path_length != INFINITY
         #puts "   --vertex.sts= #{cur_vertex[1].status} vertex.path_length(#{cur_vertex[1].path_length}) is less then min #{min}"
         x=cur_vertex[1]
         min=cur_vertex[1].path_length
      end
    end

    #if  x != EMPTY
      #puts "    - get_nearest_vertex - about to return #{x.id} with min #{min} value of all connected Vx"
    #end
    return x
  end


#alghoritm based on visualisation: https://www.youtube.com/watch?v=q3yKyE19OR0
  def Dijkstra(g, s, e)
    #puts "In Dijkstra: start : #{g.visual_vertices[s]} end : #{g.visual_vertices[e]} "
    g.visual_vertices[s].path_length=0                            #starting Vx is 0 length, other have longer
    path_dur=0
    while true
      c=get_vertext_min_PL(g.visual_vertices)
       if (c==EMPTY)
         #puts "c was empty, returning"
         puts "  -path between #{s} and #{e} was not found, so it is not marked on output map"
         return
       end
      #puts " - vertex #{c.id} status=> PERMANENT"
      c.status=PERMANENT
      if (c.id == e and c.status==PERMANENT ) #found end?
       #  puts "  -found end vertex e #{e} and it is in status PERMANENT and path length is #{c.path_length} and predescessor #{c.predecessor}  "
       #now have end and start - mark all edges to be red,  get duration
          vv_start=g.visual_vertices[s]                #visual vertex of start node
          vv_cur=g.visual_vertices[e]                  #visual vertex start with end node
          vv_cur.set_emphesized(2)
          #handle edges
          tp="#{e}"     #text path
          while vv_cur != vv_start
            #puts "   is vv_cur #{vv_cur.id} != #{vv_start.id} ? finsh if yes"
            #puts "have in hand #{vv_cur.id}, his forecomer #{vv_cur.predecessor.id} - look for that one showing on me"
            vv_cur.predecessor.neighbour_edges.each do |neighbour_edge|
              if neighbour_edge.v2.get_id == vv_cur.get_id
                #puts "  !!finally found edge pointing from neighbour_edge.v2=#{vv_cur.get_id} = #{neighbour_edge.v2.get_id} - neighbour edge.set_emphesized =>1 "
                #length/50/.36
                cur_dur = neighbour_edge.distance / neighbour_edge.edge.max_speed / 0.36
                path_dur = (path_dur + cur_dur)
                #puts "length #{neighbour_edge.distance} speed: #{neighbour_edge.edge.max_speed} res: #{path_dur} #{cur_dur}"
                neighbour_edge.set_emphesized(1)
                if neighbour_edge.hidden == true
                  #unhide hiden
                  neighbour_edge.hidden = false
                  #hide unhiden
                  vv_cur.neighbour_edges.each do |neighbour_edge_hide|
                    if neighbour_edge_hide.v2.get_id == vv_cur.predecessor.id
                      neighbour_edge_hide.hidden = true
                    end
                  end
                end
                #stop further search
                break
              end
             end

            vv_cur=vv_cur.predecessor
            vv_cur.set_emphesized(1)
            #puts "vv_cur = vv_cur.predescessor = #{vv_cur.id} - set_emphesized =>1 "
            tp="#{vv_cur.id}->#{tp}"

          end
          puts "\n  -full path: #{tp} "
          puts "  -full path length: #{c.path_length.round}m"
          puts "  -minimum duration: #{path_dur.round/60} minute(s) #{(path_dur.round)%60} seconds"
          #puts "#{vv_start.id} -> set emphesized => 2"
          vv_start.set_emphesized(2)
          return
        end

     #analyse all neighbours of the current vertex C
      #puts " - have neigbour edges: #{c.neighbour_edges.length} - analyse one by one:"
      c.neighbour_edges.each do |edge|
        if edge.v2.status==TEMPORARY
          #puts "   - v2 je TEMPORARY v1:#{edge.v1.id} -> v2:#{edge.v2.id} v2.length: (v1.PL)#{edge.v1.path_length} + (edge.distance)(#{edge.distance}"
          if ((edge.v1.path_length + edge.distance) < edge.v2.path_length )  #found shorter path?
            edge.v2.path_length = edge.v1.path_length + edge.distance
            #puts "   - nastavuju trasu vertexu v2 #{c.id} na delku #{edge.v2.path_length} (navyseni o #{c.path_length}) "
            edge.v2.predecessor  = c         #to show, which is the previous vertex on the shortest way
          end
        end
      end
    end
  end


end