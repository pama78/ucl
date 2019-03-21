package cz.unicorncollege.controller;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;


import cz.unicorncollege.bt.model.MeetingCentre;
import cz.unicorncollege.bt.model.MeetingRoom;
import cz.unicorncollege.bt.model.Reservation;
import cz.unicorncollege.bt.utils.Choices;
import cz.unicorncollege.bt.utils.Logger;

public class ReservationController {
	private MeetingController meetingController;
	private MeetingCentre actualMeetingCentre;
	private MeetingRoom actualMeetingRoom;
	private Date actualReservationDate;
	private Logger logger = Logger.getInstance();
	private static final String  DATE_SLASH_FMT = "dd/MM/yyyy";	
	
	/**
	 * Constructor for ReservationController class
	 * 
	 * @param meetingController
	 *            loaded data of centers and its rooms
	 *       
	 */
		
	public ReservationController(MeetingController meetingController) {
		this.meetingController = meetingController;
		this.actualReservationDate = new Date();
	}

	/**
	 * Method to show options for reservations
	 */
	public void showReservationMenu() {
		List<String> choices = new ArrayList<String>();

		// Meeting centres
		int meetingCentresCount = meetingController.getMeetingCentres().size();
		if (meetingCentresCount == 0) {
			System.out.println("\n  No meeting center detected. Return to main menu. \n");
			return;
		}

		int counterMeetingCentres = 0;
		for (MeetingCentre centre : meetingController.getMeetingCentres()) {
			counterMeetingCentres++;
			System.out.println("  " + counterMeetingCentres + ".) " + centre.getCode());
			choices.add(centre.getCode() + " - " + centre.getName());
		}

		while (true) {
			String chosenOption = Choices.getInput("Choose the Meeting Centre (1.." + meetingCentresCount + ") : ");
			try {
				int chosenInt = Integer.parseInt(chosenOption);
				if ((chosenInt >= 1) && (chosenInt <= meetingCentresCount)) {
					actualMeetingCentre = meetingController.getMeetingCentres().get(chosenInt - 1);
					System.out.println(">  Chosen meeting Centre: " + actualMeetingCentre.getName());
					System.out.println("\nList of Meeting Rooms:");
					break;
				} else {
					System.out.println(" *User entry validation failed (wrong number): please type a number between 1 and " + meetingCentresCount);
				}
			} catch (Exception e) {
				System.out.println(" *User entry validation failed (not a number): please type a number between 1.." + meetingCentresCount);
				continue;
			}
		}
		choices.clear();

		// display rooms from actual meeting center
		if (actualMeetingCentre.getMeetingRooms() == null) {
			System.out.println("\n  No meeting room detected for selected Meeting centre. Return to main menu.\n");
			return;
		}

		int meetingRoomsCount = actualMeetingCentre.getMeetingRooms().size();
		int counterMeetingRooms = 0;
		for (MeetingRoom room : actualMeetingCentre.getMeetingRooms()) {
			counterMeetingRooms++;
			System.out.println("  " + counterMeetingRooms + ".) " + room.getCode() + " - " + room.getName());
			choices.add(room.getCode() + " - " + room.getName());
		}

		while (true) {
			String chosenOption = Choices.getInput("Choose the Meeting Room (1.." + meetingRoomsCount + ") : ");
			try {
				int chosenInt = Integer.parseInt(chosenOption);
				if ((chosenInt >= 1) && (chosenInt <= meetingRoomsCount)) {
					actualMeetingRoom = actualMeetingCentre.getMeetingRooms().get(chosenInt - 1);
					System.out.println(">  Chosen Meeting Centre: " + actualMeetingRoom.getName());
					break;
				} else {
					System.out.println(" *User entry validation failed (wrong number): please type a number between 1 and "+ meetingRoomsCount);
				}
			} catch (Exception e) {
				System.out.println(" *User entry validation failed (not a number): please type a number between 1.."+ meetingRoomsCount);
				continue;
			}
		}
		choices.clear();
		getItemsToShow();
	}

