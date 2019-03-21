package cz.unicorncollege.bt.model;

import java.text.SimpleDateFormat;
import java.util.Comparator;
import java.util.Date;
import java.util.List;
import cz.unicorncollege.bt.utils.Logger;

public class Reservation {
	private MeetingRoom meetingRoom;
	private Date date;
	private String timeFrom;
	private String timeTo;
	private int expectedPersonCount;
	private String customer;
	private boolean needVideoConference;
	private String note;
	private Logger logger = Logger.getInstance();
	private static final String  DATE_SLASH_FMT = "dd/MM/yyyy";		
	private static final String  DATE_TIME_SLASH_FMT = "dd/MM/yyyy HH:mm";								
	    	
	public MeetingRoom getMeetingRoom() {
		return meetingRoom;
	}

	public void setMeetingRoom(MeetingRoom meetingRoom) {
		this.meetingRoom = meetingRoom;
	}

	public Date getDate() {
		return date;
	}

	public String formatDate(Date date) {
		SimpleDateFormat sdf = new SimpleDateFormat(DATE_SLASH_FMT);
		System.out.println("pma formatDate date has in date:" + date + " and wants to return" + sdf.format(date));
		return sdf.format(date);
	}

	public String getTimeFromDate(Date date) {
		SimpleDateFormat sdf = new SimpleDateFormat(DATE_SLASH_FMT);
		System.out.println("pma formatDate date has in date:" + date + " and going to return: " + sdf.format(date));
		return sdf.format(date);
	}

	public String getFormattedDateTime() {
		SimpleDateFormat sdf = new SimpleDateFormat(DATE_SLASH_FMT);
		logger.debug("*entered getFormattedDateTime..", "OL");
		logger.debug("  getFormattedDateTime has in date:" + date + " and going to return: " + sdf.format(date), "OL");
		return sdf.format(date);
	}

	public String getFormattedDate() {
		SimpleDateFormat sdf = new SimpleDateFormat(DATE_SLASH_FMT);
		logger.debug("*entered getFormattedDate..", "OL");
		logger.debug("  getFormattedDate has in date:" + date + " and going to return: " + sdf.format(date), "OL");
		return sdf.format(date);
	}

	public void setDate(Date date) {
		this.date = date;
	}

	public String getTimeFrom() {
		return timeFrom;
	}

	public void setTimeFrom(String timeFrom) {
		this.timeFrom = timeFrom;
	}

	public String getTimeTo() {
		return timeTo;
	}

	public void setTimeTo(String timeTo) {
		this.timeTo = timeTo;
	}

	/*
	 * validate the format of time for data insert purposes
	 */
	public Date convertStringToDateFull(String inputDate) {
		SimpleDateFormat format = new SimpleDateFormat(DATE_TIME_SLASH_FMT);
		format.setLenient(false);

		try {
			Date strToDate = format.parse(inputDate);
			return strToDate;

		} catch (java.text.ParseException e) {
			return null;
		}
	}

	public Date convertStringToDate(String inputDate) {
		SimpleDateFormat format = new SimpleDateFormat(DATE_SLASH_FMT);
		format.setLenient(false);

		try {
			Date strToDate = format.parse(inputDate);
			return strToDate;

		} catch (java.text.ParseException e) {
			return null;
		}
	}

	// for sorting of reservations
	public int reservationStartAsInt(Reservation reservation) {
		String[] partsHourMinute = reservation.getTimeFrom().split(":");
		int timeFromAsInt = Integer.parseInt(partsHourMinute[0] + partsHourMinute[1]);
		return timeFromAsInt;
	}

