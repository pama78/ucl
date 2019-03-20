###################################################################################################################
# jmeno: hrabibench.rb
# ucel:  provede 5 druhu sortovani na dane kombinace (m, n), kde m je velikost poli, a n je pocet opakovani testu
#
# autor: Pavel Majer
# verze: 1
###################################################################################################################

#nastaveni kombinaci m, n
  dvojice = [[10,50000],[40, 10000], [160,2000], [640,200], [2560,20], [10240,5]]
  #dvojice = [[10240,5],[2560,20],[640,200],  [160,2000], [40, 10000], [10,50000]]
  #dvojice = [[1024000,2] ]

#nacteni knihoven
  require "benchmark"
  require_relative "quicksort"
  require_relative "insertion_sort"
  require_relative "hrabisort"

#metody
def print_header(name)
  puts
  puts
  @MARGIN = 15
  row="#{name}"# m".ljust(@MARGIN)
 # p "#{name}"

  print "# m".ljust(@MARGIN)
  print "K1".ljust(@MARGIN)
  print "K2".ljust(@MARGIN)
  print "K3".ljust(@MARGIN)
  print "insert".ljust(@MARGIN)
  print "quick".ljust(@MARGIN)
  puts
  puts "-" * @MARGIN * 6
end

#Promenne
  res=[]
  zacatek=Time.now

#pro dvojice m,n provede vyrobu pole poli, zalohu, obnovu ze zalohy, sortovani peti zpusoby, zmereni
dvojice.each_with_index do |mn, m|
  #0) priprava pomocne promenne/pole na vysledky - pro kazde m vyrobi nove pole poli
    res[m]=[]
    res[m][0]=mn[0]
    res[m][1]=mn[1]
    res[m][2]=[]      #vlozene pole na vysledky pro danou kombinaci
    res_cur_pos=0

  puts
  print  "zpracovavam dvojici #{mn}:"
  #p "1) priprava pole  n poli delky mn=#{mn} - hrabicky"
    #priklad: [10,5] =>> [[1, 3, 5, 6, 7, 7, 8, 8, 8, 9], [1, 2, 4, 4, 5, 6, 8, 8, 8, 9], [1, 3, 5, 6, 7, 7, 8, 8, 9, 9], [1, 2, 2, 2, 3, 3, 4, 4, 6, 6], [1, 2, 3, 3, 3, 3, 4, 4, 6, 7]]
    pole_orig=[]
    mn[1].times do |cntr|   #vytvorte n poli velikosti m -- velikost m=mn[0]
      pole_orig[cntr] = Array.new(mn[0]) {rand (1..(mn[0])-1)}  #vyrobi pole poli podle nastaveni. n poli velikosti m s hodnotou 0..m-1 -- pozor zmena -- nesmysl mit 10k poli s 5 cisly
    end

  #zjisteni nejhorsi/nejrychlejsi varianty (pro dalsi vyzkumy)
    #p "predsort - zjisteni max/min - predtrideni tak, aby cislo zacinalo nejvyssim"
    #p pole_orig
    #pole_orig.each do |policko|
    #  policko.quicksort!.reverse!
    #end
    #p pole_orig

  #p "2. (K1..K3)) pro kazdy algoritmus zduplikovat pole, aby byla data porovnatelna napric ruznymi sortovacimi algoritmy"
  (1..3).each do |cur_hs_k|
    pole = Marshal.load( Marshal.dump( pole_orig ) )
    #p "3) zavolani hrabisort K#{cur_hs_k}"
      print " K#{cur_hs_k} "
      time = Benchmark.realtime do
        pole.each do |policko|
          policko.hrabisort!(cur_hs_k)
        end
      end

    #puts "4) pridani do results #{time}"
      res[m][2][res_cur_pos]=time                        #zapis casu na pozici m(10,40...) a 2 (t.j. pole v poli)
      res_cur_pos+=1                                     #zvednu pocitadlo pro dalsi mereni
      print "(#{time}),"
  end

  print " insert sort"
    pole = Marshal.load( Marshal.dump( pole_orig ) )   #kopie ze zalohy
    time = Benchmark.realtime do                       #mereni
      pole.each do |policko|
        policko.insertion_sort!
      end
    end
    res[m][2][res_cur_pos]=time                       #zapis casu na pozici m(10,40...) a 2 (t.j. pole v poli)
    res_cur_pos+=1                                    #zvednu pocitadlo pro dalsi mereni
    print "(#{time}),"

  print " quick sort"
    pole = Marshal.load( Marshal.dump( pole_orig ) )  #kopie ze zalohy
    time = Benchmark.realtime do                      #mereni
      pole.each do |policko|
        policko.quicksort!
      end
    end
    res[m][2][res_cur_pos]=time                      #zapis casu na pozici m(10,40...) a 2 (t.j. pole v poli)
    res_cur_pos+=1                                   #zvednu pocitadlo pro dalsi mereni
    print "(#{time})"
end

#vse setrideno, vypis vysledku cas celkem
 #   @MARGIN=15
 #   print_header ("t(alg)")
 #   res.length.times do |i|
 #     print "%-15s" % "#{res[i][0]}"
 #     res[i][2].length.times do |val|
 #       printf "%-15.2E" % res[i][2][val]
 #     end
 #     puts
 #   end

#vypis vysledku t(alg) cas celkem / n (pokratime poctem mereni)
  File.open("times.txt","w") do |file|
    file.puts "t(alg)/n"
    file.puts "# m            K1             K2             K3             insert         quick"
    file.puts "------------------------------------------------------------------------------------------"

    res.length.times do |i|
      m=res[i][0]
      n=res[i][1]
      row="#{"%-15s" % m}"
      res[i][2].length.times do |val|
        row="#{row}#{"%-15.2E" % ( res[i][2][val] / n)}"    #pridani hodnoty na radku
      end
      file.puts ( row )          #zapsat vytvorenou radku na disk
    end
  end

  #vypis vysledku t(alg)/mlogm -
  #v idealnim pripade s narustem cisel porosteme o mlogm - graf ukaze o kolik rosteme vic - pokus vydelim mlogm, a primka je vodorovna pak s narustajicimi elementy roste primeren)
  File.open("ratios.txt","w") do |file|
      file.puts "t(alg)/m*log(m)"
      file.puts "# m            K1             K2             K3             insert         quick"
      file.puts "------------------------------------------------------------------------------------------"

    #vytvor radky do reportu
      res.length.times do |i|
      m=res[i][0]
      n=res[i][1]
      mlogm=n*m*Math.log(m)
      row="#{"%-15s" % m}"
      res[i][2].length.times do |val|
      row="#{row}#{"%-15.2E" % ( res[i][2][val] / mlogm)}"    #pridani hodnoty na radku
      end
      file.puts ( row )                                       #zapsat vytvorenou radku na disk
    end
  end

 # vypis celkoveho casu vsech mereni
   puts "vystupy: ratios.txt a times.txt"
   puts "celkovy cas byl #{'%.0f' %  (Time.now-zacatek)}s"

