require "csv"

class Programmer
  attr_reader :name, :speed, :daily_wage
  attr_accessor :project

  def initialize(name, speed, daily_wage)
    @name = name
    @speed = speed
    @daily_wage = daily_wage
    @project = nil
  end

  # Uvolnit programatora z projektu
  def clear_project
    @project = nil
  end

  # Pracovat na projektu
  def write_code
    @project.receive_work(@speed)
  end

  # Vypise nazev prirazeneho projektu, nebo retezec "nil",
  # kdyz zadny projekt prirazen neni
  def project_name
    return project.nil? ? "nil" : project.name
  end

  # Slouzi pouze pro ladici ucely. Vypise dulezite informace o danem programatorovi.
  def print_debug_info
    puts "Programmer #{name}:"
    puts "\tSpeed: #{speed}"
    puts "\tDaily wage: #{daily_wage}"
    puts "\tProject: #{project_name}"
  end
end

class Project
  attr_reader :name, :man_days, :price
  attr_reader :man_days_done
  attr_accessor :state #moznosti :waiting, :current, :done

  def initialize(name, man_days, price)
    @name = name
    @man_days = man_days
    @man_days_done = 0
    @price = price
    @state = :waiting
  end

  # Prace, kterou programator provede na projektu
  def receive_work(man_days)
    @man_days_done += man_days
  end

  # Slouzi pouze pro ladici ucely. Vypise dulezite informace o danem projektu.
  def print_debug_info
    puts "Project #{name}:"
    puts "\tState: #{state}"
    puts "\tMan-days total: #{man_days}"
    puts "\tMan-days done: #{man_days_done}"
    puts "\tPrice: #{price}"
  end

  # Vrati projekt do vychoziho stavu. Vola se vzdy po provedeni simulace pro jednu firmu.
  # Nikde volani teto metody nemusite pridavat. Je jiz volana v cyklu, ve kterem jsou spousteny
  # simulace pro jednotlive firmy
  def reset
    @state = :waiting
    @man_days_done = 0
  end
end

