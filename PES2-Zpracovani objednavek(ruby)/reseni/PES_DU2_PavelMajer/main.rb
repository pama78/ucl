########################################################################################################
# Program:     PES_DU2, zpracovani objednavek
# Ucel:        zpracovani objednavek z xml souboru.
# Autor:       Pavel M.
# Verze:       1
# Detaily k reseni/predpoklady:
#              pri kontrole produktu provadim vice kontrol, nez se objekty prestanu zabyvat, a predpokladam ze by se skladove referencni hodnoty mely opravit na nasi strane
#              u kontroly objednavek vic kontrol neprovadim. u  nich naopak predpokladam, ze je potreba neco opravovat. objednavka se pak pripadne posle znovu
#              pracuji s celymi cisly. odvozuji to z ukazek. (takze nejsou halere, ani mnozstvi polozek s desetinnymi misty)
#              pokud neni dost mnozstvi zbozi na sklade, neodecitam cast z objednavky. bud se odecte pozadovane mnozstvi, nebo nic.
#              vyjimky pisu pouze na obrazovku
#              tridu customer jsem nevyuzil. nevsiml jsem si ji, kdyz jsem zacal resit ukladani adress, pouzil jsem promenne. snad to nebude problem
#              vlozil jsem hodne komentaru, abych se v kodu lepe orientoval, az to otevru zase po nejake dobe.
# Zdroje:      u nekterych veci jsem pouzival informace ze stackoverflow a jinych webovych zdroju. napr u nokogiri, odkaz jsem dal primo do textu
########################################################################################################

#knihovny
  require_relative "product.rb"
  require_relative "store.rb"
  require_relative "customer.rb"
  require_relative "order.rb"
  require "nokogiri"  #pro pouziti, neni ve standardni sade. je potreba doinstalovat
  require "time"

