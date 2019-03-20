package cz.ucl.fa.model;

import java.io.Serializable;
import java.util.HashSet;
import java.util.Set;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.OneToMany;

/**
 * Entity implementation class for Entity: Accommodation
 *
 */
@Entity

public class Accommodation implements Serializable {

	   
	@Id
	@GeneratedValue
	private Long id;
	
	private String location;
	private String name;
	private String description;
	private String imagePath;
	private int capacity;
	
	@OneToMany(mappedBy="hotel")
	private Set<Service> services;
	
	private static final long serialVersionUID = 1L;

	public Accommodation() {
		super();
		services = new HashSet<Service>();
	}   
	public Long getId() {
		return this.id;
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
	public String getImagePath() {
		return this.imagePath;
	}

	public void setImagePath(String imagePath) {
		this.imagePath = imagePath;
	}
	public Set<Service> getServices() {
		return services;
	}
	
	public void addService(Service s) {
		services.add(s);
		s.setHotel(this);
	}
	
	public void setCapacity(int capacity) {
	 this.capacity =  capacity;
  }
	public int getCapacity() {
		return capacity;
	}
	public void setServices(Set<Service> services) {
		this.services = services;
	}
	@Override
	public String toString() {
		return getName() + ", " + getLocation();
	}
	
	
   
}
