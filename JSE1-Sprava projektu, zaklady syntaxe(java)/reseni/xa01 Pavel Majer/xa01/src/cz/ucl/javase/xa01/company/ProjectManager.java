package cz.ucl.javase.xa01.company;

import java.util.List;

// IMPLEMENTUJTE ZDE
// Tato trida zatim neni v programu nikde vyuzita, ale predstavte si, 
// ze program bude nekdy v budoucnu dale rozvijen.
// Trida ProjectManager ma nektere prvky spolecne s tridou Programmer. 
// Vytvorte vhodneho spolecneho predka temto tridam, o kterem vite, 
// ze bude obecny a nebudou z nej v programu vytvareny instance. 
// Timto tedy musite upravit jak tuto tridu tak tridu Programmer, 
// pricemz ze spolecneho predka vyuzijte jeho konstruktor v potomcich.

public class ProjectManager extends Employee {
	private List<Project> managedProjects;

	public ProjectManager(String name, int dailyWage, List<Project> managedProjects) {
		super(name, dailyWage);
		this.managedProjects = managedProjects;
	}

	public List<Project> getManagedProjects() {
		return managedProjects;
	}

	public void setManagedProjects(List<Project> managedProjects) {
		this.managedProjects = managedProjects;
	}
}
