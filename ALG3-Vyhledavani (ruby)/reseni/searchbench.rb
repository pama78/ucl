###################################################################################################################
# jmeno: searchbench.rb
# ucel:  zmerit narocnost pridavani elementu do sa/ua/bst
# autor: Pavel Majer
# verze: 1
# informace: 
# Spusteni:   standardni spusteni z ruby, externi parametry nejsou treba
# Nastaveni:  lze nastavit 
#               ruzne dvojice (v parametru dvojice), 
#               pocet mereni (v parametru pocet_pereni)
#               nahodna cisla (v parametru nahodna cisla)
###################################################################################################################

#nastaveni kombinaci m, n
  dvojice = [[10,50000],[50,10000],[100,5000],[500,1000],[1000,100], [5000,10]]  # m velikost pole a ciselne omezeni, n=pocet opakovani
  pocet_mereni=10
  nahodna_cisla="A"  #A/N

#nacteni knihoven
  require "benchmark"
  require_relative "binary_search_tree"
  require_relative "sorted_array"
  require_relative "unsorted_array"

#promenne
  res={}

resb={}
   counts_uai={}
   counts_sai={}
   counts_bsti={}
   counts_uad={}
   counts_sad={}
   counts_bstd={}

#pomocne funkce
  def median(arr)
    stred = arr.length / 2
    pole = arr.sort
    if pole.length % 2 == 1
      return pole[stred]
    else
      return ((pole[stred] + pole[stred-1] ) /2.to_f)
    end
  end

