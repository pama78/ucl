package cz.ucl.jsf.controller;

import java.io.Serializable;
import java.util.List;

import javax.annotation.PostConstruct;
import javax.annotation.PreDestroy;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.persistence.EntityManager;

import cz.ucl.fa.model.Customer;
import cz.ucl.fa.model.util.JPAUtil;

@ManagedBean(name="customerController")
@ViewScoped
public class CustomerController implements Serializable {
	private String searchSurname;
	private List<Customer> customersFound;	

	private Long selectedCustomerId;
	private Customer currentCustomer;
	
	
	@PostConstruct
	public void init() {
		System.out.println("!!! Customer Controller initialized for VIEW SCOPE: " + this.toString());
	}
	
	@PreDestroy 
	public void destroy() {
		System.out.println("!!! Customer Controller destroyed at the end of the VIEW SCOPE: " + this.toString());
	}

	public String getSearchSurname() {
		return searchSurname;
	}

	public void setSearchSurname(String searchSurname) {
		this.searchSurname = searchSurname;
	}
	
	public Long getSelectedCustomerId() {
		return selectedCustomerId;
	}
	
	public void setSelectedCustomerId(Long selectedClientId) {
		this.selectedCustomerId = selectedClientId;
	}

	public List<Customer> getCustomersFound() {
		return customersFound;
	}

	/**
	 * Vrací objekt zákazníka, vyhledaný podle identifikátoru selectedCustomerId)
	 * @return
	 */
	public Customer getCurrentCustomer() {
		if (currentCustomer == null) {
			EntityManager em = JPAUtil.createEntityManager();
			
			currentCustomer = (Customer) em
					.createQuery(
							"SELECT c FROM Customer c " +
							"LEFT JOIN FETCH c.contracts contract " +
							"LEFT JOIN FETCH contract.holiday holiday " + 
							"WHERE c.id = :id")
					.setParameter("id", selectedCustomerId).getSingleResult();

			em.close();
		}

		return currentCustomer;
	}

	/**
	 * Do proměnné customersFound vloží seznam zákazníků, nalezených podle
	 * shody prefixu příjmení (z proměnné searchSurname)
	 */
	@SuppressWarnings("unchecked")
	public void searchCustomers() {
		EntityManager em = JPAUtil.createEntityManager();
		customersFound = (List<Customer>) em.createNamedQuery(
				"Customer.findBySurname")
				.setParameter("surname", searchSurname+"%").getResultList();
		em.close();
	}

}