	private void addNewReservation() {
		logger.debug("#addNewReservation entered for actual meeting room:" + actualMeetingRoom.toString(), "OL");
		Reservation currentReservation = new Reservation();

		// add known data. MeetingRoom
		if (actualMeetingRoom == null) {
    		System.out.println(" *please select the meetingRoom first. returning back");
			return;
		}
		logger.debug("adding current meetingroom to the reservation. MC=" + actualMeetingRoom, "OL");
		currentReservation.setMeetingRoom(actualMeetingRoom);
		
		// date
		System.out.println("Date taken: " + getFormattedDate());
		String currentDate = getFormattedDate();
		SimpleDateFormat sdf = new SimpleDateFormat(DATE_SLASH_FMT);
		
		try {
			currentReservation.setDate(sdf.parse(currentDate));
			logger.debug("added current formatted date to the reservation date=" + currentDate, "OL");
		} catch (ParseException e) {
			System.out.println(" \n*cannot convert the value of curDate "+currentDate+" to date" );
		}
		
		// fromDate
		String reservationFromDate = "";
		while (true) {
			reservationFromDate = Choices
					.getInput("Enter the time of reservation start on day <" + currentDate + "> in format <HH24:MI>: ");
			if (reservationFromDate.matches("^[0-2][0-9]:[0-5][0-9]$")) {
				String reservationFromDateStr = currentDate + " " + reservationFromDate;
				Date reservationFromDateDate = currentReservation.convertStringToDateFull(reservationFromDateStr);

				if (reservationFromDateDate != null) {
					logger.debug("fromDate validated and passed: " + reservationFromDateDate, "OL");
					if (currentReservation.isWithinRange(actualMeetingRoom, reservationFromDateStr, null)) {
						currentReservation.setTimeFrom(reservationFromDate);
						break;
					} else {
						System.out.println(
								" \n*user data entry error. the date shouldn't overlap with other reservations. please try again.");
					}
				} else {
					System.out.println(" \n*user data entry error. the value can be only time (HH:MM) and was: "
							+ reservationFromDate);
				}
			} else {
				System.out
						.println(" \n*user data entry error(format broken). The value can be only time (HH:MM) an was: "
								+ reservationFromDate);
			}
		}
		
		// toDate - set lenient false didnt report error on time as 1:1, so added also the format check 
		while (true) {
			String reservationToDate = Choices
					.getInput("Enter the time of reservation end on day <" + currentDate + "> in format <HH24:MI>: ");
			if (reservationToDate.matches("^[0-2][0-9]:[0-5][0-9]$")) {
				String reservationToDateStr = currentDate + " " + reservationToDate;
				Date reservationToDateDate = currentReservation.convertStringToDateFull(reservationToDateStr);
				if (reservationToDateDate != null) {
					logger.debug("toDate validated and passed: " + reservationToDateDate, "OL");
					// check overlap in two phases, 1. end date if its in some
					// range, 2. if the new reservation holds some smaller
					// inside
					if ((currentReservation.isWithinRange(actualMeetingRoom, reservationToDateStr, null))
							&& (currentReservation.isWithinRange(actualMeetingRoom,
									currentDate + " " + reservationFromDate, reservationToDateStr))) {
						currentReservation.setTimeTo(reservationToDate);
						break;
					} else {
						System.out.println(
								" \n*user data entry error. the date shouldn't overlap with other reservations. please try again.");
					}
				} else {
					System.out.println(" \n*user data entry error. the value can be only time (HH:MM) and was: "
							+ reservationToDate);
				}
			} else {
				System.out.println(
						" \n*user data entry error(format broken). The value can be only time (HH:MM) an was: " + reservationToDate);
			}
		}

		// persons
		while (true) {
			String resExpectedPersons = Choices
					.getInput("Enter the expected persons to come (1.." + actualMeetingRoom.getCapacity() + "): ");
			boolean isValidationPassed = currentReservation.validateExpectedPersonCount(resExpectedPersons,
					actualMeetingRoom.getCapacity());
			if (isValidationPassed) {
				logger.debug("validateExpectedPersonCount returned success", "OL");
				currentReservation.setExpectedPersonCount(Integer.valueOf(resExpectedPersons));
				break;
			} else {
				logger.debug(
						" *user data entry error. the value can be only between 1 and current max capacity of the room ("
								+ actualMeetingRoom.getCapacity() + "). received value was: " + resExpectedPersons,	"OL");
			}
		}

		// customer
		while (true) {
			String resCustomer = Choices.getInput("Enter the Customer name (2..100 chars): ");
			boolean isValidationPassed = currentReservation.validateCustomer(resCustomer);
			if (isValidationPassed) {
				logger.debug("validateExpectedPersonCount returned success", "OL");
				currentReservation.setCustomer(resCustomer);
				break;
			} else {
				logger.debug(" *user data entry error. the value can be only between 2 and 100 characters. Received value was: " + resCustomer,"OL");
			}
		}

		// videoconf
		if (actualMeetingRoom.isHasVideoConference()) {
			loop: while (true) {
				String resVideo = Choices.getInput("Do you want to configure the video conference? (Y/N): ");
				switch (resVideo) {
				case "Y":
					logger.debug("  Chosen Y - request video configuration = Y", "OL");
					currentReservation.setNeedVideoConference(true);
					break loop;
				case "N":
					logger.debug("  Chosen N - request video configuration = N", "OL");
					currentReservation.setNeedVideoConference(false);
					break loop;
				default:
					System.out.println("\n *user entry error. only Y/N is allowed. please try again. \n ");
				}
			}
		} else {
			currentReservation.setNeedVideoConference(false); // dosent have
		}

		// Notes
		while (true) {
			String resNote = Choices.getInput("Enter the Reservation note (0.300 chars): ");
			boolean isValidationPassed = currentReservation.validateNote(resNote);
			if (isValidationPassed) {
				logger.debug("validateNote returned success", "OL");
				currentReservation.setNote(resNote);
				break;
			} else {
				logger.debug(
						" *user data entry error. the value can be only between 0 and 300 characters. Received value was: "+ resNote,"OL");
			}
		}

		// if got here, send the data to MeetingRoom
		logger.debug("adding current reservation to the meetingroom", "OL");
		actualMeetingRoom.addReservation(currentReservation);
		logger.debug(" added new reservation curRes= " + currentReservation + " to meeting centre " + actualMeetingRoom.getCode(),"OL");
	}