class Shop
  def initialize(arguments)
    # 1. Overte spravne mnozstvi argumentu. V pripade chyby vyvolejte vyjimku.
    # 2. Ulozte si argumenty do vhodnych promennych pro pozdejsi pouziti
    if ARGV.length < 5
      puts "CHYBA: nedostatek parametru programu. \nOcekavaji se tyto parametry: products store orders store_out customers_out"
      exit
    end
    @PRODUCTS_XML = ARGV[0]
    @STORE_XML = ARGV[1]
    @ORDERS_XML = ARGV[2]
    @STORE_OUT_XML = ARGV[3]
    @CUST_OUT_XML = ARGV[4]
    @vsechny_adresy=[]
  end

  def load_products
    # 1. Nactete XML soubor s produkty. V pripade problemu (napr. neexistujici soubor) vyvolejte vyjimku.
    # 2. Prochazejte XML soubor a vytvarejte nove objekty tridy Produkt. Nezapomente odchytavat vyjimky.
    #products=[]
    unless File.exist?(@PRODUCTS_XML)
      puts "CHYBA: Vstupni soubor <#{@PRODUCTS_XML}> neexistuje!"
      exit
    end

    File.open(@PRODUCTS_XML,"r") do |file|
      doc = Nokogiri::XML::Document.parse(file)
        doc.root.xpath("/products/product").each do |el_product|
        el_p_code = el_product["code"]                            #pristupujeme podobne jako k poli =
        el_p_name = el_product.at_xpath("name").content           #kdyz chci jeden element, zavolam metodu at_xpath, ziskani textoveho obsahu = content
        el_p_price = el_product.at_xpath("price").content
        #puts "code: #{el_p_code}, name: #{el_p_name} price: #{el_p_price}"
        @product = Product.new(el_p_code, el_p_name, el_p_price)
      end
    end
  end

  def load_store
     @store = Store.new
     # 1. Nactete XML soubor se stavem skladu. V pripade problemu (napr. neexistujici soubor) vyvolejte vyjimku.
     # 2. Prochazejte XML soubor a volejte @store.add_product.
     unless File.exist?(@STORE_XML)
       puts "CHYBA: Vstupni soubor <#{@STORE_XML}> neexistuje!"
       exit
     end

     File.open(@STORE_XML,"r") do |file|
        doc = Nokogiri::XML::Document.parse(file)
        doc.root.xpath("/store/product").each do |el_product|
          el_s_code = el_product["code"]                            #pristupujeme podobne jako k poli =
          el_s_amt = el_product["amount"]
          @store.add_product(el_s_code, el_s_amt)
          ##puts "code: #{el_p_code}, name: #{el_p_name} price: #{el_p_price}"
        end
     end
  end

  def load_orders
    @orders = []
    # 1. Nactete XML soubor s objednavkami. V pripade problemu (napr. neexistujici soubor) vyvolejte vyjimku.
    # 2. Prochazejte XML soubor a pro jednotlive objednavky:
    # 2a. Vytvorte novy objekt tridy Order.
    # 2b. Pro jednotlive polozky objednavky vytvorte novy objekt tridy OrderItem a predejte jej metode add_item.
    # 2c. Pridejte objednavku do pole @orders.

    File.open("orders.xml","r") do |file|
      doc = Nokogiri::XML::Document.parse(file)
      doc.root.xpath("/orders/order").each do |el_order|
        el_o_number = el_order["number"]
        el_o_date = Time.xmlschema(el_order["date"])
        el_o_sh_name = el_order.at_xpath("address[@type='shipping']/name").content
        el_o_sh_street= el_order.at_xpath("address[@type='shipping']/street").content
        el_o_sh_city= el_order.at_xpath("address[@type='shipping']/city").content
        el_o_sh_state= el_order.at_xpath("address[@type='shipping']/state").content
        el_o_sh_zip= el_order.at_xpath("address[@type='shipping']/zip").content
        el_o_sh_country= el_order.at_xpath("address[@type='shipping']/country").content
        el_o_sh_address = {"name" => el_o_sh_name, "street" => el_o_sh_street, "city" => el_o_sh_city, "state" => el_o_sh_state, "zip" => el_o_sh_zip, "country" => el_o_sh_country}

        el_o_bl_name = el_order.at_xpath("address[@type='billing']/name").content
        el_o_bl_street= el_order.at_xpath("address[@type='billing']/street").content
        el_o_bl_state= el_order.at_xpath("address[@type='billing']/state").content
        el_o_bl_city= el_order.at_xpath("address[@type='billing']/city").content
        el_o_bl_zip= el_order.at_xpath("address[@type='billing']/zip").content
        el_o_bl_country= el_order.at_xpath("address[@type='billing']/country").content
        el_o_bl_address = {"name" => el_o_bl_name, "street" => el_o_bl_street, "city" => el_o_bl_city, "state" => el_o_bl_state, "zip" => el_o_bl_zip, "country" => el_o_bl_country}

        #p "shipping: #{el_o_sh_name} #{el_o_sh_street} #{el_o_sh_state} #{el_o_sh_zip} #{el_o_sh_country}"
        #p "billing: #{el_o_bl_name} #{el_o_bl_street} #{el_o_bl_state} #{el_o_bl_zip} #{el_o_bl_country}"

        # vlozeni do objednavek
        #p "order.new #{el_o_number}, #{el_o_date}, #{el_o_sh_address}, #{el_o_bl_address}"
          order = Order.new(el_o_number, el_o_date, el_o_sh_address, el_o_bl_address)
          (el_order/'items/item').each do |item|
            #Debug p [item["code"], (item/'./name').text, (item/'./quantity').text , (item/'./price').text ]
            el_o_i_code=item["code"]
            el_o_i_name=(item/'./name').text
            el_o_i_quantity=(item/'./quantity').text
            el_o_i_price=(item/'./price').text.to_i
            el_o_item = OrderItem.new(el_o_i_code, el_o_i_name, el_o_i_price, el_o_i_quantity)
            order.add_item(el_o_item)
          end
          @orders << order
      end
    end
  end

  def process_order(order)
    # Zpracujte objednavku.
    # Prochazejte jednolive polozky objednavky a provadejte zadane kontroly.
    # V pripade, ze je vse v poradku, upravte stav skladu volanim @store.sell_product.
    # Nezapomente si ulozit udaje o zakaznikovi.
    #Program srovná název a cenu produktu z objednávky s názvem a cenou produktu v databázi produkt? (srovnání d?láme na základ? kódu produktu).
    # Pokud se názvy nebo ceny neshodují nebo pokud produkt s daným kódem v databázi produkt? neexistuje, upozorní program na tuto situaci a
    # považuje položku objednávky za neplatnou a dále se jí nezabývá.
    @vsechny_adresy << order.billing_address

    #p order.billing_address
    order.items.each do |ord_item|
     # p "#{ord_item.product_code}, #{ord_item.quantity} "
    store_prod=Product.get(ord_item.product_code)
     if Product.get(ord_item.product_code) == nil
        p "CHYBA v objednavce <#{order.order_number}>. Produktovy kod <#{ord_item.product_code}> a jmeno <#{ord_item.product_name}> neexistuje mezi produkty."
        else
          if store_prod.price.to_i != ord_item.price.to_i
            p "CHYBA v objednavce <#{order.order_number}>. Produktovy kod <#{ord_item.product_code}> ma jinou cenu na sklade a v objednavce. sklad: <#{store_prod.price.to_i}> objednavka: <#{ord_item.price.to_i}>"
          else
            if store_prod.name.strip != ord_item.product_name.strip
              p "CHYBA v objednavce <#{order.order_number}>. Produktovy kod <#{ord_item.product_code}> ma jine jmeno na sklade a v objednavce. sklad: <#{store_prod.name}> objednavka: <#{ord_item.product_name}>"
            else
              ret_val = @store.sell_product(ord_item.product_code, ord_item.quantity)
             # p "#{ord_item.product_code}, #{ord_item.quantity} #{ret_val}"
              if ret_val == 2
                  p "CHYBA v objednavce <#{order.order_number}>. Neni dostatecne mnozstvi produktu <#{ord_item.product_code}> <#{ord_item.product_name}> na sklade "
              elsif ret_val == 3
                p "CHYBA v objednavce <#{order.order_number}>. Pozadovano neocekavane mnozstvi <#{ord_item.quantity}> produktu <#{ord_item.product_code}> <#{ord_item.product_name}> "
              end

            end
          end
        end
     end
  end

  def process_orders
    # Zpracujte objednavky. Zde se deje samotna logika programu, ktera je podrobne popsana v zadani.
    # Seradte objednavky dle data a v poradi od nejstarsi je zacnete zpracovavat volanim metody process_order.
    #Program projde jednotlivé objednávky v po?adí dle data (a ?asu) objednávky (toto po?adí nemusí odpovídat po?adí objednávek ve vstupním souboru)
    # a pro každou vykoná následující kroky.
    # Zapamatuje si údaje o zákazníkovi (z adresy typu „billing“).
     @orders.sort! { |a,b| (a.date <=> b.date) }
     @orders.each do |ord|
       process_order(ord)
     end
    end

  def save_store
    # p @store.products
    # Projdete produkty v @store a ulozte je do XML souboru.
    # zdroj: http://www.rubydoc.info/github/sparklemotion/nokogiri/Nokogiri/XML/Builder
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.store do
            @store.products.each do |product|
              xml.product({"code" => product[0], "amount" => product[1]})
            end
          end
        end

      File.open(@STORE_OUT_XML, "w") do |file|
        file.puts builder.to_xml
      end
  end

  def save_customers
     # Projdete zakazniky ziskane ze zpracovanych zakazek a ulozte je do XML souboru.
     # p @vsechny_adresy
  #   p @vsechny_adresy.uniq!
  #   exit
     # zdroj: http://www.rubydoc.info/github/sparklemotion/nokogiri/Nokogiri/XML/Builder
     builder = Nokogiri::XML::Builder.new do |xml|
       xml.customers do
         @vsechny_adresy.each do |radka|
           break if radka["name"] == nil
           xml.customer({"name" => radka["name"]}) do
             xml.address do
               xml.street(radka["street"]) if radka["street"] != nil
               xml.city(radka["city"])     if radka["city"] != nil
               xml.state(radka["state"])   if radka["state"] != nil
               xml.zip(radka["zip"])       if radka["zip"] != nil
               xml.country(radka["country"]) if radka["country"] != nil
             end
           end
         end
       end
     end

     File.open(@CUST_OUT_XML, "w") do |file|
       file.puts builder.to_xml
     end
  end

  def run
    load_products
    load_store
    load_orders
    process_orders
    save_store
    save_customers
  end
end

shop = Shop.new(ARGV)
shop.run

