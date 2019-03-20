// block nondigits: resources used: http://stackoverflow.com/questions/19269507/accept-only-digits-for-hinputtext-value
//

package cz.ucl.jsf.controller;

import java.io.IOException;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import javax.faces.application.FacesMessage;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;
import javax.faces.context.ExternalContext;
import javax.faces.context.FacesContext;
import javax.persistence.EntityManager;
import javax.servlet.http.HttpServletRequest;
import cz.ucl.fa.model.Contract;
import cz.ucl.fa.model.CreditCard;
import cz.ucl.fa.model.Customer;
import cz.ucl.fa.model.Holiday;
import cz.ucl.fa.model.Traveller;
import cz.ucl.fa.model.util.JPAUtil;
//import javax.annotation.PostConstruct;
//import javax.annotation.PreDestroy;


@ManagedBean(name = "purchaseController")
@SessionScoped
public class PurchaseController implements Serializable {

	/**
	 * Vznikající objekt smlouvy
	 */
	private Contract contract = new Contract();
	private Customer customer;
	private List<Traveller> allTravellers = new ArrayList<>();

	private List<Holiday> allHolidays;
	private Long currentHolidayId = 1L;
	private Holiday currentHoliday = new Holiday();
	private int travellersCount = 0;
	private Double currentPrice = 0.0;
	private String saveMssageDetails = "";
	private String saveStatus = "Not sent";

	/**
	 * Pomocné objekty pro přidávání cestujících do smlouvy
	 */
	private Traveller currentTraveller;
	private Integer selectedTravellerPos;
	private List<Traveller> travellers;

	/**
	 * Proměnné pro práci s existujícími zákazníky
	 */
	private boolean existingCustomer;
	private Long existingCustomerId;

	/**
	 * Asociativní pole Název->ID všech zájezdů
	 */
	private Map<String, Long> allTrips;

	/**
	 * Pomocná pole pro ukládání čísla a platnosti kreditní karty
	 */
	private String[] creditCardNo = new String[4];
	private String[] creditCardValidity = new String[2];

	public String[] getCreditCardNo() {
		return creditCardNo;
	}

	public void setCreditCardNo(String[] creditCardNo) {
		this.creditCardNo = creditCardNo;
	}

	public String[] getCreditCardValidity() {
		return creditCardValidity;
	}

	public void setCreditCardValidity(String[] creditCardValidity) {
		this.creditCardValidity = creditCardValidity;
	}

	/**
	 * setters/getters
	 */

	public int getTravellersCount() {
		return travellersCount;
	}

	public Long getCurrentHolidayId() {
		return currentHolidayId;
	}

	public void setCurrentHolidayId(Long currentHolidayId) {
		this.currentHolidayId = currentHolidayId;
	}

	public List<Traveller> getAllTravellers() {
		return allTravellers;
	}

	public Customer getCustomer() {
		if (customer == null) {
			customer = new Customer();
		}
		return customer;
	}

	public void setCustomer(Customer customer) {
		this.customer = customer;
	}

	public Double getCurrentPrice() {
		return currentPrice;
	}

	public Traveller getCurrentTraveller() {
		if (currentTraveller == null) {
			currentTraveller = new Traveller();
		}
		return currentTraveller;
	}

	public void setCurrentTraveller(Traveller currentTraveller) {
		this.currentTraveller = currentTraveller;
	}

	public Integer getSelectedTravellerPos() {
		return selectedTravellerPos;
	}

	public void setSelectedTravellerPos(Integer selectedTravellerPos) {
		this.selectedTravellerPos = selectedTravellerPos;
	}

	public List<Traveller> getTravellers() {
		return travellers;
	}

	public void setTravellers(List<Traveller> travellers) {
		this.travellers = travellers;
	}

	/********************************************************************
	 * logika
	 ********************************************************************/

	/**
	 * Vrací seznam všech katalogových zájezdu z databáze
	 */
	@SuppressWarnings("unchecked")
	public List<Holiday> getAllHolidays() {
		EntityManager em = JPAUtil.createEntityManager();
		allHolidays = (List<Holiday>) em.createNamedQuery("Trip.getFixed").getResultList();
		em.close();
		updateCurrentHoliday();
		return allHolidays;
	}

