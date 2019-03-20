###
#
# Author: Pavel Majer
# Date:   28/12/2016
##

#zadani DU 1
#  Načíst soubor s mapou ve formátu OSM, vyfiltrovat pouze hrany potřebné pro konstrukci uliční
#  sítě (tudíž například ne okraje budov) a zkonstruovat neorientovaný graf reprezentující danou síť
#  (prozatím budeme ignorovat možnost jednoho směru). Uložte také informaci o délce každého segmentu
#  ulice a povolené rychlosti – pokud informace o povolené rychlosti nebude dostupná, pak ji
#  nastavte jako 50 km/h. Poté zobrazte výsledek načtení do textového výstupu pro program Graphviz.
#  výstup by měl využívat geografické informace (lat a lon) a mapa ulic by tak měla být dobře
#  poznatelná. Body křižovatek je možné zobrazit výrazněji.
#  Program bude mít následující rozhraní: ruby osm2graphviz.rb --load <map.osm> <output.gv>
# Postup:
#  1. najit misto na mape: https://www.openstreetmap.org/ => export do map.osm
#  2. spustit nastavit jmeno vystupu, vstupu program - --load <cesta>\map.osm c:\ruby\map.gv
#  3. neato -Tpdf -o VYSTUPNI_SOUBOR.pdf VSTUPNI_SOUBOR.gv
#
# Poznamky k reseni:
#  1. nepodarilo se mi rozbehat knihovnu geokit, ta by mela umet pocitat vzdalnosti mezi gps souradnicemi.
#     misto toho jsem nasel na stackoverflow algoritmus na vypocet. pouzil jsem ten (je ve zdrojich)
#  2. na parsovani xml pouzivam knihovnu nokogiri. predpokladam ze jde o standard a neni potreba popisovat
#     jeji instalaci
#  3. pri pruchodu cestami neprojizdim cesty tam a zpatky. prochazim pouze jednim smerem. pri tvorbe grafu
#     pouzivam relaci "--", ktera by mela dobre poslouzit pro neorientovany graf.
#     pokud by bylo treba, muzu doplnit i pruchod zpatky.
#  4. narazil jsem pri testovani na ruzne obtize se zobrazitelnosti vyslednych pdfek.
#     Nejspis to bylo zpusobene mnozstvim bodu, pozicovanim a nasobenim gps souradnic. ty jsem
#     musel nasobit bulharskou konstantou, aby graf byl citelny. nakonec jsem nechal ten nasobic
#     mezi  100 a 5000. kdyz je hodne elementu, nasobic se blizi ke 100, kdyz je malo elementu,
#     je 5000
#  5. neuvazuji waytype=service. u nekterych ulic, ktere jsem zkoumal by se to hodilo, ale u vetsiny
#     to spise prekazelo. je to momentalne odfiltrovane, ale da se to pokud bude treba vratit.
#
# Poznamky k reseni DU2:
#  1. DU1 prepracovany, je vice objektove orientovany
#  2. DU2 kvuli prehlednosti jsem rozdelil do vice rb souboru.
#  3. je tam relativne hodne komentaru, ty odstranim az s du3. pravdepodobne se budou jeste hodit.
#
#  dalsi zdroje: http://stackoverflow.com/questions/4379977/ruby-find-items-in-hash-by-values
#         http://stackoverflow.com/questions/12966638/how-to-calculate-the-distance-between-two-gps-coordinates-without-using-google-m
#
############################################################################################


#variables and config
  #ignored_waytypes=["footway","cycleway","","steps","service", "living_street","unclassified", 'service']
  road_waytypes=['residential','primary', 'secondary', 'tertiary']
  @nodes_hash={}
  @nodes_hash_filtered={}
  @vertices = []
  @edges = []
  @new_edges = []
  DEBUG_LEVEL=0              #0=very basic messages, 100=headers and basic info, 1000 full details
  PDF_GPS_MULTIPLY=500000   # GPS multiplier = this value/number of nodes, if result>5000, we keep 5000

  require 'nokogiri'
  require_relative 'edge'
  require_relative 'vertex'
  require_relative 'utilities'

