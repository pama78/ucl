
class Store
  attr_reader :products

  def initialize
    @products = {} # asociativni pole, klicem je kod produktu, hodnotou mnozstvi
  end

  def add_product(code, amount)
    # 1. Overte korektnost predanych dat (existence produktu s danym kodem v databazi produktu,
    #    povolene mnozstvi). V pripade chyby vyvolejte vyjimku.
    # 2. Pridejte do asociativniho pole @products pod danym kodem dane mnozstvi.
    #Produkty jsou op?t popisovány elementy product. Atribut code se odkazuje na kód produktu z databáze produkt?. Atribut amount ur?uje aktuální množství
    #produktu na sklad?. Na data máme následující omezení:
    #1. Pro daný produkt musí existovat (platný) záznam v databázi produkt?.
    #2. Po?et kus? musí být kladné ?íslo (skute?n? kladné ?íslo, nulu nedovolujeme).
    #Údaje o jakémkoliv produktu porušující n?které z t?chto pravidel považujeme za neplatné.
    #Situace, kdy pro n?jaký produkt vyskytující se v databázi nemáme ve stavu skladu žádný záznam, je zcela korektní: vyjad?uje, že produkt v
    #sou?asné dob? není dostupný.

    # p "v add_product #{code} #{amount}"
    if Product.get(code) == nil
      p "CHYBA pri nacitani produktu do skladu z <#{ARGV[1]}>. Produkt #{code} neexistuje v DB produktu."
    else
      unless amount.match('^[0-9]+$')
        p "CHYBA pri nacitani produktu do skladu z <#{ARGV[1]}>. Produkt <#{code}> ma mnozstvi, ktere se ma pridat na sklad musi byt kladne cele cislo, ale je #{amount}."
      else
        @products[code] = amount.to_i
         #p "produkty jsou #{@products}"
      end
    end
  end

  def sell_product(code, amount)
    # 1. Overte dostatecne mnozstvi produktu na skladu. V pripade chyby vyvolejte vyjimku.
    # 2. Snizte mnozstvi produktu na skladu o hodnotu amount.
    #Program podle kódu produktu a požadovaného množství zjistí, zda máme produktu dostate?né množství na skladu. Pokud ano, ode?te požadované
    # množství od stavu skladu (tím považujeme položku objednávky za vy?ízenou). Pokud ne, program na situaci nedostate?ného množství produktu
    # upozorní.  Program uloží výsledný stav skladu.Program uloží databázi zákazník?.
    na_sklade=@products[code]
   # pama

    unless amount.match('^[\d]*$')
      p "pozadovane mnozstvi produktu #{code} neni cele kladne cislo. Pozadovano <#{amount}>."
      return 3
    end

      if na_sklade < amount.to_f
      p "na sklade neni dostatek produktu #{code}. Pozadovano #{amount} je mene nez je na sklade #{na_sklade}. "
      return 2
    end

    @products[code] = (na_sklade - amount.to_i)
   # p "debug: novy stav skladu pro polozku #{code} je #{@products[code]}"
    return 0
  end
end
