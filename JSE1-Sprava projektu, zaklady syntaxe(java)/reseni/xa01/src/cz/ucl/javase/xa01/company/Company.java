package cz.ucl.javase.xa01.company;

import java.util.ArrayList;
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
	 * Najme tolik programatoru, kolik cini kapacita firmy a ulozi je 
	 * do kolekce programmers.
	 * 
	 * @param programmersAvailable kolekce programatoru k dispozici
	 */
	public void allocateProgrammers(List<Programmer> programmersAvailable) {
		// IMPLEMENTUJTE TUTO METODU
		// Z parametru programmersAvailable vyberte prvnich capacity programatoru
		// a vlozte je do kolekce (atributu) programmers.
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
	}

	/**
	 * Uvolni programatory z hotovych projektu.
	 */
	public void checkProgrammers() {
		// IMPLEMENTUJTE TUTO METODU
		// Uvolnete programatory pracujici na projektech, ktere jsou dokonceny.
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
	}

	/**
	 * Spusteni simulace. Simulace je ukoncena pokud je stav firmy Bankrupt nebo
	 * Finished, nebo pokud simulace bezi dele nez 1000 dni.
	 */
	public void run() {
		// IMPLEMENTUJTE ZDE: az budete mit implementovanu tridu Logger, pak
		// nasledujici radek odkomentujte
		// logger.log("Company " + name + ", started with budget: " + budget);
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
