package cz.unicorncollege.bt.model;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import cz.unicorncollege.bt.utils.Logger;


public class MeetingRoom extends MeetingObject {
	private int capacity;
	private boolean hasVideoConference;
	private MeetingCentre meetingCentre;
	private List<Reservation> reservations; // DU3
	private Logger logger = Logger.getInstance();

	public int getCapacity() {
		return capacity;
	}

	public void setCapacity(int capacity) {
		this.capacity = capacity;
	}

	public boolean isHasVideoConference() {
		return hasVideoConference;
	}

	public void setHasVideoConference(boolean hasVideoConference) {
		this.hasVideoConference = hasVideoConference;
	}

	public MeetingCentre getMeetingCentre() {
		return meetingCentre;
	}

	public void setMeetingCentre(MeetingCentre meetingCentre) {
		this.meetingCentre = meetingCentre;
	}

	public List<Reservation> getReservations() {
		return reservations;
	}

	public void addReservation(Reservation reservation) {

		if (reservations == null) {
			reservations = new ArrayList<>();
		}
		this.reservations.add(reservation);
	}

	public int reservationStartAsIntXX(Reservation reservation) {
		String[] partsHourMinute = reservation.getTimeFrom().split(":");
		int timeFromAsInt = Integer.parseInt(partsHourMinute[0] + partsHourMinute[1]);
		return timeFromAsInt;
	}

	public List<Reservation> getSortedReservationsByDate(Date reservationDate) {
		logger.debug("* Entered to getSortedReservationsByDate with parametrem: " + reservationDate, "OL");
		List<Reservation> reservationsFiltered = new ArrayList<>();
		SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");
		String curDateStr = dateFormat.format(reservationDate);
		logger.debug("  ..getSortedReservationsByDate, date:" + curDateStr, "OL");
		if (reservations != null) {
			for (Reservation reservation : reservations) {
				if (reservation.getFormattedDate().equals(curDateStr)) {

					logger.debug("getSortedReser.... on date: " + curDateStr + " getTimeFrom "
							+ reservation.getTimeFrom() + " getTimeTo: " + reservation.getTimeTo(), "OL");
					reservationsFiltered.add(reservation);
				}
			}
		}

		// order inside
		Collections.sort(reservationsFiltered, new StartTimeComparator());
		return reservationsFiltered;
	}


	/* 
	 *   getAllReservationDates - show the dates, which have at least one reservation on the room 
	 *   sort array list: http://stackoverflow.com/questions/12561396/sorting-of-date-arraylist
	 */
	public List<Date> getAllReservationDates() {
		List<Date> allDates = new ArrayList<>();
		if (reservations != null) {
			for (Reservation reservation : reservations) {
				if (!allDates.contains(reservation.getDate())) {
					allDates.add(reservation.getDate());
				}
			}
		}
		
		Collections.sort(allDates);
		return allDates;
	}

	/* 
	 *   getAllReservationDatesAndCounts - to show after import, on which days and how many reservations we have per each day 
	 */
	public List<String> getAllReservationDatesAndCounts() {
		List<Date> allDates = new ArrayList<>();
		List<String> allDatesString = new ArrayList<>();

		if (reservations != null) {
			for (Reservation reservation : reservations) {
				if (!allDates.contains(reservation.getDate())) {
					allDates.add(reservation.getDate());
					int reservationsCountOnDay = this.getSortedReservationsByDate(reservation.getDate()).size();
					allDatesString.add(reservation.getFormattedDate() + "(" + reservationsCountOnDay + ")");
				}
			}
		}
		return allDatesString;
	}


	public void setReservations(List<Reservation> reservations) {
		this.reservations = reservations;
	}

}