	// date and time cannot be in range of any other reservation
	// for ranges overlaps we need 2nd param, but not always its populated.
	public Boolean isWithinRange(MeetingRoom meetingRoom, String inputReservationStartStr,
			String inputReservationEndStr) {

		Date inputStartDate = convertStringToDateFull(inputReservationStartStr);
		Date inputEndDate = new Date();

		if (inputReservationEndStr != null) {
			inputEndDate = convertStringToDateFull(inputReservationEndStr); 
		}

		logger.debug("isWithinRange " + inputStartDate, "OL");

		// no reservations, noting to check
		if (meetingRoom.getReservations() == null) {
			return true;
		}

		for (Reservation reservation : meetingRoom.getReservations()) {
			Date loopResFrom = convertStringToDateFull(
					reservation.getFormattedDate() + " " + reservation.getTimeFrom());
			Date loopResTo = convertStringToDateFull(reservation.getFormattedDate() + " " + reservation.getTimeTo());
			logger.debug("loop over found from: " + loopResFrom + "-" + loopResTo, "OL");
			if ((inputStartDate.after(loopResFrom) ) && (inputStartDate.before(loopResTo) )) {
				// conflict - inside
				System.out.println("* Error detected collision with range of (" + loopResFrom + " - " + loopResTo
						+ ") :: " + reservation.getCustomer());
				return false;
			}

			// 2nd parameter, for detecting full overlaps first check, if 2nd is higher then first date
			if (inputReservationEndStr != null) { 
				if (inputEndDate.before(inputStartDate)) {
					System.out.println(
							"* Error detected collision with dates. The end of the meeting should be after the start. Please set the correct date/time.");
					return false;
				}
				// second check - full overlaps
				if ((inputStartDate.before(loopResFrom) ) && (inputEndDate.after(loopResTo) )) {
					System.out.println("* Error detected collision with range of (" + loopResFrom + " - " + loopResTo
							+ ") :: " + reservation.getCustomer());
					return false;
				}

			}

		}

		return true;

	}

	public int getExpectedPersonCount() {
		return expectedPersonCount;
	}

	public void setExpectedPersonCount(int expectedPersonCount) {
		this.expectedPersonCount = expectedPersonCount;
	}

	public boolean validateExpectedPersonCount(String capacity, int maxCapacity) {
		if (capacity.matches("^0*[1-9][0-9]*$")) {
			int capacityInt = Integer.valueOf(capacity);
			if (capacityInt <= maxCapacity) {
				return true; // is number and is less then max
			} else {
				System.out.println("ERROR detected. the number shouldn't be higher then is the room capacity. Please try again.");
				return false; // is number and is more then max
			}
		} else {
			System.out.println("ERROR detected. The the number was expected. Please try again.");
			return false;
		} // not a number
	}

	public String getCustomer() {
		return customer;
	}

	public void setCustomer(String customer) {
		this.customer = customer;
	}

	public Boolean validateCustomer(String customer) {
		if ((customer.length() >= 2) && (customer.length() <= 100)) {
			return true;
		} else {
			return false;
		}
	}

	public Boolean validateNote(String note) {
		if (note.length() <= 300) {
			return true;
		} else {
			return false;
		}
	}

	public boolean isNeedVideoConference() {
		return needVideoConference;
	}

	public void setNeedVideoConference(boolean needVideoConference) {
		this.needVideoConference = needVideoConference;
	}

	public String getNote() {
		return note;
	}

	public void setNote(String note) {
		this.note = note;
	}
}

class StartTimeComparator implements Comparator<Reservation> {
	public int compare(Reservation reservation1, Reservation reservation2) {
		int res1Time = reservationStartAsInt(reservation1);
		int res2Time = reservationStartAsInt(reservation2);

		if (res1Time > res2Time) {
			return 1;
		} else if (res1Time < res2Time) {
			return -1;
		} else {
			return 0;
		}
	}

	private int reservationStartAsInt(Reservation reservation) {
		String[] partsHourMinute = reservation.getTimeFrom().split(":");
		int timeFromAsInt = Integer.parseInt(partsHourMinute[0] + partsHourMinute[1]);
		return timeFromAsInt;
	}

	public void setReservations(List<Reservation> reservations) {
		System.out.println(reservations);

	}

}