###################################################################################3
puts "osm2graphviz.rb started with parameters #{ARGV}"

#
#validate inputs
#
    case ARGV[0]
      when '--load'
          (puts "\nIncorrect use of the script. Option --load expect 2 paramerters: <map.osm> <ouput.gv>. exitting" ; exit) if ARGV.size!=3
          INPUT_FILE=ARGV[1]
          OUTPUT_FILE=(ARGV[2])
          SCRIPT_MODE=1   #1= convert map.osm to output.gv
          puts "about to load file #{INPUT_FILE} and create the graphviz file\n"
      when '--mst'
          (puts "\nIncorrect use of the script. Option --mst expect 2 paramerters: <map.osm> <ouput.gv>. exitting" ; exit) if ARGV.size!=3
          INPUT_FILE=ARGV[1]
          OUTPUT_FILE=(ARGV[2])
          SCRIPT_MODE=2   #2= convert map.osm to output.gv and show the minimum spanning tree in red
          puts "about to load file #{INPUT_FILE}, find there the minimum spanning tree and create the graphviz file\n "
      else
          puts "\nIncorrect use of the script. Please run with parameters --load <map.osm> <output.gv> or --mst <map.osm> <output.gv>\nexitting"
          exit 1
      end

    #validate file
    unless File.exist?(INPUT_FILE)
      puts "#{INPUT_FILE} doesn't exist, program terminates"
      exit 1
    end
     if File.exist?(OUTPUT_FILE)
       #puts "#{OUTPUT_FILE} already exist, remove/rename the file manually and rerun the program. \nexitting"
       puts "#{OUTPUT_FILE} file existed. deleting the file"
       File.delete(OUTPUT_FILE)
     end

    unless File.exist?(File.dirname(OUTPUT_FILE))
      puts "Selected directory of given output file #{OUTPUT_FILE} doesnt exist. please fix and rerun the program. \nexitting"
      exit 1
    end