class Company
  attr_reader :name, :capacity, :daily_expenses, :budget
  attr_reader :days, :programmers
  attr_reader :projects_waiting, :projects_current, :projects_done
  attr_reader :state # moznosti :idle, :running, :finished, :bankrupt

  def initialize(name, capacity, daily_expenses, budget)
    @name = name
    @capacity = capacity
    @daily_expenses = daily_expenses
    @budget = budget
    @state = :idle
    @days = 0
    @projects_waiting = []
    @projects_current = []
    @projects_done = []
  end

  # Nacist vsechny projekty do pole @projects_waiting
  def allocate_projects(projects_array)
    projects_array.each do |proj|
      @projects_waiting << proj
    end
  end

  # Najmout tolik programatoru, kolik cini kapacita
  def allocate_programmers(programmers_array)
    # IMPLEMENTUJTE TUTO METODU
    # Z pole programmers_array vyberte prvnich @capacity programatoru
    # v poradi podle nejvyhodnejsiho pomeru jejich rychlosti proti jejich cene.
    # Nasledne je v tomto poradi vkladejte do pole @programmers.
    programmers_array.sort! { |a,b| a.daily_wage/a.speed <=> b.daily_wage/b.speed }      #sort list
    @programmers = []
    @capacity.times do |i|
      @programmers[i]=programmers_array[i]
      # p programmers_array[i]
    end
    #p @programmers
  end

  # Zjistit ktere projekty jsou uz hotove
  # a presunout je do @projects_done
  def check_projects
    # Nasledujici kod si vyzaduje urcitou pozornost a vysvetleni komentarem. Jeho smyslem je z pole @projects_current
    # odebrat vsechny projekty, ktere jsou jiz hotove (pocet odpracovanych dni je vetsi nebo roven poctu dni potrebnemu
    # k dokonceni projektu) a tyto projekty umistit do pomocneho pole currently_done.
    # V podmince bloku metody reject! vyuzivame toho, ze pokud jeste neni odpracovan dostatecny pocet dni, bude hned
    # prvni cast podminky vyhodnocena jako false a diky zkracenemu vyhodnocovani vyrazu se druha cast podminky vubec
    # neprovede. V pripade, ze uz je odpracovano dostatecne mnozstvi dni, pridani zkoumaneho projektu do currently_done
    # se provede a vyslednou hodnotou celeho bloku bude objekt currently_done samotny, coz v podminkovem kontextu
    # znamena pravdivou hodnotu, a tedy projekt bude metodou reject! odebran z @projects_current.
    # Pokud vam takovato konstrukce pripada ponekud slozita a nepruhledna, nevadi, muzete si predstavit, ze bychom
    # misto toho pouzili nasledujici kod -- vysledek by byl stejny:
    # currently_done = @projects_current.select { |project| project.man_days_done >= project.man_days }
    # @projects_current.reject! { |project| project.man_days_done >= project.man_days }
    currently_done = []
    @projects_current.reject! { |project| project.man_days_done >= project.man_days && currently_done << project }

    currently_done.each do |project|
      project.state = :done
      @projects_done << project
      @budget += project.price
    end
  end

  # Uvolnit programatory, co delaji na projektech,
  # ktere uz jsou hotove.
  def check_programmers
    # IMPLEMENTUJTE TUTO METODU
    @programmers.each_with_index do |prg,i|
      #puts "debug: prg name= #{@programmers[i].name} prj=#{@programmers[i].project} prstate=#{@programmers[i].project.state}"
      #if @programmers[i].project.state==:done  ##nejde, protoze se stav nastavi az po volani tehle metody.
      if @programmers[i].project.man_days <= @programmers[i].project.man_days_done
        @programmers[i].project = nil
        #puts "debug: releasing programmers after project is in the done state: #{@programmers[i].name} prg.project=#{@programmers[i].project} "
      end
    end
    #p "check programmers end. programmers= #{@programmers}"
    #gets
  end

  # Nastavit projekty programatorum, kteri jsou volni.
  def assign_new_projects
    # IMPLEMENTUJTE TUTO METODU
    # Pro kazdeho volneho programatora hledejte projekt k prideleni nasledovne:
    # - Pokud existuje nejaky projekt v @projects_waiting, vyberte prvni takovy.
    #   (Nezapomente mu zmenit stav a presunout jej do @projects_current.)
    # - Pokud ne, vyberte takovy projekt z @projects_current, na kterem zbyva
    #   nejvice nedodelane prace.
    @programmers.each_with_index do |prg,i|
      if @programmers[i].project == nil  #programator bez projektu
        if @projects_waiting.length > 0
          cur_prj=@projects_waiting.shift
          cur_prj.state=:current
          @programmers[i].project=cur_prj
          @projects_current << cur_prj
        else
          if @projects_current.length >0
            #p "vyber ten kde je nejvic prace"
            #p @projects_current
            @projects_current.sort! { |a,b| (a.man_days-a.man_days_done) <=> (b.man_days-b.man_days_done) }
            # @projects_current.sort_by! {|rem| -(rem.man_days - rem.man_days_done) }
            @programmers[i].project=@projects_current[0] if @projects_current.length >0
          end
        end
      end
    end
  end

  # Programatori pracuji.
  def programmers_work
    # IMPLEMENTUJTE TUTO METODU
    # Projdete vsechny programatory a predejte jejich denni vykon projektum,
    # ktere maji pridelene.
    # Zaroven snizte aktualni stav financi firmy o jejich denni mzdu a rovnez
    # o denni vydaje firmy.
    @programmers.each_with_index do |prj,i|
      @budget -= @programmers[i].daily_wage
      @programmers[i].write_code
      #p "debug: #{@programmers[i].name} speed #{@programmers[i].speed} budget-cena: #{@programmers[i].daily_wage}  man_days_done=#{@programmers[i].project.man_days_done}"
    end
    @budget -= @daily_expenses
    #p "debug: programmers_work - budget -dailyexp #{@daily_expenses} po programmers_work #{@budget}"
  end

  # Zjistit stav spolecnosti.
  def check_company_state
    # IMPLEMENTUJTE TUTO METODU
    # Pokud je aktualni stav financi firmy zaporny, nastavte
    # stav spolecnosti na :bankrupt.
    # Pokud ne a zaroven pokud jsou jiz vsechny projekty hotovy,
    # nastavte stav spolecnosti na :finished.
    @state=:bankrupt if @budget <0
    @state=:finished if (@projects_current.length==0 and @projects_waiting.length==0)
    #p "debug: check_company_state - state=#{@state} budget=#{@budget} cur_prj=#{@projects_current.length} prj_wa=#{@projects_waiting.length}"
  end

  # Spusteni simulace. Cyklus se ukonci kdyz je stav firmy
  # :bankrupt nebo :finished, nebo pokud simulace bezi vice nez 1000 dni
  def run
    @state = :running
    while @state != :bankrupt and @state != :finished and @days <= 1000
      @days += 1
      assign_new_projects
      programmers_work
      check_programmers
      check_projects
      check_company_state

      # odkomentovani nasledujicich radku zpusobi vypsani velmi podrobnych informaci
      # o stavu spolecnosti na konci kazdeho dne
      # puts
      # print_debug_info
    end
    @state = :idle if @state == :running
  end

  def output_result
    puts
    puts "Company name #{name}"
    puts "Days running #{@days}"
    puts "Final budget #{@budget}"
    puts "Final state #{@state}"
    puts "Number of projects done #{@projects_done.size}"
  end

  # Slouzi pouze pro ladici ucely. Vypise dulezite informace o danem projektu,
  # vcetne seznamu zamestnanych programatoru a seznamu cekajicich, zpracovavanych a zpracovanych projektu.
  # U zpracovavanych a zpracovanych projektu vypise i podrobnosti o techto projektech.
  def print_debug_info
    puts "Company #{name}, day #{days}:"
    puts "\tState: #{state}"
    puts "\tCurrent cash flow: #{budget}"
    puts "\tDaily expenses: #{daily_expenses}"
    puts "\tCapacity: #{capacity}"
    puts "\tProgrammers: #{programmers.collect { |programmer| programmer.name + " (" + programmer.project_name + ")" }.join(", ")}"
    puts "\tPROJECTS WAITING: #{projects_waiting.collect { |project| project.name }.join(", ")}"
    puts "\tPROJECTS CURRENT:"
    projects_current.each { |project| project.print_debug_info }
    puts "\tPROJECTS DONE:"
    projects_done.each { |project| project.print_debug_info }
  end
