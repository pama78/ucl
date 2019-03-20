package cz.ucl.fa.model;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

import javax.persistence.CascadeType;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;
import javax.persistence.OneToMany;
import javax.persistence.OneToOne;
import javax.validation.constraints.NotNull;
//import javax.validation.constraints.Pattern;
import javax.validation.constraints.Size;

/**
 * Entity implementation class for Entity: Customer
 *
 */
@Entity
@NamedQueries( { 
	 @NamedQuery(name = "Customer.findAll", query = "SELECT c FROM Customer c"),
	 @NamedQuery(name = "Customer.findBySurname", query = "SELECT c FROM Customer c WHERE c.surname LIKE :surname")
	})
public class Customer implements Serializable {

	   
	@Id
	@GeneratedValue
	private Long id;
	
	@NotNull(message = "The first name must not be empty" )
	@Size( min = 2, max = 255, message = "The first name must be between 2 and 255 characters long" )
	private String firstName;
	
	@NotNull(message = "The surname must not be empty")
    @Size( min = 2, max = 255, message = "The surname must be between 2 and 255 characters long" )
	private String surname;
	
	@OneToOne(cascade=CascadeType.ALL)
	private CreditCard card;
	
	@OneToMany(mappedBy="customer")
	List<Contract> contracts;
	
	private static final long serialVersionUID = 1L;

	public Customer() {
		super();
		contracts = new ArrayList<Contract>();
	}   
	public Long getId() {
		return this.id;
	}

	public String getFirstName() {
		return this.firstName;
	}

	public void setFirstName(String firstName) {
		this.firstName = firstName;
	}   
	public String getSurname() {
		return this.surname;
	}

	public void setSurname(String surname) {
		this.surname = surname;
	}   

	public CreditCard getCard() {
		return this.card;
	}

	public void setCard(CreditCard card) {
		this.card = card;
	}
	
	public List<Contract> getContracts() {
		return contracts;
	}
	
	public void addContract(Contract c) {
		contracts.add(c);
		c.setCustomer(this);
	}
	public String getName() {
		return firstName + " " + surname; //$NON-NLS-1$
	}
   
}
