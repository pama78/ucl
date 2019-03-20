package cz.ucl.javase.xa01.company;

public abstract class Employee {
	//public String name;
	//public int dailyWage; 
	protected String name;
	protected int dailyWage;

	public Employee(String name, int dailyWage) {
		this.name = name;
		this.dailyWage = dailyWage;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public int getDailyWage() {
		return dailyWage;
	}

	public void setDailyWage(int dailyWage) {
		this.dailyWage = dailyWage;
	}

}
