package cz.ucl.jsf.controller;

import java.io.Serializable;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.annotation.PostConstruct;
import javax.annotation.PreDestroy;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.persistence.EntityManager;
import javax.persistence.Query;

import cz.ucl.fa.model.Holiday;
import cz.ucl.fa.model.Transportation;
import cz.ucl.fa.model.util.JPAUtil;

@ManagedBean(name="holidayManager")
@ViewScoped
public class TripConfigurationController implements Serializable {
	private List<Holiday> allHolidays;
	private Holiday currentHoliday;
	private Transportation transportExample;

	private Long currentHolidayId;
	private Long transportId;
	
	@PostConstruct
	public void init() {
		System.out.println("!!! Holiday Controller initialized for VIEW SCOPE: " + this.toString());
	}
	
	@PreDestroy 
	public void destroy() {
		System.out.println("!!! Holiday Controller destroyed at the end of the VIEW SCOPE: " + this.toString());
	}


	/**
	 * Vrací seznam všech katalogových zájezdu z databáze
	 */
	@SuppressWarnings("unchecked")
	public List<Holiday> getAllHolidays() {
		EntityManager em = JPAUtil.createEntityManager();
		allHolidays = (List<Holiday>) em.createNamedQuery("Trip.getFixed")
				.getResultList();
		em.close();
		return allHolidays;
	}

	/**
	 * Nacítá objekt zájezdu z databáze na základe primárního klíce, uloženého ve vlastnosti currentHolidayId
	 */
	public Holiday getCurrentHoliday() {
		if (currentHoliday == null) {
			if (currentHolidayId != null) {
				EntityManager em = JPAUtil.createEntityManager();
				currentHoliday = em.find(Holiday.class, currentHolidayId);
				currentHoliday.getAccommodation().size();
				currentHoliday.getTransportation().size();
				currentHoliday.getServices().size();
				em.close();
			} else {
				currentHoliday = new Holiday();
			}
		}

		return currentHoliday;
	}

	/**
	 * Hodnota nastavena automaticky po stisku odkazu v tabulce všech zájezdu.
	 * Použito dále v getCurrentHoliday, saveHoliday, addTransport a removeTransport.
	 */
	public void setCurrentHolidayId(Long id) {
		currentHolidayId = id;
		currentHoliday = null;
	}
	

	public Long getCurrentHolidayId() {
		return currentHolidayId;
	}

	/**
	 * Objekt transportExample slouží jen pro nastavení hodnot, podle nichž má být vyhledáváno
	 * mezi všemi dopravními spojeními v databázi 
	 */
	public Transportation getTransportExample() {
		if (transportExample == null)
			transportExample = new Transportation();
		return transportExample;
	}

	/**
	 * Hodnota nastavena automaticky po stisku odkazu v tabulce všech nalezených dopravních spojení.
	 * Použito dále v addTransport.
	 */
	public void setTransportId(Long transportId) {
		this.transportId = transportId;
	}

	/**
	 * Seznam všech mest, ze kterých je možné nekam vyjet
	 */
	@SuppressWarnings("unchecked")
	public Map<String,String> getAllFromCities() {
		EntityManager em = JPAUtil.createEntityManager();
		List<String> result = (List<String>) em
				.createNamedQuery("Transportation.findAllFromLocations")
				.getResultList();
		em.close();
		return getStringMapFromList(result);
	}

	/**
	 * Seznam všech mest, do kterých je možno prijet
	 */
	@SuppressWarnings("unchecked")
	public Map<String,String> getAllToCities() {
		EntityManager em = JPAUtil.createEntityManager();
		List<String> result = (List<String>) em
				.createNamedQuery("Transportation.findAllToLocations")
				.getResultList();
		em.close();
		
		return getStringMapFromList(result);
	}
	
	private Map<String,String> getStringMapFromList(List<String> lst) {
		Map<String,String> resultMap = new HashMap<String,String>();
		for(String item : lst) {
			resultMap.put(item, item);
		}
		return resultMap;
	}

	/**
	 * Odebere dopravní spojení ze zájezdu
	 */
	public String removeTransport() {
		EntityManager em = JPAUtil.createEntityManager();
		Transportation selectedTransport = em.find(Transportation.class,
				this.transportId);

		em.getTransaction().begin();
		currentHoliday = em.merge(getCurrentHoliday());
		Set<Transportation> allTransports = getCurrentHoliday().getTransportation();
		allTransports.remove(selectedTransport);
		em.getTransaction().commit();
		em.close();

		return "transport_removed";
	}
	
	/**
	 * Ukládá aktuální hodnotu objektu currentHoliday do databáze
	 */
	public String saveHoliday() {
		EntityManager em = JPAUtil.createEntityManager();
		em.getTransaction().begin();
		currentHoliday = em.merge(getCurrentHoliday());
		em.getTransaction().commit();
		em.close();
		
		return "holiday_saved";
	}

	/**
	 * Pridává do zájezdu nové dopravní spojení
	 */
	public String addTransport() {
		EntityManager em = JPAUtil.createEntityManager();
		Transportation selectedTransport = em.find(Transportation.class,
		this.transportId);

		em.getTransaction().begin();
		currentHoliday = em.merge(getCurrentHoliday());
		getCurrentHoliday().addTransportation(selectedTransport);
		em.getTransaction().commit();
		em.close();

		return "transport_added";
	}

	/**
	 * Vyhledává dopravní spojení v databázi na základe podmínek, uložených v objektu transportExample 
	 */	
	public List<Transportation> getFoundTransports() {
		String qString = "SELECT t FROM Transportation t WHERE t.from = :transFrom AND t.to = :transTo ";
		if (transportExample.getDeparture() != null)
			qString += " AND t.departure > :dep_from AND t.departure < :dep_to ";

		EntityManager em = JPAUtil.createEntityManager();
		Query q = em.createQuery(qString);
		q.setParameter("transFrom", transportExample.getFrom());
		q.setParameter("transTo", transportExample.getTo());
		if (transportExample.getDeparture() != null) {
			Calendar cal = Calendar.getInstance();
			cal.setTime(transportExample.getDeparture());

			cal.set(Calendar.HOUR_OF_DAY, 0);
			cal.set(Calendar.MINUTE, 0);
			cal.set(Calendar.SECOND, 0);

			Date day1 = new Date(cal.getTimeInMillis());
			q.setParameter("dep_from", day1);

			cal.set(Calendar.DAY_OF_MONTH, cal.get(Calendar.DAY_OF_MONTH) + 1);
			Date day2 = new Date(cal.getTimeInMillis());
			q.setParameter("dep_to", day2);
		}

		List<Transportation> result = (List<Transportation>) q.getResultList();
		em.close();
		return result;
	}
}