	/*
	 * getReservationObject - for delete/update of reservation
	 */
	private Reservation getReservationObject() {
		Reservation selectedReservation = null;

		List<String> choices = new ArrayList<String>();
		List<Reservation> listReservationsOnDay = actualMeetingRoom.getSortedReservationsByDate(actualReservationDate);
		if (listReservationsOnDay != null && listReservationsOnDay.size() > 0) {
			System.out.println("");
			int reservationsCounter = 0;
			System.out.println("Reservations for: " + getActualData());
			for (Reservation reservation : listReservationsOnDay) {
				reservationsCounter++;
				System.out.println(reservationsCounter + ".) " + reservation.getTimeFrom() + "-" + reservation.getTimeTo() + " :: " + reservation.getCustomer() + " :: " + reservation.getNote() );
				choices.add(reservation.getTimeFrom() + "-" + reservation.getTimeTo());
			}
			System.out.println("");
		} else {
			System.out.println("");
			System.out.println("There are no reservation for " + getActualData());
			System.out.println("");
			return null;
		}

		int reservationsCount = listReservationsOnDay.size();
		while (true) {
			String chosenOption = Choices.getInput("Choose the Reservation (1.." + reservationsCount + ") : ");
			try {
				int chosenInt = Integer.parseInt(chosenOption);
				if ((chosenInt >= 1) && (chosenInt <= reservationsCount)) {
					selectedReservation = listReservationsOnDay.get(chosenInt - 1);
					System.out.println(	"  chosen reservation: " + chosenInt + " with start date:" + selectedReservation.getTimeFrom());
					break;
				} else {
					System.out.println(	" *User entry validation failed (wrong number): please type a number between 1 and "+ reservationsCount);
				}
			} catch (Exception e) {
				System.out.println(
						" *User entry validation failed (not a number): please type a number between 1.." + reservationsCount);
				continue;
			}
		}

		return selectedReservation;
	}