# 10násobné opakování
  pocet_mereni.times do |iter|
     # pro každou dvojici (M, N)
     # # vygenerování polí
     #1 Vytvo?te N polí velikosti M. Každé z polí bude obsahovat M náhodných hodnot z rozmezí 0 až (M?1). Tato pole budou obsahovat prvky do struktur vkládané.
     #2 Vytvo?te (dalších) N polí velikosti M. Každé z polí bude obsahovat M náhodných hodnot z rozmezí 0 až (M?1). Tato pole budou obsahovat prvky ve strukturách hledané.
     #3.Vytvo?te (dalších) N polí velikosti M. Každé z polí bude obsahovat M náhodných hodnot z rozmezí 0 až (M?1). Tato pole budou obsahovat prvky ze struktur mazané.
     dvojice.each_with_index do |mn, i|
        #0) priprava pomocne promenne/pole na vysledky - pro kazde m vyrobi nove pole poli
        #priklad: [10,5] =>> [[1, 3, 5, 6, 7, 7, 8, 8, 8, 9], [1, 2, 4, 4, 5, 6, 8, 8, 8, 9], [1, 3, 5, 6, 7, 7, 8, 8, 9, 9], [1, 2, 2, 2, 3, 3, 4, 4, 6, 6], [1, 2, 3, 3, 3, 3, 4, 4, 6, 7]]
        m=mn[0]
        n=mn[1]
        puts "Zpracovavam dvojici #{mn} v iteraci #{iter}"

        #inicializace
        res[mn] ||= []          #asociativni multidimensionalni pole pro vysledky, vytvori jenom kdyz neexistuje
        resb[mn] ||= []
        counts_uai[mn] ||= []
        counts_sai[mn] ||= []
        counts_bsti[mn] ||= []
        counts_uad[mn] ||= []
        counts_sad[mn] ||= []
        counts_bstd[mn] ||= []

        #vyroba nahodnych cisel pro kombinaci m,n
        pole_vkl=[]
        pole_hl=[]
        pole_maz=[]
        n.times do |cntr|                                     #vytvorte n poli velikosti m -- velikost m=mn[0]
          if nahodna_cisla=="A"                               #pro overeni interpol searchu - proc je pomalejsi nez binary
            pole_vkl[cntr] = Array.new(m) {rand (0..(m-1))}   #vyrobi n poli velikosti m s hodnotou 0..m-1 na vkladani
          else
            pole_vkl[cntr] = (0..(m-1)).to_a
          end
          pole_hl[cntr]  = Array.new(m) {rand (0..(m-1))}   #vyrobi n poli velikosti m s hodnotou 0..m-1 na hledani
          pole_maz[cntr] = Array.new(m) {rand (0..(m-1))}   #vyrobi n poli velikosti m s hodnotou 0..m-1 na mazani
        end

        #4. Vytvo?te N prázdných instancí UnsortedArray.
        #5. Vytvo?te N prázdných instancí SortedArray.
        #6. Vytvo?te N prázdných instancí BinarySearchTree.
        pole_ua=[]
        pole_sa=[]
        pole_bst=[]

        n.times do |nt|
           pole_ua[nt] = UnsortedArray.new
           pole_sa[nt] = SortedArray.new
           pole_bst[nt] = BinarySearchTree.new
        end

        #7. V cyklu pro i od 0 do (N?1) vložte všech M hodnot z i-tého pole z bodu 1 do i-té instance UnsortedArray z bodu 4. Zm??te, jak dlouho tento celý cyklus potrvá.
        # cyklus p?es N a M
        elapsed_uai = Benchmark.realtime do
          n.times do |ni|
            m.times do |mi|
              pole_ua[ni].insert(pole_vkl[ni][mi])
            # puts "sleep"
            end
          end
        end
        n.times { |ni| counts_uai[mn] << pole_ua[ni].to_a.length }

        #8. V cyklu pro i od 0 do (N?1) vložte všech M hodnot z i-tého pole z bodu 1 do i-té instance SortedArray z bodu 5. Zm??te, jak dlouho tento celý cyklus potrvá.
        elapsed_sai = Benchmark.realtime do
          n.times do |ni|
            m.times do |mi|
              pole_sa[ni].insert(pole_vkl[ni][mi])
              #sleep 0.1
            end
          end
        end
        n.times { |ni| counts_sai[mn] << pole_sa[ni].to_a.length }  ##mereni poctu vlozenych

        #9. V cyklu pro i od 0 do (N?1) vložte všech M hodnot z i-tého pole z bodu 1 do i-té instance BinarySearchTree z bodu 6. Zm??te, jak  dlouho tento celý cyklus potrvá
        elapsed_bsi = Benchmark.realtime do
          n.times do |ni|
            m.times do |mi|
              pole_bst[ni].insert(pole_vkl[ni][mi])
            end
          end
        end

        #mereni poctu vlozenych
        n.times do |ni|
          bst_tmp=pole_bst[ni].to_s.split(/[(,)]/)                   #rozrezu podle zavorek a carek
          counts_bsti[mn] << bst_tmp.grep(/\d+/).length              #vytahnu jen cisla a spocitam
        end

        #10. V cyklu pro i od 0 do (N?1) prove?te vyhledání všech M hodnot z i-tého pole z bodu 2 v i-té instanci UnsortedArray z bodu 4. Zm??te, jak dlouho tento celý cyklus potrvá.
        elapsed_uaf = Benchmark.realtime do
        n.times do |ni|
            m.times do |mi|
              pole_ua[ni].find(pole_hl[ni][mi])
              #sleep 1 OK
            end
          end
        end

        #11. V cyklu pro i od 0 do (N?1) prove?te vyhledání všech M hodnot z i-tého pole z bodu 2 v i-té instanci SortedArray z bodu 5.  Zm??te, jak dlouho tento celý cyklus potrvá (a) pro binární vyhledávání, (b) pro interpola?ní vyhledávání.

        elapsed_safb = Benchmark.realtime do
          n.times do |ni|
            m.times do |mi|
             # pole_sa[ni].find(pole_vkl[ni][mi])
              pole_sa[ni].binary_search(pole_vkl[ni][mi])
             #  p "polesani=#{pole_sa[ni]}"
             #  p "polevkl=#{pole_vkl[ni][mi]}"
            #  p "#{n} #{m} : hledame tolik cisel #{pole_vkl[ni][mi]} v tolika: #{pole_sa[ni]}"
              #sleep 1 funguje dobre
            end
          end
        end

        #p "call pole_vkl[ni][mi]: ni=#{ni} mi=#{mi} "
        #p "cal interpol"
        #cqd=0
        elapsed_safi = Benchmark.realtime do

          n.times do |ni|
            m.times do |mi|
              pole_sa[ni].interpolation_search(pole_vkl[ni][mi])
              #p "#{ni} #{mi} : pole s delkou: #{pole_vkl[ni][mi]} v tolika #{pole_sa[ni]} "
              #sleep 1 funguje dobre
            end
          end
        end
        p "      [m:#{m}, n:#{n}]: interpol_search: #{elapsed_safi}, binsearch: #{elapsed_safb} "

        #12. V cyklu pro i od 0 do (N?1) prove?te vyhledání všech M hodnot z i-tého pole z bodu 2 v i-té instanci BinarySearchTree z bodu 6. Zm??te, jak dlouho tento celý cyklus potrvá.
        elapsed_bsf = Benchmark.realtime do
          n.times do |ni|
            m.times do |mi|
              pole_bst[ni].find(pole_hl[ni][mi])
              #sleep 1
            end
          end
        end

        #13. V cyklu pro i od 0 do (N?1) smažte všech M hodnot z i-tého pole z bodu 3 v i-té instanci UnsortedArray z bodu 4. Zm??te, jak dlouho tento celý cyklus potrvá.
        elapsed_uad = Benchmark.realtime do
          n.times do |ni|
            m.times do |mi|
              pole_ua[ni].delete(pole_maz[ni][mi])
          # sleep 1
            end
          end
        end
        n.times { |ni| counts_uad[mn] << pole_ua[ni].to_a.length } #UAD - mereni poctu po smazani

        #14. V cyklu pro i od 0 do (N?1) smažte všech M hodnot z i-tého pole z bodu 3 v i-té instanci SortedArray z bodu 5. Zm??te, jak dlouho tento celý cyklus potrvá.
        elapsed_sad = Benchmark.realtime do
          n.times do |ni|
            m.times do |mi|
               pole_sa[ni].delete(pole_maz[ni][mi])
            #sleep 1
            end
            end
        end
        n.times { |ni| counts_sad[mn] << pole_sa[ni].to_a.length } #SAD - mereni poctu po smazani

        #15. V cyklu pro i od 0 do (N?1) smažte všech M hodnot z i-tého pole z bodu 3 v i-té instanci BinarySearchTree z bodu 6. Zm??te, jak dlouho tento celý cyklus potrvá.
        elapsed_bsd = Benchmark.realtime do
          n.times do |ni|
            m.times do |mi|
              pole_bst[ni].delete(pole_maz[ni][mi])
          #   sleep 1
            end
          end
        end

        #BSTD - mereni poctu po smazani
        n.times do |ni|
          bst_tmp=pole_bst[ni].to_s.split(/[(,)]/)               #rozrezu podle zavorek a carek
          counts_bstd[mn] << bst_tmp.grep(/\d+/).length          #vytahnu jen cisla a spocitam
        end

       #vlozeni vysledku do pomocne promenne res pro dalsi analyzu
       #resb[mn] << [elapsed_uai, elapsed_sai, elapsed_bsi, elapsed_uaf, elapsed_safb, elapsed_safi, elapsed_bsf, elapsed_uad, elapsed_sad, elapsed_bsd ]
       res[mn] << [elapsed_uai/n, elapsed_sai/n, elapsed_bsi/n, elapsed_uaf/n, elapsed_safb/n, elapsed_safi/n, elapsed_bsf/n, elapsed_uad/n, elapsed_sad/n, elapsed_bsd/n ]

        p "      #{mn}: #{res[mn]}"
        elapsed_uai=""
        elapsed_sai=""
        elapsed_bsi=""
        elapsed_uaf=""
        elapsed_safb=""
        elapsed_safi=""
        elapsed_bsf=""
        elapsed_uad=""
        elapsed_sad=""
        elapsed_bsd=""
     end
  end #konec velkeho 10times loopu


