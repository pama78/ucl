class Product
  # Tridni promenna @@products slouzi zaroven jako databaze produktu.
  # Jedna se o asociativni pole, kde klicem je vzdy kod produktu a hodnotou objekt produktu samotny.
  @@products = {}

  attr_reader :code, :name, :price

  def initialize(code, name, price)
    # 1. Overte korektnost dat predanych konstruktoru. V pripade chyby vyvolejte vyjimku.
    # 2. Naplnte instancni promenne.
    # 3. Pridejte self do databaze produktu @@products
      @code = code
      @name = name
      @price = price

     #VALIDACE:
     #Kód produktu musí mít následující tvar. Za?íná velkým písmenem z množiny {P, Q, R, S, T}, pokra?uje velkým písmenem z množiny {A, E, I, O, U} a
     # kon?í ?íslem v rozsahu 001-450.
     ##slo by vylepsit, rozpadnout 001-450 do regulerniho vyrazu, bylo by to zdlouhavejsi a hure upravitelne do budoucna
     #unless @code.match('[PQRST][AEIOU]([0-4][0-9][0-9])')
      val_errs=0
      if @code.match('^[PQRST][AEIOU][\d][\d][\d]$')  ##TBD 000-449 -- pridat limit 001, a 450 TBD
         if @code[2..4].to_i > 451 or @code[2..4].to_i == 0
           p "CHYBA pri nacitani seznamu produktu z <#{ARGV[0]}>. ciselna cast produktu <#{@code}> neni v rozmezi 001-450"
           val_errs+=1
         end
      else
        p "CHYBA pri nacitani seznamu produktu z <#{ARGV[0]}>. Kod produktu <#{@code}> neodpovida masce [PQRST][AEIOU][trimistne cislo]"
        val_errs+=1
      end

     #Kód produktu musí být unikátní.
      if Product.get(@code) != nil
        p "CHYBA pri nacitani seznamu produktu z <#{ARGV[0]}>. Produkt <#{name}>, ma kod <#{code}>, ktery existuje ve vstupnim souboru vicekrat."
        val_errs+=1
      end

    #Cena musí být kladné ?íslo. (predpoklad, muze byt i desetinne, a nesmi byt 0)
      if !( @price.match('^[0-9]*$|^[0-9]*\.[0-9]*$')) || @price.to_i==0
        p "CHYBA pri nacitani seznamu produktu z <#{ARGV[0]}>. Produkt <#{code}> <#{name}> ma chybnou cenu <#{@price}>"
        val_errs+=1
      end

      if val_errs == 0
        @@products[@code] = self
      end

  end

  #def Product.get(code)
  def Product.get(code)
    return @@products[code]
  end
end