	/**
	 * Přidá travellery
	 */
	public String addTraveller() {

		if (currentTraveller != null) {
			allTravellers.add(currentTraveller);
			currentTraveller = null;
		}
		travellersCount = allTravellers.size();
		return "Traveller added";
	}

	/**
	 * Ukládá aktuální hodnotu objektu currentHoliday do databáze
	 */
	public String saveContract() {

		// 1. new CC obj
		// System.out.println(" faze 1, ziskavam cc detaily");
		String ccJoined = creditCardNo[0] + creditCardNo[1] + creditCardNo[2] + creditCardNo[3];
		CreditCard cc = new CreditCard();
		cc.setNumber(ccJoined);
		cc.setValidity(creditCardValidity[0] + creditCardValidity[1]);
		cc.setOwnerName(customer.getFirstName().toUpperCase() + " " + customer.getSurname().toUpperCase());

		// 2. nastaví card na customer
		customer.setCard(cc);

		// 3. nastaví customer na contract
		contract.setCustomer(customer);

		// 4. start Entity manager
		try {
			EntityManager em = JPAUtil.createEntityManager();
			em.getTransaction().begin();

			// 1. ukládání napřímo
			// em.persist(currentHoliday); -- zpusobovalo disconnect chyby
			contract.setHoliday(em.find(Holiday.class, currentHolidayId));

			// 2. CC
			System.out.println("!1 - persist cc: ");
			em.persist(cc);

			// 3. contract
			// System.out.println("!3 - persist contract ");
			// System.out.println("cur custno:" + customer.getId());
			em.persist(contract);

			// 4. travellers (ukazuji na contract)
			System.out.println("!3a - persist travellers ");
			for (Iterator<Traveller> it = allTravellers.iterator(); it.hasNext();) {
				Traveller t = it.next();
				t.setContract(contract);
				em.persist(t);
			}

			// 5. commit
			em.getTransaction().commit();
			em.close();

			// 6. message for next window
			saveMssageDetails = "The order of customer " + customer.getFirstName() + " " + customer.getSurname()
					+ " with total price: " + travellersCount * currentHoliday.getPrice() + " for trip to "
					+ currentHoliday.getName() + " was saved to the system";

			// 6. cleanup and return if success
			// System.out.println("!!! saveContract !!!");
			clearPurchase();
			saveStatus = "Saved";
			return "holiday_saved";

		} catch (RuntimeException re) {
			System.out.println("******************************************************");
			System.out.println("persist failed" + re);
			System.out.println("******************************************************");

			saveMssageDetails = "Error: Saving of the travel order failed. Please contact support personnel";
			saveStatus = "Not sent";
			throw re;

		}

	}

	public String getSaveMssageDetails() {
		return saveMssageDetails;
	}

	public String getSaveStatus() {
		return saveStatus;
	}

	/**
	 * Vyčistí proměnné a okno - nedojde k odpojení od objektů po uložení
	 */
	public void clearPurchase() {
		customer = null;
		creditCardNo = new String[4];
		creditCardValidity = new String[2];

		allTravellers = new ArrayList<>();
		// currentHolidayId=1L;
		contract = new Contract();
		travellersCount = 0;
	}