#
# open file, parse xml, store store the contents
#
  puts "\n1. open file and create nodes_hash: "  if DEBUG_LEVEL>=100
  puts '=============================='        if DEBUG_LEVEL>=100
  File.open(INPUT_FILE, 'r') do |file|
    doc = Nokogiri::XML::Document.parse(file)
    doc.root.xpath('node').each do |node_element|
       lat=node_element.attr('lat')
       lon=node_element.attr('lon')
       osm_id = node_element.at_xpath('@id').content.to_i
       v = Vertex.new(osm_id, lat, lon)
       #puts "osm_id #{osm_id} lat #{lat} #{lon} vertex: #{v}"
       @nodes_hash[osm_id] = v
       #puts " puts nodes #{@nodes_hash[osm_id]} "
     end
    puts ("nodes loaded: #{@nodes_hash.length}" )  if DEBUG_LEVEL>=100

    puts "\n2. go over each way"     if DEBUG_LEVEL>=100
    puts '===================='      if DEBUG_LEVEL>=100
       doc.root.xpath("way/tag[@k='highway']").each do |way_element|
          #set defaults
          name=''
          is_oneway='no'
          way_type=''
          way_visible='true'    #default
          maxspeed=50
          way_id=''

          filtered_way=way_element.parent
          puts ( "\nstart processing: " + way_element.parent.to_s )    if DEBUG_LEVEL>=1000
          puts '================================================'      if DEBUG_LEVEL>=1000
             filtered_way.xpath('tag').each do |tag_element|
               p ( 'tag element: ' + tag_element.to_s )                if DEBUG_LEVEL>=1000
               name=tag_element['v'] if (tag_element['k']=='name')
               is_oneway=tag_element['v'].to_s if (tag_element['k']=='oneway')
               way_type=tag_element['v'].to_s if (tag_element['k']=='highway')
               maxspeed=tag_element['v'].to_i if (tag_element['k']=='maxspeed')
               way_visible=filtered_way.attr('visible')
               way_id=filtered_way.attr('id').to_i
            end

             if  road_waytypes.include?(way_type) && way_visible
                p ( 'way_id=' + way_id.to_s + 'way_name=' + name + ' is_oneway=' + is_oneway + ' way type:' + way_type + ' way visible:' + way_visible.to_s + ' speed: ' + maxspeed.to_s) if DEBUG_LEVEL>=1000
                node_cur=''
                node_prev=''
                last_osm_id=''
                last_vertex=''
                cur_vertex=''
                last_internal_number=0   #zatim nevim k cemu se bude pouzivat
                filtered_way.xpath('nd').each do |nd_element|
                   node_position=@nodes_hash[nd_element['ref']]
                   node_cur=nd_element['ref']
                   #old: puts ( "  --> node #{node_position} out-degree: (#{node_position[:deg_in]}) =+1"    ) if DEBUG_LEVEL>=1000
                   #node_position[:deg_in] += 1  #number of links of this position, 3+ =crossing
                   if node_prev == ''
                     #first run
                     node_prev=node_cur if node_prev == ''
                     #new:
                     # ...
                     # take the first <nd> reference OSM id into _nd1_osm_id_
                     # ...
                     nd1_osm_id=nd_element['ref'].to_i   #DANGER
                     v1 = @nodes_hash[nd1_osm_id]
                     v1.set_number(@vertices.length)
                     @vertices.push(v1)  unless @vertices.include?(v1)
                     last_osm_id = nd1_osm_id
                     last_internal_number = 0
                     last_vertex=v1
                     # ...
                  else
                    #other runs
                    #old p ( "  --> node #{node_prev} in-degree: (#{node_position[:deg_out]}) =+1"    ) if DEBUG_LEVEL>=1000
                    # find the right node already saved into the Hash
                    nd_osm_id=nd_element['ref'].to_i
                    cur_vertex = @nodes_hash[nd_osm_id]
                    # set its internal number to the next free number
                    v_nr = @vertices.length
                    cur_vertex.set_number(v_nr)
                    # save this Vertex into the array @vertices
                    @vertices.push(cur_vertex)  unless @vertices.include?(cur_vertex)

                   # create a new Edge, calculate time distance in secs
                    distance=cur_vertex.get_distance(last_vertex)
                    distance_s=(distance/maxspeed*3.6).ceil.to_i
                    e = Edge.new(last_osm_id, nd_osm_id, last_internal_number, v_nr, name, maxspeed, is_oneway, distance_s)

                   # save this Edge into the array @edges
                     @edges.push(e)

                    # ...
                    #increase in/out degree (out is from previous iterration, in is current)
                      cur_vertex.increment_degree
                      last_vertex.increment_degree
                     #add edge to vertex
                      cur_vertex.add_edge(e)
                      last_vertex.add_edge(e)
                    #add linkeds to vetexes
                      cur_vertex.connect_neighbour(last_vertex)
                      last_vertex.connect_neighbour(cur_vertex)
                    #store last value as the begining of the next edge
                      last_osm_id = nd_osm_id
                      last_internal_number = v_nr
                      last_vertex=cur_vertex
                      node_prev=node_cur
                   end
                end
                p ( "  --> @vertices= #{@vertices}"  ) if DEBUG_LEVEL>=1000
                p ( "  --> @edges = #{@edges} ")  if DEBUG_LEVEL>=1000
             end  #if waytypes include list
       end
  end  #end of open file

 #filter hashes according to verticles - other will not be needed only ~1/30 is needed
  @vertices.each do |vertex|
    @nodes_hash_filtered[vertex.osm_id]=vertex
  end
  @nodes_hash=@nodes_hash_filtered

