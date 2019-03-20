
class Store
  attr_reader :products

  def initialize
    @products = {} # asociativni pole, klicem je kod produktu, hodnotou mnozstvi
  end

  def add_product(code, amount)
    # 1. Overte korektnost predanych dat (existence produktu s danym kodem v databazi produktu,
    #    povolene mnozstvi). V pripade chyby vyvolejte vyjimku.
    # 2. Pridejte do asociativniho pole @products pod danym kodem dane mnozstvi.
    #Produkty jsou op?t popisov�ny elementy product. Atribut code se odkazuje na k�d produktu z datab�ze produkt?. Atribut amount ur?uje aktu�ln� mno�stv�
    #produktu na sklad?. Na data m�me n�sleduj�c� omezen�:
    #1. Pro dan� produkt mus� existovat (platn�) z�znam v datab�zi produkt?.
    #2. Po?et kus? mus� b�t kladn� ?�slo (skute?n? kladn� ?�slo, nulu nedovolujeme).
    #�daje o jak�mkoliv produktu poru�uj�c� n?kter� z t?chto pravidel pova�ujeme za neplatn�.
    #Situace, kdy pro n?jak� produkt vyskytuj�c� se v datab�zi nem�me ve stavu skladu ��dn� z�znam, je zcela korektn�: vyjad?uje, �e produkt v
    #sou?asn� dob? nen� dostupn�.

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
    #Program podle k�du produktu a po�adovan�ho mno�stv� zjist�, zda m�me produktu dostate?n� mno�stv� na skladu. Pokud ano, ode?te po�adovan�
    # mno�stv� od stavu skladu (t�m pova�ujeme polo�ku objedn�vky za vy?�zenou). Pokud ne, program na situaci nedostate?n�ho mno�stv� produktu
    # upozorn�.  Program ulo�� v�sledn� stav skladu.Program ulo�� datab�zi z�kazn�k?.
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