## vypocet prumeru casu
prum={}
med={}
res.keys.each do |mn|                    #pro kazdy klic z listu (10,50...)
  m=mn[0]
  n=mn[1]
  prum[m]=[0,0,0,0,0,0,0,0,0,0]          #inicializace promenne pro prumery, slo by vylepsit, aby bylo dynamicke pro vic vypoctu
  med[m]=[]                              #inicializace
  #p "keys #{m} #{n}:\n-----------------"
  10.times do |i|                        #10 sloupcu, 10 iteraci, do budoucna jde dynamicky, zmena sloupcu by ale stejne znamenala kodovani na vice mistech
    med_tmp=[]                           #vycisteni docasne promene med pro mediany
    pocet_mereni.times do |pos|          #10, nebo X iteraci (zalezi, kolikrat se bude merit)
      prum[m][i]+=res[mn][pos][i]        #secteni vsech casu pro kazdou operaci (vcetne pocet_mereni)
      med_tmp << res[mn][pos][i]         #odkladani hodnot pro vypocet medianu
    end
    med[m][i]=median(med_tmp)/m
    prum[m][i]= prum[m][i] / pocet_mereni / m
  end
end


#zapis AVG
File.open("times_avg.txt","w") do |file|
  #  file.puts "# m       UA_insert  SA_insert  BST_insert SA_delete  SA_delete  BST_delete"
  file.puts "# m       UA_insert  SA_insert  BST_insert UA_search  SA_binarys SA_interps BST_Search UA delete SA_delete BST_delete"
  file.puts "----------------------------------------------------------------------------------------------------------------------"
  puts "\nPRUMER"
  puts "# m       UA_insert  SA_insert  BST_insert UA_search  SA_binarys SA_interps BST_Search UA delete SA_delete BST_delete"
  puts "----------------------------------------------------------------------------------------------------------------------"
  prum.keys.each do |key|
    row="#{"%-10s" % key}"
    prum[key].length.times do |pos|
      row="#{row}#{"%-11.2E" % prum[key][pos]}"
    end
    puts row
    file.puts ( row )
  end
