package cz.ucl.javase.xa01.company;

public class Project {
	private String name;
	private double manDays;
	private int price;

	private double manDaysDone;
	private ProjectState state;

	public Project() {
		this.state = ProjectState.WAITING;
	}

	public Project(String name, double manDays, int price) {
		this(); // Volani bezparametrickeho konstruktoru
		this.name = name;
		this.manDays = manDays;
		this.price = price;
	}

	/**
	 * Prida programatorem odvedenou praci projektu.
	 * 
	 * @param manDays odvedena prace na projektu.
	 */
	public void receiveWork(double manDays) {
		manDaysDone += manDays;
	}

	/**
	 * Vrati projekt do vychoziho stavu. Vola se vzdy po provedeni simulace pro
	 * jednu firmu. Nikde volani teto metody nepridavejte. Jeji volani je jiz
	 * implementovano v cyklu, ve kterem jsou spousteny simulace pro jednotlive
	 * firmy.
	 */
	public void reset() {
		state = ProjectState.WAITING;
		manDaysDone = 0;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public double getManDays() {
		return manDays;
	}

	public void setManDays(double manDays) {
		this.manDays = manDays;
	}

	public double getManDaysDone() {
		return manDaysDone;
	}

	public void setManDaysDone(double manDaysDone) {
		this.manDaysDone = manDaysDone;
	}

	public int getPrice() {
		return price;
	}

	public void setPrice(int price) {
		this.price = price;
	}

	public ProjectState getState() {
		return state;
	}

	public void setState(ProjectState state) {
		this.state = state;
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		long temp;
		temp = Double.doubleToLongBits(manDays);
		result = prime * result + (int) (temp ^ (temp >>> 32));
		result = prime * result + ((name == null) ? 0 : name.hashCode());
		result = prime * result + price;
		return result;
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		Project other = (Project) obj;
		if (Double.doubleToLongBits(manDays) != Double.doubleToLongBits(other.manDays))
			return false;
		if (name == null) {
			if (other.name != null)
				return false;
		} else if (!name.equals(other.name))
			return false;
		if (price != other.price)
			return false;
		return true;
	}
}
