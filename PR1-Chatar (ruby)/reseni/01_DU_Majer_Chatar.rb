###############################################################################################################################################
#Aplikace: Chatar 1526
#Predmet:  Programování 1, DU1, Ruby
#Vlastnik: Pavel Majer
#
#Zadani:   Stali jste se chatařem v roce 1526. Vaším úkolem je přežít. Vaše chata se nachází uprostřed lesa. Už začíná zima a venku je čím dál chladněji. V roce 1526 ještě nebyly
#          počítače, takže jsou vaše možnosti omezené. Jako chatař můžete totiž pouze jít pokácet strom, nařezat kládu na polena, jít spát, nebo vzdát svůj život (a ukončit naši
#          simulaci). A aby vaše kácení či řezání mělo nějakou motivaci, tak tím důvodem proč to jako chatař děláte je, že nechcete umrznout. Každý den totiž můžete vykonat pouze
#          jednu akci. A každý den hladový krb spálí jedno poleno. Běda když polena dojdou, pak umrznete a simulace skončí.
#
#Reseni:   trida Sklad, s parametry klady a polena a funkcemi pokacet_strom, narezat_klady, palit_poleno
#          funkce fn_menu, ktera je volana ve smycce, a pricita den po kazde akci
###############################################################################################################################################

#CLASSES
class Sklad
  attr_accessor :klady, :polena

  def narezat_klady()
   # Když hráč zvolí tuto možnost, simulace zkontroluje, zda jsou k dispozici klády k nařezání. Pokud nejsou, zobrazí hráči text
   # "V kůlně nejsou žádné klády k řezání". Pokud v kůlně nějaké klády jsou, pak simulace vygeneruje náhodné číslo od 2 do 5. Toto číslo určí, kolik klád se podařilo hráči nařezat.
   # Z každé klády vzniknou 2 polena. Zde však musíme dát pozor na situaci, kdy bude naše vygenerované náhodné číslo například 3, ale v kůlně máme pouze dvě klády. V takovém případě
   # hráč nařeže pouze dvě a ne tři klády a získá tedy 4 polena. Po nařezání polen, bude hráči zobrazen text "Nařezal jsi X klád na Y polen". Polena jsou následně uložena do kůlny.
   if  ( @klady == 0 )
      #dosly klady
      puts "V kulne nejsou zadne klady k rezani."
      return
    else
      #klady jsou
      klady_k_rezani = rand(2 .. 5)
      #puts "V kulne je #{@klady} ks klad k rezani. Chci narezat #{klady_k_rezani} "
      if   klady_k_rezani > @klady
        #klady jsou ale je jich malo [10, 4].min
        klady_k_rezani = @klady
      end
      @klady -= klady_k_rezani
      narezana_polena = (klady_k_rezani *2)
      @polena += narezana_polena

      #koncovka pro klady
      case klady_k_rezani
        when 1 ; koncovka1 = "u"
        when 2, 3, 4 ; koncovka1 = "y"
        else koncovka1 = ""
      end

      #koncovka pro polena
      case narezana_polena
        when 1 ; koncovka2 = "o"
        when 2, 3, 4 ; koncovka2 = "a"
        else koncovka2 = ""
      end

      puts "Narezal jsi #{klady_k_rezani} klád#{koncovka1} na #{narezana_polena} polen#{koncovka2}"
   end
  end
  def pokacet_strom()
    #Když hráč zvolí tuto možnost, simulace vygeneruje náhodné číslo (= počet klád, které hráč v této akci pokácel) a vypíše text
    #"Sel si na drevo, pokacel si 3 stromy, mas z nich 3 klady". Klády jsou přidány k již uloženým kládám v kůlně. Při jednom kácení může hráč pokácet 2-4 stromů,
    # tedy získat 2-4 klády.
    stromy_ke_kaceni = rand(2 .. 4)
    @klady += stromy_ke_kaceni
    puts "Sel si na drevo, pokacel si #{stromy_ke_kaceni} stromy, mas z nich #{stromy_ke_kaceni} klady."
  end
  def palit_poleno()
    #spalit poleno kazdy den. Pokud není jaké poleno spálit, program hráči oznámí, že umrzl a simulace končí.
    if @polena < 1
      puts "\nUz nejsou zadna polena, umrzl jsi, simulace konci."
      exit 0
    else
      puts "\nUplynul den a spalil si jedno poleno.\n"
     @polena -= 1
    end

  end

end


#FUNCTIONS
def fn_menu(v_den)
  #koncovka pro klady
  case Chatar1_sklad.klady
    when 1 ; koncovka1 = "u"
    when 2, 3, 4 ; koncovka1 = "y"
    else koncovka1 = ""
  end

  #koncovka pro polena
  case Chatar1_sklad.polena
    when 1 ; koncovka2 = "o"
    when 2, 3, 4 ; koncovka2 = "a"
    else koncovka2 = ""
  end

  puts "\n------------------------------------------------------------"
  puts "Je #{v_den}. den. V kulne mas #{Chatar1_sklad.klady} klad#{koncovka1} a #{Chatar1_sklad.polena} polen#{koncovka2}."
  puts "\nCo udelas?\n1) Pokacet strom\n2) Narezat kladu na polena\n3) Jit spat\n4) Vzdat zivot (a ukoncit simulaci)

  Tva volba:"
  i_volba = gets.strip.to_i

  puts #{Chatar1_sklad.klady}
  case i_volba
    when 1 ;  Chatar1_sklad.pokacet_strom
    when 2 ;  Chatar1_sklad.narezat_klady
    #Třetí akcí je "Jít spát". V tomto případě jde hráč spát (simulace vypíše text "Sel jsi spat … chrrr chrrr chrrr") aniž něco udělá a probudí se zase další den ráno a může něco udělat.
    when 3 ;  puts "Sel jsi spat."
    #Čtvrtou a zároveň poslední akcí je Ukončit simulaci. Tato akce zkrátka vypíše text "Konec simulace" a ukončí program.
    when 4 ;   puts "Vzdal si svuj zivot a sve usili. Tvůj pomnik bude u chaty stat jeste tisic let!"
               exit 0
    else      puts "\nNeplatny vstup\n"
  end

end


### PRG START ###
v_den = 1
Chatar1_sklad = Sklad.new
Chatar1_sklad.klady = 0
Chatar1_sklad.polena = 3

puts "Vitej v programu Chata 1526! Stal jsi se chatarem v roce 1526, zkus prezit!"
while true do
 fn_menu v_den
 v_den += 1
 Chatar1_sklad.palit_poleno
end


