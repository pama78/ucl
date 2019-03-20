package cz.ucl.fa.model;

import java.io.Serializable;
import java.text.DateFormat;
import java.util.Date;
import javax.persistence.*;

import cz.ucl.fa.model.types.TransportationType;

/**
 * Entity implementation class for Entity: Transportation
 *
 */
@Entity
@NamedQueries( { 
	 @NamedQuery(name = "Transportation.findAllFromLocations", query = "SELECT DISTINCT t.from FROM Transportation t"),
	 @NamedQuery(name = "Transportation.findAllToLocations", query = "SELECT DISTINCT t.to FROM Transportation t")
	})
public class Transportation implements Serializable {

	   
	@Id
	@GeneratedValue
	private Long id;
	private TransportationType type;
	
	@Column(name="loc_from")
	private String from;
	
	@Column(name="loc_to")
	private String to;
	
	@Temporal(TemporalType.TIMESTAMP)
	private Date departure;
	
	@Temporal(TemporalType.TIMESTAMP)
	private Date arrival;
	
	private int capacity;
	private int occupied;
	private static final long serialVersionUID = 1L;

	public Transportation() {
		super();
	}   
	public Long getId() {
		return this.id;
	}

	public TransportationType getType() {
		return this.type;
	}

	public void setType(TransportationType type) {
		this.type = type;
	}   
	public String getFrom() {
		return this.from;
	}

	public void setFrom(String from) {
		this.from = from;
	}   
	public String getTo() {
		return this.to;
	}

	public void setTo(String to) {
		this.to = to;
	}   
	public Date getDeparture() {
		return this.departure;
	}

	public void setDeparture(Date departure) {
		this.departure = departure;
	}   
	public Date getArrival() {
		return this.arrival;
	}

	public void setArrival(Date arrival) {
		this.arrival = arrival;
	}   
	public int getCapacity() {
		return this.capacity;
	}

	public void setCapacity(int capacity) {
		this.capacity = capacity;
	}   
	public int getOccupied() {
		return this.occupied;
	}

	public void setOccupied(int occupied) {
		this.occupied = occupied;
	}
	
	@Override
	public String toString() {
		String result = ""; 
		result += getType().name();
		result += " [" ;
		result += getFrom();
		result += " -> ";
		result += getTo();
		result += "]";
		result += " on ";
		DateFormat df = DateFormat.getDateTimeInstance();
		result += df.format(getDeparture());		
		return result;
	}
	
	
   
}
