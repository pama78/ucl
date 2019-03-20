package cz.ucl.fa.model;

import java.io.Serializable;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.ManyToOne;

import cz.ucl.fa.model.types.ServiceType;

/**
 * Entity implementation class for Entity: Service
 * 
 */
@Entity
public class Service implements Serializable {

	@Id
	@GeneratedValue
	private Long id;
	@ManyToOne
	private Accommodation hotel;
	
	private String location;
	private String name;
	private String description;
	private ServiceType type;
	private static final long serialVersionUID = 1L;

	public Service() {
		super();
	}

	public Long getId() {
		return this.id;
	}

	public Accommodation getHotel() {
		return this.hotel;
	}

	public void setHotel(Accommodation hotel) {
		this.hotel = hotel;
	}

	public String getLocation() {
		return this.location;
	}

	public void setLocation(String location) {
		this.location = location;
	}

	public String getName() {
		return this.name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getDescription() {
		return this.description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public ServiceType getType() {
		return this.type;
	}

	public void setType(ServiceType type) {
		this.type = type;
	}

	@Override
	public String toString() {
		String result = "";		
		result += getName();
		if (getHotel()!=null) {
			result += " [" ;
			result += getHotel().toString();
			result += "]";
		}
		
		return result;
	}
	
	

}
