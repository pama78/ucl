package cz.ucl.fa.model;

import java.io.Serializable;
import java.util.Date;
import javax.persistence.*;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Pattern;
import javax.validation.constraints.Size;

/**
 * Entity implementation class for Entity: Traveller
 * 
 */
@Entity
public class Traveller implements Serializable {

	@Id
	@GeneratedValue
	private Long id;
	
	@ManyToOne
	private Contract contract;
	
	@NotNull(message = "The Firstname must not be empty")
    @Size( min = 2, max = 255, message = "The value must be between {min} and {max} characters long" )
	private String firstName;

	@NotNull(message = "The Surname must not be empty")
    @Size( min = 2, max = 255, message = "The value must be between {min} and {max} characters long" )
	private String surname;

	@NotNull(message = "The ID must not be empty")
    @Size( min = 2, max = 255, message = "The value must be between {min} and {max} characters long" )
	private String idNumber;

	@NotNull(message = "The date of birth must not be empty")
	@Temporal(TemporalType.DATE)
	private Date dateOfBirth;
	
	private static final long serialVersionUID = 1L;

	public Traveller() {
		super();
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

	public String getIdNumber() {
		return this.idNumber;
	}

	public void setIdNumber(String idNumber) {
		this.idNumber = idNumber;
	}

	public Date getDateOfBirth() {
		return this.dateOfBirth;
	}

	public void setDateOfBirth(Date dateOfBirth) {
		this.dateOfBirth = dateOfBirth;
	}

	public Contract getContract() {
		return contract;
	}

	public void setContract(Contract contract) {
		this.contract = contract;
	}

	
}
