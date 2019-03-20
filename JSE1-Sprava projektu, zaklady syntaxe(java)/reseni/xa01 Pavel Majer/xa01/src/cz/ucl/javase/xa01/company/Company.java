package cz.ucl.javase.xa01.company;

import java.util.ArrayList;
import java.util.Iterator; // pridano pro ucely iterace nad listy
import java.util.List;

public class Company {
	private String name;
	private int capacity;
	private int dailyExpenses;
	private int budget;

	private int days;
	private CompanyState state;
	private List<Programmer> programmers;
	private List<Project> projectsWaiting;
	private List<Project> projectsCurrent;
	private List<Project> projectsDone;

	private Logger logger;

	public Company() {
		this.state = CompanyState.IDLE;
		this.programmers = new ArrayList<Programmer>();
		this.projectsWaiting = new ArrayList<Project>();
		this.projectsCurrent = new ArrayList<Project>();
		this.projectsDone = new ArrayList<Project>();
	}

	public Company(String name, int capacity, int dailyExpenses, int budget) {
		this(); // Volani bezparametrickeho konstruktoru
		this.name = name;
		this.capacity = capacity;
		this.dailyExpenses = dailyExpenses;
		this.budget = budget;
		// IMPLEMENTUJTE ZDE: az budete mit implementovanu tridu Logger,
		// pak zde vytvorte jeji novou instanci a ulozte ji do atributu logger.
		this.logger = Logger.getInstance();

	}

	/**
	 * Nacte vsechny projekty do kolekce projectsWaiting.
	 * 
	 * @param projects nacitane projekty
	 */
	public void allocateProjects(List<Project> projects) {
		projectsWaiting.addAll(projects);
	}

	/**
	 * Najme tolik programatoru, kolik cini kapacita firmy a ulozi je do kolekce
	 * programmers.
	 * 
	 * @param programmersAvailable kolekce programatoru k dispozici
	 */
	public void allocateProgrammers(List<Programmer> programmersAvailable) {
		// IMPLEMENTUJTE TUTO METODU
		// Z parametru programmersAvailable vyberte prvnich capacity programatoru
		// a vlozte je do kolekce (atributu) programmers.
		logger.debug("#allocateProgrammers entered ", "OL");
		int curCapacity = getCapacity();
		for (int c = 0; c < curCapacity; c++) {
			programmers.add(programmersAvailable.get(c));
		}

		// logovani
		logger.debug("#allocateProgrammers - Company (" + this.getName() + "): ", "BOL");
		for (int y = 0; y < programmers.size(); y++) {
			logger.debug(programmers.get(y).getName() + " ", "MOL");
		}
		logger.debug("", "EOL");
	}

	/**
	 * Zkontroluje/upravi stav hotovych projektu a upravi rozpocet.
	 */
	public void checkProjects() {
		// IMPLEMENTUJTE TUDO METODU
		// Z kolekce projectsCurrent odeberte ty projekty, ktere jsou dokoncene.
		// Dokonceny projekt je ten, ktery ma manDaysDone >= manDays.
		// Zaroven temto projektum nastavte spravny stav,
		// pridejte je do projectsDone a do rozpoctu firmy prictete utrzene
		// penize za projekt.
		logger.debug("#checkProjects - entered on day#" + this.days, "OL");
		for (Iterator<Project> iterator = projectsCurrent.iterator(); iterator.hasNext();) {
			Project project = iterator.next();
			if (project.getManDaysDone() >= project.getManDays()) {
				logger.debug("#checkProjects - detected completed project: " + project.getName(), "OL");
				iterator.remove();
				project.setState(ProjectState.DONE);
				projectsDone.add(project);
				this.budget += project.getPrice();
				logger.debug("#checkProjects - on day#" + this.days + " project: " + project.getName()
						+ " Status -> " + project.getState() + " (MD: " + project.getManDays() + "/"
						+ project.getManDaysDone() + ")", "OL");
			}
		}

	}

