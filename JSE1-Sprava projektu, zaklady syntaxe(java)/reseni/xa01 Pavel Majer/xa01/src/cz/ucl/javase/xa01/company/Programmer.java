package cz.ucl.javase.xa01.company;

public class Programmer extends Employee {
	private double speed;
	private Project project;

	public Programmer(String name, double speed, int dailyWage) {
		super(name, dailyWage);
		this.speed = speed;
	}

	/**
	 * Uvolni programatora z projektu. Zamerne je implementovano jako metoda pro
	 * ilustraci situace, kdy je napr. dopredu pocitano s tim, ze pri uvolnovani
	 * projektu bude implementovana urcita business logika, ktera svym
	 * charakterem neodpovida situaci, kdy by se typicky dala vyuzit vlastnost -
	 * setter. Nicmene zadnou logiku nyni do teto metody nepridavejte.
	 */
	public void clearProject() {
		project = null;
	}

	/**
	 * Priradi programatorovi projekt, na kterem bude pracovat. Duvod proc je
	 * toto implementovano jako metoda a nikoliv pomoci setter jsou obdobne jako
	 * u clearProject.
	 * 
	 * @see {@link Programmer#clearProject()}
	 * 
	 * @param project
	 *            projekt, na kterem bude programator pracovat.
	 */
	public void assignProject(Project project) {
		this.project = project;
	}

	/**
	 * Programator odvede svou praci na projektu.
	 */
	public void writeCode() {
		project.receiveWork(speed);
	}

	public double getSpeed() {
		return speed;
	}

	public void setSpeed(double speed) {
		this.speed = speed;
	}

	public Project getProject() {
		return project;
	}
}