#
#Map manipulation for mst/load options - for mst we remove nodes and mark mst on the graph
#
  if SCRIPT_MODE == 2
    #1. remove the degree 2 nodes
     omit_degree_2_nodes if SCRIPT_MODE==2

    #2.filter unused, if any (du2, vertices reduce 60% edges reduce 90%)
     @valid_edges=[]
     @valid_vertices=[]
     @edges.each do |e| ; @valid_edges << e if e.is_valid; end
     @vertices.each do |v| ; @valid_vertices << v if v.is_valid; end

    #3. apply kruskal to mark certan ways for DU2 only
      apply_kruskal
  else
    @valid_edges=@edges
    @valid_vertices=@vertices
  end


 #calculate gps multiplier - for better representation, based on number of elements
    real_pdf_multiply=PDF_GPS_MULTIPLY/(@vertices.length)  #more links lesser number
    real_pdf_multiply=5000 if real_pdf_multiply>5000
    real_pdf_multiply=1000 if real_pdf_multiply<1000
    puts "found crossings #{nodes_crossings.size} and road links #{nodes_conn.size}. the gps coordinates will be multiplied by #{real_pdf_multiply}"  if DEBUG_LEVEL>=100


#
#write file
#
  puts ( "\nstart writing the file: " + OUTPUT_FILE )        if DEBUG_LEVEL>=100
  puts '================================================'  if DEBUG_LEVEL>=100

  File.open(OUTPUT_FILE, 'w') do |file|
    begin
      file.puts 'strict graph {'
      file.puts " node [ label=\" \", height=0.05, color=blue, shape=point, width=0.2]"

      #blue verices (for DU2 could be disabled, as there are not supposed to be any 2degree nodes, but left here for safety reasons)
      @valid_vertices.each do |vertex|   #connectors (DU1)
          file.puts ("#{vertex.osm_id} [ pos=\"#{vertex.lon*(real_pdf_multiply)},#{vertex.lat*(real_pdf_multiply)}!\" ]" ) if (vertex.degree == 2)
       end

      #red vertices (crossings)
      file.puts " node [ label=\" \", height=0.1, color=red, shape=point, width=0.2]"
      @valid_vertices.each do |verticle|   #connectors (DU2)
        file.puts ("#{verticle.osm_id} [ pos=\"#{verticle.lon*(real_pdf_multiply)},#{verticle.lat*(real_pdf_multiply)}!\" ]" ) if verticle.degree !=2
      end

      #write edges
      @valid_edges.each do |edge|
        #osmDistance= edge.instance_variable_get(:@time_distance)
        #edge_info="#{osmDistance}m; #{edge.instance_variable_get(:@maxspeed)}; #{osmFR}->#{osmTO}"
        degree_sum=@nodes_hash_filtered[edge.osm_from].degree + @nodes_hash_filtered[edge.osm_to].degree

        #show name only on non blue nodes (only ends and crossings have sum !=4)
        edge_info="#{edge.name}"                            if SCRIPT_MODE == 1 and degree_sum != 4
        edge_info="#{edge.name} (#{edge.time_distance}s)"   if SCRIPT_MODE == 2
        edge_color="color=\"red\", penwidth=2, " if edge.is_bold
        file.puts "#{edge.osm_from} -- #{edge.osm_to} [ #{edge_color} label=\"#{edge_info}\" ] "
      end

      file.puts '}'
      OUTPUT_BASE_B=File.basename(OUTPUT_FILE )
      puts "\nFile #{OUTPUT_FILE} was created. To generate PDF with neato do: neato -Tpdf -o #{OUTPUT_BASE_B}.pdf #{OUTPUT_FILE} "
    rescue
      puts "\nError appeared wnen trying to create file #{OUTPUT_FILE}"
    ensure
      file.close unless file.nil?
    end
  end