	/**
	 * Uvolni programatory z hotovych projektu.
	 */
	public void checkProgrammers() {
		// IMPLEMENTUJTE TUTO METODU
		// Uvolnete programatory pracujici na projektech, ktere jsou dokonceny.
		logger.debug("#checkProgrammers - entered on day#" + this.days, "OL");
		for (Iterator<Programmer> iterator = programmers.iterator(); iterator.hasNext();) {
			Programmer programmer = iterator.next();
			Project project = programmer.getProject();
			if (project.getState() == ProjectState.DONE) {
				logger.debug("#checkProjects - on day#" + this.days + " clear project " + project.getName()
						+ " from " + programmer.getName(), "OL");
				programmer.clearProject();
			}

		}
	}

	/**
	 * Priradi nove projekty programatorum, kteri nepracuji.
	 */
	public void assignNewProjects() {
		// IMPLEMENTUJTE TUTO METODU
		// Nastavte projekty programatorum, kteri aktualne nepracuji na zadnem
		// projektu.
		// Pro kazdeho volneho programatora hledejte projekt k prirazeni
		// nasledujicim zpusobem:
		// - Pokud existuje nejaky projekt v projectsWaiting, vyberte prvni
		// takovy. Nezapomente projektu zmenit stav a presunout jej do projectsCurrent.
		// - Pokud ne, vyberte takovy projekt z projectsCurrent, na kterem zbyva
		// nejvice nedodelane prace.

		logger.debug("#assignNewProjects - entered on day#" + this.days, "OL");
		// old: for (int y = 0; y < programmers.size(); y++) {
		// old: Programmer curPrg = programmers.get(y);
		for (Iterator<Programmer> iterator = programmers.iterator(); iterator.hasNext();) {
			Programmer programmer = iterator.next();
			if (programmer.getProject() == null) {
				logger.debug("#assignNewProjects - " + programmer.getName() + " is without project!", "OL");
				if (projectsWaiting.isEmpty() == false ) {
					Project project = projectsWaiting.remove(0);
					logger.debug("#assignNewProjects - existed " + projectsWaiting.size() + " projectsWaiting. "
							+ programmer.getName() + " took first: " + project.getName(), "OL");
					project.setState(ProjectState.CURRENT);
					programmer.assignProject(project);
					projectsCurrent.add(project);
				} else { // to find a project with most work pending
					if (projectsCurrent != null) {
						logger.debug("#assignNewProjects - no projectsWaiting, but still exist some projectsCurrent:"
								+ projectsCurrent.size(), "OL");
						// find the one with most undone work
						Project projectCurrentBiggest = projectsCurrent.get(0);
						double projectCurrentBiggestRemain = (projectCurrentBiggest.getManDays()
								- projectCurrentBiggest.getManDaysDone());

						for (int i = 0; i < projectsCurrent.size(); i++) {
							Project projectCurrentLoop = projectsCurrent.get(i);
							double projectCurrentLoopRemain = (projectCurrentLoop.getManDays()
									- projectCurrentLoop.getManDaysDone());
							if (projectCurrentLoopRemain > projectCurrentBiggestRemain) {
								projectCurrentBiggest = projectCurrentLoop;
								projectCurrentBiggestRemain = projectCurrentLoopRemain;
							}
						}
						logger.debug(
								"#assignNewProjects - detected project with most work to be done: "
										+ projectCurrentBiggest.getName() + " with MDs:" + projectCurrentBiggestRemain,"OL");
						programmer.assignProject(projectCurrentBiggest);
					}
				}
			}
		}
	}