end

# Konstanty s nazvy souboru se vstupnimi daty
FILE_NAME_COMPANIES = "companies.csv"
FILE_NAME_PROGRAMMERS = "programmers.csv"
FILE_NAME_PROJECTS = "projects.csv"
companies = []
programmers = []
projects = []
# IMPLEMENTUJTE zde nacteni dat ze vstupnich souboru do poli companies, programmers a projects
  cntr=-1
  File.open(FILE_NAME_COMPANIES, "r") do |f|
    while line = f.gets
      args=line.strip.split(",")
      if cntr>=0                                                                     #zacit od druhe radky #odstranit \n, rozrezat po polich (,)
        companies[cntr] = Company.new(args[0], args[1].to_i, args[2].to_i, args[3].to_i )
      end
      cntr+=1
    end
  end
  #p programmers
  #p companies[0].print_debug_info

  cntr=-1
  File.open(FILE_NAME_PROGRAMMERS, "r") do |f|
    while line = f.gets                                                              #odstranit whitespace
      args=line.strip.split(",")
      #p "f=#{f} line=#{line} cntr=#{cntr} #{args[0] }"
      if cntr>=0                                                                     #zacit od druhe radky #odstranit \n, rozrezat po polich (,)
        programmers[cntr] = Programmer.new(args[0], args[1].to_f, args[2].to_i )
      end
      cntr+=1
    end
  end
  #p programmers
  #programmers[0].print_debug_info

  cntr=-1
  File.open(FILE_NAME_PROJECTS, "r") do |f|
    while line = f.gets
      args=line.strip.split(",")
      if cntr>=0                                                            #zacit od druhe radky #odstranit \n, rozrezat po polich (,)
        projects[cntr] = Project.new(args[0], args[1].to_f, args[2].to_i )  #odstranit \n, rozrezat po polich (,)
      end
      cntr+=1
    end
  end


# Tento cyklus se opakuje pro kazdou firmu
companies.each do |c|
  # Prijmout programatory
  c.allocate_programmers(programmers)
  # Nacist projekty
  c.allocate_projects(projects)
  # Spustit simulaci
  c.run
  # Vypsat vysledek
  c.output_result

  # Protoze pri simulaci pracujeme v kazde firme se stejnymi objekty programatoru a projektu
  # pak po kazde dokoncene simulaci pro jednu firmu resetujeme programatory a projekty do vychoziho stavu
  # aby jim nezustal prirazen projekt a nebyla u nich evidovana odvedena prace.
  programmers.each do |prg|
    prg.clear_project
  end
  projects.each do |prj|
    prj.reset
  end
end

# IMPLEMENTUJTE zde:
# Program se uzivatele zepta zdali chce informace o koncovem stavu firem zapsat do souboru.
# Pokud uzivatel zvoli ze nechce, pak program konci. V opacnem pripade je koncovy stav firem
# zapsan do souboru result.csv. Tento soubor bude mit hlavickovy radek:
# CompanyName,DaysRunning,FinalBudget,FinalState,NumberOfProjectsDone
#
# Jeden radek v tomto souboru bude odpovidat informacim o koncovem stavu jedne firmy

#vypis na obrazovku (ze zadani)
#Po vypsání informací o koncovém stavu na konzoli program uživateli umožní si nechat tyto informace zapsat do CSV souboru. Implementujte tuto
#možnost podle instrukcí ve zdrojovém kódu. Pokud soubor result.csv již existuje, pak je jeho obsan p?epsán.

  puts "\nVysledky simulace:\n------------------"
  puts "CompanyName     DaysRunning     FinalBudget     FinalState      NumberOfProjectsDone"
  companies.each_with_index do |com, i|
    puts "#{"%-15s" % companies[i].name} #{"%-15s" % companies[i].days} #{"%-15s" % companies[i].budget} #{"%-15s" % companies[i].state} #{companies[i].projects_done.count}"
  end

#otazka, jestli zapsat do souboru
  odpoved="x"
  while true do
    puts "\nChcete zapsat informace o koncovem stavu do souboru results.csv? [A/N]"
    odpoved = gets.strip
    break if odpoved == 'A' or odpoved == 'N'
  end

#samotny zapis do souboru
  if odpoved == 'A'
    puts "zapisuji do souboru results.csv"
    CSV.open("result.csv", "w") do |csv|
      csv << ["CompanyName","DaysRunning","FinalBudget","FinalState","NumberOfProjectsDone"]
      companies.each_with_index do |com, i|
      csv << [companies[i].name, companies[i].days, companies[i].budget ,companies[i].state, companies[i].budget]
    end
    end
  else
    puts "nezapisuji vysledky do souboru."
  end

