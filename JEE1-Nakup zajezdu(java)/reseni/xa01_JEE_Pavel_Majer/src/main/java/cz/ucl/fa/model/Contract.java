package cz.ucl.fa.model;

import java.io.Serializable;
import java.util.HashSet;
import java.util.Set;

import javax.persistence.CascadeType;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.ManyToOne;
import javax.persistence.OneToMany;
//import javax.persistence.NamedQueries;
//import javax.persistence.NamedQuery;

/**
 * Entity implementation class for Entity: Contract
 *
 */
@Entity

public class Contract implements Serializable {

	   
	@Id
	@GeneratedValue
	private Long id;
	
	private Long number;
	
	@ManyToOne(cascade=CascadeType.PERSIST)
	private Customer customer;
	
	//@ManyToOne(cascade = CascadeType.MERGE)
	@ManyToOne(cascade = CascadeType.PERSIST)
	private Holiday holiday;
	
	@OneToMany(mappedBy="contract",cascade=CascadeType.ALL)
	private Set<Traveller> travellers;
	
	private static final long serialVersionUID = 1L;

	public Contract() {
		super();
		travellers = new HashSet<Traveller>();
		
	}   
	public long getId() {
		return this.id;
	}

	public void setId(long id) {
		this.id = id;
	}   
	public long getNumber() {
		return this.number;
	}

	public void setNumber(long number) {
		this.number = number;
	}   
	public Customer getCustomer() {
		return this.customer;
	}

	public void setCustomer(Customer customer) {
		this.customer = customer;
		customer.getContracts().add(this);
	}   
	
	public Set<Traveller> getTravellers() {
		return this.travellers;
	}

	public void addTraveller(Traveller t) {
		travellers.add(t);
		t.setContract(this);
	}
	public Holiday getHoliday() {
		return holiday;
	}
	public void setHoliday(Holiday holiday) {
		this.holiday = holiday;
	}   
	
	
   
}