	public void clearAndRefreshPurchase() {
		clearPurchase();
		// refreshe by mely prekreslit okno
		try {
			reload();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	public void reload() throws IOException {
		ExternalContext ec = FacesContext.getCurrentInstance().getExternalContext();
		ec.redirect(((HttpServletRequest) ec.getRequest()).getRequestURI());
	}

	/**
	 * Vrací seznam všech katalogových zájezdu z databáze
	 */
	public Holiday getCurrentHoliday() {
		if (currentHolidayId != null) {
			for (Holiday holiday : allHolidays) {
				if (holiday.getId().equals(currentHolidayId)) {
					return holiday;
				}
			}
		}
		System.out.println("!ERROR - nenasel jasem id" + currentHolidayId + "ve allHolidays" + allHolidays.size());
		return null;
	}

	/**
	 * Pomocná proměnná pro práci se zvolenou dovolenou
	 */
	public void updateCurrentHoliday() {
		for (Holiday holiday : allHolidays) {
			if (holiday.getId().equals(currentHolidayId)) {
				currentHoliday = holiday;
			}
		}

		if (currentHoliday == null) {
			System.out.println("!ERROR: updateCurrentPrice didnt find value in allHolidays ");
		}

	}

	/**
	 * Vyhledá všechny katalogové zájezdy a naplní je do asociativního pole
	 * allTrips (v podobě vhodné k použití pro f:selectItems)
	 */
	@SuppressWarnings("unchecked")
	public Map<String, Long> getAllTrips() {
		if (allTrips == null) {
			allTrips = new TreeMap<String, Long>();
			allTrips.put("", -1L);

			EntityManager em = JPAUtil.createEntityManager();
			List<Object[]> queryResult = em.createNamedQuery("Trip.getAllNamesAndIds").getResultList();
			for (Object[] item : queryResult) {
				allTrips.put((String) item[0], (Long) item[1]);
			}
		}
		return allTrips;
	}

	/**
	 * Na základě nastavení identifikátoru zájezdu (bude voláno JSF implementací
	 * poté, co uživatel vybere ze seznamu) z databáze načte objekt typu Holiday
	 * a naplní do vznikajícího objektu smlouvy (contract)
	 */
	public void setSelectedTripId(long selectedTripId) {
		if (selectedTripId != -1) {
			EntityManager em = JPAUtil.createEntityManager();
			Holiday selectedHoliday = em.find(Holiday.class, selectedTripId);
			selectedHoliday.getAccommodation().size();
			selectedHoliday.getTransportation().size();
			selectedHoliday.getServices().size();
			contract.setHoliday(selectedHoliday);
			em.close();
		}
	}

	/**
	 * Pro existujícího zákazníka zkopíruje jméno/příjmení z databáze pro -
	 * nepoužito nastavení hodnot do objektu currentTraveller.
	 */
	public void copyTravellerFromCustomer() {
		currentTraveller = new Traveller();
		if (existingCustomer && existingCustomerId != null) {
			EntityManager em = JPAUtil.createEntityManager();
			Customer existingCustomerValue = (Customer) em.find(Customer.class, existingCustomerId);
			currentTraveller.setSurname(existingCustomerValue.getSurname());
			currentTraveller.setFirstName(existingCustomerValue.getFirstName());
			em.close();
		} else {
			currentTraveller.setSurname(contract.getCustomer().getSurname());
			currentTraveller.setFirstName(contract.getCustomer().getFirstName());
		}

	}

	/**
	 * Odebere dopravní spojení ze zájezdu - nepoužito
	 */
	public String removeTraveller(Traveller traveller) {
		allTravellers.remove(traveller);
		System.out.println("!!!!!!removing " + traveller.getFirstName());
		travellersCount = allTravellers.size();
		return null;
	}

	/**
	 * - nepoužito Provede potvrzení smlouvy a její zápis do databáze. Rozlišuje
	 * mezi existujícím a novým zákazníkem. Neobsahuje (zatím) validace
	 */
	public String confirmContract() {
		EntityManager em = JPAUtil.createEntityManager();
		if (existingCustomer) {
			if (existingCustomerId == null) {
				FacesContext.getCurrentInstance().addMessage(null,
						new FacesMessage("No customer selected", "No existing customer was selected"));
				return "validationError";
			} else {
				contract.setCustomer((Customer) em.find(Customer.class, existingCustomerId));
			}
		} else {
			CreditCard card = new CreditCard();
			card.setNumber(creditCardNo[0] + creditCardNo[1] + creditCardNo[2] + creditCardNo[3]);

			card.setValidity(creditCardValidity[0] + creditCardValidity[1]);
			card.setOwnerName(contract.getCustomer().getName());
			contract.getCustomer().setCard(card);
		}

		em.getTransaction().begin();
		contract.setHoliday(em.merge(contract.getHoliday()));
		em.persist(contract);
		em.getTransaction().commit();

		return "confirmed";
	}

}
