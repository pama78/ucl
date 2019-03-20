###################################################################################################################
# jmeno: hrabisort.rb
# ucel:  druh sortovani podle hrabicek. zpusob je podobny shellsortu
#        podle parametru K se vypocita k (rozpeti hrabicek)
#        sortovani hrabisort! pak rychle presune velke hodnoty na velke vzdalenosti - a zrychli se tim klasicky insert sort
#
# autor: Pavel Majer
# verze: 1
###################################################################################################################


class Array
  def hrabisort!(ktype = 1)
    #ktype definovan
      delka=self.length  #pouzita pro vypocet k
      pozice=1           #startovaci pozice pro vypocet k
      i=1                #pouzite ve vzorcich pro vypocet k
      ksa=[]             #pole, ktere bude drzet vzdalenost hrotu hrabicek
      mv_cntr=0          #pocitadlo presunu = pro analyzu slozitosti

    #podle parametru K a delky pole vypocitam ruzne k
      case ktype
      when 1
        while pozice <= delka/2 do
          delka = delka/2
          ksa << delka
        end
      when 2
        while pozice <= (delka/3) do
          i+=1
          ksa << pozice
          pozice = ((3**i)-1)/2
        end
        ksa=ksa.reverse   #zmena poradi, pri trideni jedu pak od nejvetsiho po nejmensi
      when 3              #K3 => k=2^r*3^s
        r=0
        q=0
        pozice=0
        while true do                  #r zustava, q loopuje
          while true  do               #mohlo by byt pozice < delka, ale podminka je resena breakem
             pozice=((2**r)*(3**q))    #vypocet vsech moznych kombinaci 2^0 * 3^0 .. 2^r * 2^q
             break if pozice > delka   #pri dosazeni delky konec inner loopu, a zveda se r
             ksa << pozice             #zapis hodnoty do pole s hroty
             q+=1
          end
          r+=1
          q=0
          pozice=0
          break if 2**r > delka       #v bode, kdyz samostany 2^r > delka uz loop musi skoncit
        end
        ksa=ksa.sort.reverse    #zmena poradi, pri trideni jedu pak od nejvetsiho po nejmensi
    else
      p "Hrabickovy typ trideni muze byt jen 1,2,3 a bylo poslano: #{ktype}. koncim program"
      exit
    end
    #p "ksa(#{ktype})=#{ksa}"
    #zacatek hrabickoveho trideni pro danou skupinu k (vychazi z insertion sortu, se zamenou 1 za cur_k)
    ksa.each do |cur_k|
    cur_k.upto(self.size - 1) do |i|
      item = self[i]
      j = i - cur_k
      while j >= 0 && self[j] > item    ## dokud na posunutem miste neni mensi nebo rovno, a zaroven j neni nula
        self[j + cur_k] = self[j]
        j -= cur_k
        mv_cntr += 1
      end
      self[j + cur_k] = item
    end
      end
      #p "hrabisort(#{ktype}): pocet zubu #{ksa.length}, velikost pole:#{self.length} presunu provedeno: #{mv_cntr}"
     return self
end
end