	private void editReservation() {
		Reservation selectedReservation = getReservationObject();
		if (selectedReservation == null) {
			System.out.println("* Nothing selected, not deleting any reservation");
			return;
		} else {
			System.out.println("* User selected reservation starting on:" + selectedReservation.getTimeFrom());
		}

		// ask for confirm
		String validateOption = Choices.getInput("Are you sure, you want to update reservation: " + selectedReservation.getTimeFrom() + "(Y/N)?:");
		System.out.println("> chosen:" + validateOption);
		if (!validateOption.equalsIgnoreCase("Y")) {
			System.out.println("\n* User didn't confirm updating the reservation. Returning.. \n");
			return;
		}

		// persons
		int origPersonCount = selectedReservation.getExpectedPersonCount();
		while (true) {
			String newPersonCount = Choices.getInput("Enter the expected persons to come (1.."
					+ actualMeetingRoom.getCapacity() + ") or enter to leave original (" + origPersonCount + "): ");
			if (newPersonCount.isEmpty()) {
				break;
			} // leave original if enter
			boolean isValidationPassed = selectedReservation.validateExpectedPersonCount(newPersonCount,
					actualMeetingRoom.getCapacity());
			if (isValidationPassed) {
				logger.debug("validateExpectedPersonCount returned success", "OL");
				selectedReservation.setExpectedPersonCount(Integer.valueOf(newPersonCount));
				break;
			} else {
				logger.debug(" *user data entry error. the value can be only between 1 and current max capacity of the room ("
								+ actualMeetingRoom.getCapacity() + "). received value was: " + newPersonCount, "OL");
			}
		}

		// customer
		String origCustomer = selectedReservation.getCustomer();
		while (true) {
			String newCustomer = Choices.getInput(
					"Enter the Customer name (2..100 chars) or enter to leave original (" + origCustomer + "): ");
			if (newCustomer.isEmpty()) {
				break;
			} // leave original
			boolean isValidationPassed = selectedReservation.validateCustomer(newCustomer);
			if (isValidationPassed) {
				logger.debug("validateExpectedPersonCount returned success", "OL");
				selectedReservation.setCustomer(newCustomer);
				break;
			} else {
				logger.debug(" *user data entry error. the value can be only between 2 and 100 characters. Received value was: "+ newCustomer,"OL");
			}
		}

		// videoconf
		if (actualMeetingRoom.isHasVideoConference()) {
			String origIsNeedVideoConferenceStr = "";
			if (selectedReservation.isNeedVideoConference()) {
				origIsNeedVideoConferenceStr = "Y";
			} else {
				origIsNeedVideoConferenceStr = "N";
			}

			loop: while (true) {
				String newIsNeedVideo = Choices
						.getInput("Do you want to configure the video conference? (Y/N) or enter to leave original ("
								+ origIsNeedVideoConferenceStr + "): ");
				if (newIsNeedVideo.isEmpty()) {
					break;
				} // leave original

				switch (newIsNeedVideo) {
				case "Y":
					logger.debug("  Chosen Y - request video configuration = Y", "OL");
					selectedReservation.setNeedVideoConference(true);
					break loop;
				case "N":
					logger.debug("  Chosen N - request video configuration = N", "OL");
					selectedReservation.setNeedVideoConference(false);
					break loop;
				default:
					System.out.println("\n *user entry error. only Y/N is allowed. please try again. \n ");
				}
			}
		}

		// Notes
		String origNote = selectedReservation.getNote();
		while (true) {
			String newNoteStr = Choices.getInput(
					"Enter the Reservation note (0..300 chars) or enter to leave original (" + origNote + "): ");
			if (newNoteStr.isEmpty()) {
				break;
			} // leave original
			boolean isValidationPassed = selectedReservation.validateNote(newNoteStr);
			if (isValidationPassed) {
				logger.debug("validateNote returned success", "OL");
				selectedReservation.setNote(newNoteStr);
				break;
			} else {
				logger.debug(" *user data entry error. the value can be 0..300 characters. Received value was: " + newNoteStr,"OL");
			}
		}

		logger.debug("finished updates", "OL");
		logger.debug("actualMeetingRoom:" + actualMeetingRoom.getCode(), "OL");

	}

	private void deleteReservation() {
		Reservation selectedReservation = getReservationObject();
		if (selectedReservation == null) {
			System.out.println("* Nothing selected, not deleting any reservation");
			return;
		} else {
			System.out.println("* User selected reservation starting on:" + selectedReservation.getTimeFrom());

			// ask for confirm
			String validateOption = Choices
					.getInput("Are you sure, you want to delete reservation " + selectedReservation.getTimeFrom() + "-" + selectedReservation.getTimeFrom() + " (Y/N)?:");
			
			System.out.println("chosen:" + validateOption);
			if (validateOption.equalsIgnoreCase("Y")) {
				// actual delete after confirmation
				logger.debug("  about to delete object: " + selectedReservation, "OL");
				logger.debug("  before delete: " + actualMeetingRoom.getSortedReservationsByDate(actualReservationDate), "OL");
				List<Reservation> copyReservations = actualMeetingRoom.getReservations();
				if (copyReservations.remove(selectedReservation)) {
					System.out.println("deleted selected item " );
					actualMeetingRoom.setReservations(copyReservations);
					actualMeetingRoom.getSortedReservationsByDate(actualReservationDate);
					logger.debug("delete succeeded. meeting objects fter delete: "
							+ actualMeetingRoom.getSortedReservationsByDate(actualReservationDate), "OL");
				} else {
					System.out.println("delete reservation returned problem - probably item " + selectedReservation	+ " was not found \n ");
				}
			} else {
				System.out.println("\n* user didn't confirm the deletion of the reservation. Leaving it undeleted.\n");
			}
		}

	}