	/**
	 * Preda praci programatoru projektum a upravi rozpocet firmy.
	 */
	public void programmersWork() {
		// IMPLEMENTUJTE TUTO METODU
		// Projdete vsechny programatory a predejte jejich denni vykon (praci)
		// projektum (pouziti metody writeCode).
		// Zaroven snizte aktualni stav financi firmy o jejich denni mzdu a
		// rovnez o denni vydaje firmy.

		logger.debug("programmerWork - entered on day#" + this.days, "OL");
		// old:for (int y = 0; y < programmers.size(); y++) {
		// old:Programmer curPrg = programmers.get(y);
		for (Iterator<Programmer> iterator = programmers.iterator(); iterator.hasNext();) {
			Programmer programmer = iterator.next();
			logger.debug("programmerWork - programmer (before work): " + programmer.getName() + " (wage: "
					+ programmer.getDailyWage() + " speed:" + programmer.getSpeed() + " prj: "
					+ programmer.getProject().getName() + " project TBD:"
					+ Math.round(programmer.getProject().getManDaysDone() * 100.0) / 100.0 + "/"
					+ programmer.getProject().getManDays() + "); Company Budget:" + this.getBudget(), "OL");
			programmer.writeCode();
			this.budget -= programmer.getDailyWage();
			logger.debug("programmerWork - programmer (after work): " + programmer.getName() + " (wage: "
					+ programmer.getDailyWage() + " speed:" + programmer.getSpeed() + " prj: "
					+ programmer.getProject().getName() + " project TBD:"
					+ Math.round(programmer.getProject().getManDaysDone() * 100.0) / 100.0 + "/"
					+ programmer.getProject().getManDays() + "); Company Budget:" + this.getBudget(), "OL");
		}
		this.budget -= this.getDailyExpenses();
		logger.debug("programmerWork - Day is over, after daily expenses (" + this.getDailyExpenses()
				+ ") the budget is: " + this.getBudget(), "OL");

	}

	/**
	 * Zkontroluje a nastavi spravny stav firmy.
	 */
	public void checkCompanyState() {
		// IMPLEMENTUJTE TUTO METODU
		// Pokud je aktualni stav financi firmy zaporny, nastavte stav firmy na
		// Bankrupt.
		// Pokud ne a zaroven pokud jsou jiz vsechny projekty hotove, nastavte
		// stav firmy na Finished.
		logger.debug("checkCompanyState - entered on day#" + this.days, "OL");
		if (this.budget < 0) {
			this.state = CompanyState.BANKRUPT;
			logger.debug("#checkCompanyState - budget is a negative number (" + this.budget + "). Setting CompanyState to BANKRUPT", "OL");
		} else {
			//if ((projectsCurrent.size() == 0) && (projectsWaiting.size() == 0)) {
			if ((projectsCurrent.isEmpty() == true ) && (projectsWaiting.isEmpty() == true)) {
				this.state = CompanyState.FINISHED;
				logger.debug("#checkCompanyState - all projects finished and budget>0 (" + this.budget + "). Setting CompanyState to FINISHED", "OL");
			}
		}
	}

	/**
	 * Spusteni simulace. Simulace je ukoncena pokud je stav firmy Bankrupt nebo
	 * Finished, nebo pokud simulace bezi dele nez 1000 dni.
	 */
	public void run() {
		// IMPLEMENTUJTE ZDE: az budete mit implementovanu tridu Logger, pak
		// nasledujici radek odkomentujte
		logger.log("Company " + name + ", started with budget: " + budget);

		state = CompanyState.RUNNING;
		while (state != CompanyState.BANKRUPT && state != CompanyState.FINISHED && days <= 1000) {
			days++;
			assignNewProjects();
			programmersWork();
			checkProjects();
			checkProgrammers();
			checkCompanyState();
		}

		if (state == CompanyState.RUNNING) {
			state = CompanyState.IDLE;
		}
	}

	public void printResult() {
		System.out.println("Company name: " + name);
		System.out.println("Days running: " + days);
		System.out.println("Final budget: " + budget);
		System.out.println("Final state: " + state);
		System.out.println("Count of projects done: " + projectsDone.size() + "\n");
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public int getCapacity() {
		return capacity;
	}

	public void setCapacity(int capacity) {
		this.capacity = capacity;
	}

	public int getDailyExpenses() {
		return dailyExpenses;
	}

	public void setDailyExpenses(int dailyExpenses) {
		this.dailyExpenses = dailyExpenses;
	}

	public int getBudget() {
		return budget;
	}

	public void setBudget(int budget) {
		this.budget = budget;
	}
}