end

#zapis MED
File.open("times_med.txt","w") do |file|
  file.puts "# m       UA_insert  SA_insert  BST_insert UA_search  SA_binarys SA_interps BST_Search UA delete SA_delete BST_delete"
  file.puts "----------------------------------------------------------------------------------------------------------------------"
  puts "\nMEDIAN"
  puts "# m       UA_insert  SA_insert  BST_insert UA_search  SA_binarys SA_interps BST_Search UA delete SA_delete BST_delete"
  puts "----------------------------------------------------------------------------------------------------------------------"
  med.keys.each do |key|
    row="#{"%-10s" % key}"
    med[key].length.times do |pos|
      row="#{row}#{"%-11.2E" % med[key][pos]}"
    end
    puts row
    file.puts ( row )
  end
end


#vypocet counts
File.open("counts.txt","w") do |file|
  file.puts "# m       UA_insert  SA_insert  BST_insert UA delete  SA_delete  BST_delete"
  file.puts "----------------------------------------------------------------------------------------------------------------------"
  puts "\nCOUNTS"
  puts "# m       UA_insert  SA_insert  BST_insert UA delete  SA_delete  BST_delete"
  puts "----------------------------------------------------------------------------------------------------------------------"
  res.keys.each do |mn|
    m=mn[0]
    #n=mn[1] tadz
    row="#{"%-10i" % m}#{"%-11.1f" % median(counts_uai[mn])}#{"%-11.1f" % median(counts_sai[mn])}#{"%-11.1f" % median(counts_bsti[mn])}#{"%-11.1f" % median(counts_uad[mn])}#{"%-11.1f" % median(counts_sad[mn])}#{"%-11.1f" % median(counts_bstd[mn])}"
    puts row
    file.puts ( row )
  end
end