	public boolean validateDate(String inputDate) {
		SimpleDateFormat format = new SimpleDateFormat(DATE_SLASH_FMT);
	    format.setLenient(false);
		logger.debug("validateTimeFormat input was: " + inputDate, "OL");

		try {
			Date strToDate=(format.parse(inputDate));
			logger.debug("validateTimeFormat passed: " + strToDate, "OL");
			return true;
		} catch (java.text.ParseException e) {
			return false;
		}
	}

	public String formatDate(Date date) {
		SimpleDateFormat sdf = new SimpleDateFormat(DATE_SLASH_FMT);
		return sdf.format(date);
	}

	private void changeDate() {
		SimpleDateFormat sdf = new SimpleDateFormat(DATE_SLASH_FMT);
		sdf.setLenient(false);
				
		if (actualReservationDate == null) {  //default day is today
			actualReservationDate = new Date();
		}

		while (true) {
			String newDate = Choices.getInput("Old Date was <" + formatDate(actualReservationDate)
					+ ">. Enter the new date in format <DD/MM/YYYY> or enter to leave current one: ");
			if (newDate.isEmpty()) {
				logger.debug("leaving original date: " + actualReservationDate, "OL");
				break;
			}

			if (validateDate(newDate)) {
				logger.debug("new Date validated and passed: " + newDate, "OL");
				try {

					actualReservationDate = sdf.parse(newDate);
				} catch (ParseException e) {
					System.out.println(" \n*user data entry error. the value can be only date and was: " + newDate);
				}
				break;

			} else {
				System.out.println(" \n*user data entry error. the value can be only date and was: " + newDate);

			}
		}
	}

	private void getItemsToShow() {

		//listReservationsByDate(actualResDate);

		List<String> choices = new ArrayList<String>();
		choices.add("Edit Reservations");
		choices.add("Add New Reservation");
		choices.add("Delete Reservation");
		choices.add("Change Date");
		choices.add("Exit");

		while (true) {
			listReservationsByDate(actualReservationDate); // moved here

			switch (Choices.getChoice("Select an option: ", choices)) {
			case 1:
				editReservation();
				break;
			case 2:
				addNewReservation();
				break;
			case 3:
				deleteReservation();
				break;
			case 4:
				changeDate();
				break;
			case 5:
				return;
		    default:
		    	System.out.println("ERROR in user input. please choose value between 1 and 5");
			}
		}
	}

	private void listReservationsByDate(Date date) {
		// list reservations - for given date
		logger.debug("\nvstoupil do listReservationsByDate s: " + date ,"OL");
		List<Reservation> list = actualMeetingRoom.getSortedReservationsByDate(date);
		if (list != null && list.size() > 0) {
			System.out.println("");
			System.out.println("Reservations for " + getActualData());
			for (Reservation reservation : list) {
				System.out.println("   " + reservation.getTimeFrom() + "-" + reservation.getTimeTo() + " :: " + reservation.getCustomer());
			}
			System.out.println("");
		} else {
			System.out.println("");
			System.out.println("There are no reservation for " + getActualData());
			System.out.println("");
		}
	}

	/**
	 * Method to get formatted actual date
	 * 
	 * @return
	 */
	private String getFormattedDate() {
		SimpleDateFormat sdf = new SimpleDateFormat(DATE_SLASH_FMT);
		return sdf.format(actualReservationDate);

	}

	/**
	 * Method to get actual name of place - meeteng center and room
	 * 
	 * @return
	 */
	private String getCentreAndRoomNames() {
		return "MC: " + actualMeetingCentre.getName() + " , MR: " + actualMeetingRoom.getName();
	}

	/**
	 * Method to get actual state - MC, MR, Date
	 * 
	 * @return
	 */
	private String getActualData() {
		return getCentreAndRoomNames() + ", Date: " + getFormattedDate();
	}
	
	
}
