package cz.ucl.fa.model;

import java.io.Serializable;
import java.text.DateFormat;
import java.util.Date;
import javax.persistence.*;

/**
 * Entity implementation class for Entity: Stay
 *
 */
@Entity

public class Stay implements Serializable {

	   
	@Id
	@GeneratedValue
	private Long id;
	
	@ManyToOne
	private Accommodation hotel;
	
	@Temporal(TemporalType.DATE)
	private Date dayFrom;
	
	@Temporal(TemporalType.DATE)
	private Date dayTo;
	
	@ManyToOne
	private Holiday holiday;
	
	private static final long serialVersionUID = 1L;

	public Stay() {
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
	
	public Date getDayFrom() {
		return dayFrom;
	}
	public void setDayFrom(Date dayFrom) {
		this.dayFrom = dayFrom;
	}
	public Date getDayTo() {
		return dayTo;
	}
	public void setDayTo(Date dayTo) {
		this.dayTo = dayTo;
	}
	public Holiday getHoliday() {
		return holiday;
	}
	public void setHoliday(Holiday holiday) {
		this.holiday = holiday;
	}
	@Override
	public String toString() {	
		String result = "";
		
		result+=getHotel().toString();
		result+=", from ";		
		DateFormat df = DateFormat.getDateInstance();
		result+= df.format(getDayFrom());
		result+= " to ";
		result+= df.format(getDayTo());
		return result;
	}
   
}
