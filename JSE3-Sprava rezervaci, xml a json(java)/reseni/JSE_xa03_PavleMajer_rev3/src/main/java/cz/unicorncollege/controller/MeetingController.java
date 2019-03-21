package cz.unicorncollege.controller;

import java.util.ArrayList;
import java.util.List;

import cz.unicorncollege.bt.model.MeetingCentre;
import cz.unicorncollege.bt.model.MeetingRoom;
import cz.unicorncollege.bt.utils.Choices;
import cz.unicorncollege.bt.utils.FileParser;
import cz.unicorncollege.bt.utils.Logger; //logging improve
import java.util.Iterator;

public class MeetingController {
	private List<MeetingCentre> meetingCentres;
	private Logger logger = Logger.getInstance();

	public List<MeetingCentre> getMeetingCentres() {
		return meetingCentres;
	}

	public void setMeetingCentres(List<MeetingCentre> meetingCentres) {
		this.meetingCentres = meetingCentres;
	}

	/**
	 * Method to initialize data from the saved datafile. - nacist z ulozeneho
	 * souboru vsechna meeting centra a vypsat je na obrazovku
	 */
	public void init() {
		logger.debug("#init entered ", "OL");
		meetingCentres = FileParser.loadDataFromFile();
		FileParser.importReservations(getMeetingCentres()); // add reservations
															// at start

		// show imported rooms
		String mcList = "";
		if (meetingCentres != null) {
			for (MeetingCentre meetingCentre : meetingCentres) {
				mcList += "  " + meetingCentre.getCode() + "\t" + meetingCentre.getName() + "\n";
			}

			// show imported reservations

			System.out.println("\n**************************************************");
			System.out.println("Currently existing meeting centre codes are: \n" + mcList );
			System.out.println("**************************************************\n");

			if (showAllReservations() != null) {
				System.out.println("\n**************************************************");
				System.out.println("Currently existing reservations overview:");
				System.out.println(showAllReservations());
				System.out.println("**************************************************\n");
			}

		}
	}

	public String showAllReservations() {
		String reservationDetails = "";
		if (meetingCentres != null) {
			for (MeetingCentre meetingCentre : meetingCentres) {
				if (meetingCentre.getMeetingRooms() != null) {
					for (MeetingRoom meetingRoom : meetingCentre.getMeetingRooms()) {
						if (!meetingRoom.getAllReservationDatesAndCounts().isEmpty()) {
							reservationDetails = (reservationDetails + "  " + meetingCentre.getName() + "("
									+ meetingRoom.getName() + ") \t :: " + meetingRoom.getAllReservationDatesAndCounts()
									+ "\n");
						}
					}
				}
			}

		}
		return reservationDetails;

	}

	/**
	 * Method to list all meeting centres to user and give him some options what
	 * to do next.
	 */
	public void listAllMeetingCentres() {
		logger.debug("#listAllMeetingCentres entered ", "OL");

		List<String> choices = new ArrayList<String>();
		choices.add("Show Details of Meeting Centre with code:");
		choices.add("Edit Meeting Centre with code:");
		choices.add("Delete Meeting Centre with code:");
		choices.add("Go Back to Home");

		loop: while (true) {
			String mcList = "";
			// handle empty list - don't show options
			if (meetingCentres.isEmpty()) {
				System.out.println("\n*************************************************");
				System.out.println(
						"There are no meeting centres defined. Please create new one or import from external repository.\n");
				System.out.println("*************************************************\n");
				return;
			}
			for (MeetingCentre meetingCentre : meetingCentres) {
				mcList += "  " + meetingCentre.getCode() + "\t" + meetingCentre.getName() + "\n";
			}

			// show menu for existing listed MCs
			System.out.println("\n*************************************************");
			System.out.println("Currently existing meeting centre codes are: \n" + mcList + "\n");
			Choices.showChoices("Select an option on one of the meeting centres:", choices);
			String chosenOption = Choices
					.getInput("Choose option (including meeting center code after '-', example 1-EBC-MC_C7): ");

			System.out.println("chosen:" + chosenOption);
			int option = 0;
			String code = "";
			try {
				option = chosenOption.contains("-") ? Integer.parseInt(chosenOption.substring(0, 1))
						: Integer.parseInt(chosenOption);
				code = chosenOption.contains("-") ? chosenOption.substring(2, chosenOption.length()) : "";

				// break option
				if (option == 4) {
					System.out.println("\n*************************************************");
					System.out.println("User selected option, to return to main menu.");
					System.out.println("*************************************************\n");
					return;
				}

				// check for empty-ness of 2nd param
				if ((code.isEmpty() )) {
					throw new Exception();
				}

			} catch (Exception e) {
				System.out.println("\n*************************************************");
				System.out.println(
						"  *Error in the input string. should be in format [number]-[meeting centre code]. And received string was: "
								+ chosenOption);
				System.out.println("   please try again");
				System.out.println("*************************************************\n");
				continue loop;
			}

			if (mcList.contains(code)) {
				logger.debug("listAllMeetingCentres - given code: " + code + " exist in list.", "OL");
			} else {
				System.out.println("\n*************************************************");
				System.out
						.println("  *ERROR. Given meeting center code doesn't exist in list. Chosen code was: " + code);
				System.out.println("  please try again.");
				System.out.println("*************************************************\n");
				continue loop;
			}

			switch (option) {
			case 1:
				logger.debug("showMeeting option called", "OL");
				showMeetingCentreDetails(code);
				break;
			case 2:
				logger.debug("editMeetingCentre option called", "OL");
				editMeetingCentre(code);
				break;
			case 3:
				logger.debug("deleteMeetingCentre option called", "OL");
				deleteMeetingCentre(code);
				break;
			case 4:
				logger.debug("return back option called", "OL");
				return;
			default:
				System.out.println("Please chose valid option (value from 1 to 4):");
			}
		}

	}

	/**
	 * Method to add a new meeting centre.
	 */
	public void addMeeMeetingCentre() {
		logger.debug("#addMeeMeetingCentre entered ", "OL");
		System.out.println("\nAdding new meeting centre...");
		MeetingCentre curMC = new MeetingCentre();

		// Name [2..100]
		String mcName = "";
		while (true) {
			mcName = Choices.getInput("Enter Name of Meeting Centre: ");
			if ((mcName.length() >= 2) && (mcName.length() <= 100) && (mcName.contains(",") == false)) {
				curMC.setName(mcName);
				break;
			} else {
				System.out.println(
						" *User entry validation failed: please type a string with size between 2..100 (commas not allowed)");
			}
		}

		// MC code, unique, [5..50], a..Z, .:_
		String mcCode = "";
		loop: while (true) {
			mcCode = Choices.getInput("Enter Code of MeetingCentre: ");
			if (mcCode.matches("^[\\w._:-]{5,50}$")) {
				logger.debug("got good code: " + mcCode, "OL");
				// check uniqueness
				for (MeetingCentre meetingCentre : meetingCentres) {
					if (meetingCentre.getCode().equals(mcCode)) {
						System.out.println(" *User entry validation failed: The given meeting centre <" + mcCode
								+ "> code already existed in repository. code has to be unique. Please try again");
						continue loop;
					}
				}
				// passed both checks, insert to object
				curMC.setCode(mcCode);
				break loop;
			} else {
				System.out.println(
						" *User entry validation failed: please type a string with size between 5..50, with characters a..Z and/or special characters: .:_ (numbers and dash are supported as well)");
				continue loop;
			}
		}

		// description
		String mcDescription = "";
		curMC.setDescription(mcDescription);
		while (true) {
			mcDescription = Choices.getInput("Enter Description of Meeting Centre: ");
			if ((mcDescription.length() >= 10) && (mcDescription.length() <= 300)
					&& (mcDescription.contains(",") == false)) {
				curMC.setDescription(mcDescription);
				break;
			} else {
				System.out.println(
						" *User entry validation failed: please type a string with size between 10..300 (commas not allowed)");
			}
		}

		// handle if it's first meeting Centre - initialize
		if (meetingCentres == null) {
			logger.debug("the array list is empty", "OL");
			meetingCentres = new ArrayList<>();
		}

		// add the new MC to the list
		meetingCentres.add(curMC);
		System.out.println("Added new Meeting Centre: " + mcName);

		// meeting rooms handling
		List<String> choices = new ArrayList<String>();
		choices.add("Add a meetingroom to meeting centre " + mcName);
		choices.add("Go Back to main menu");

		loop: while (true) {
			// Choices.showChoices("Select an option on one of the meeting
			// centres:", choices);
			int chosenOption = Choices.getChoice("Select an option: ", choices);
			switch (chosenOption) {
			case 1:
				logger.debug("  Chosen 1 - adding room", "OL");
				curMC.addMC(addMeeMeetingRoom(curMC));
				continue loop;
			case 2:
				logger.debug("  Chosen 2 - return home", "OL");
				break loop;
			default:
				System.out.println("User specified unexpected option. Please choose 1 or 2.");
				continue;
			}
		}
	}

	/*
	 * addMeeMeetingRoom
	 */
	public MeetingRoom addMeeMeetingRoom(MeetingCentre meetingCentre) {
		logger.debug("#addMeeMeetingRoom entered ", "OL");
		MeetingRoom curMR = new MeetingRoom();

		// MR Name
		String mrName = "";
		while (true) {
			mrName = Choices.getInput("Enter Name of Meeting Room: ");
			if ((mrName.length() >= 2) && (mrName.length() <= 100) && (mrName.contains(",") == false)) {
				curMR.setName(mrName);
				break;
			} else {
				System.out.println(
						" *User entry validation failed: please type a string with size between 2..100 (commas not allowed)");
			}
		}

		// MR code, unique, [5..50], a..Z, .:_ //uniqueness only in boundaries
		// of the given meeting centre
		String mrCode = "";
		loop: while (true) {
			mrCode = Choices.getInput("Enter Code of Meeting Room: ");
			if (mrCode.matches("^[\\w._:-]{5,50}$")) {
				logger.debug("got good code: " + mrCode, "OL");
				// check uniqueness
				if (meetingCentre.getMeetingRooms() != null) {
					for (MeetingRoom meetingRoom : meetingCentre.getMeetingRooms()) {
						if (meetingRoom.getCode().equals(mrCode)) {
							System.out.println(" *User entry validation failed: The given meeting room <" + mrCode
									+ "> code already existed in repository for current Meeting Centre. Code has to be unique. Please try again");
							continue loop;
						}
					}
				}
				// passed both checks, insert to object
				curMR.setCode(mrCode);
				break;
			} else {
				System.out.println(
						" *User entry validation failed: please type a string with size between 5..50, with characters a..Z and/or special characters: .:_ (numbers and dash are supported as well)");
				continue;
			}
		}

		// MR description validaiton and input
		String mrDescription = "";
		while (true) {
			mrDescription = Choices.getInput("Enter Description of Meeting Room: ");
			if ((mrDescription.length() >= 10) && (mrDescription.length() <= 300)
					&& (mrDescription.contains(",") == false)) {
				curMR.setDescription(mrDescription);
				break;
			} else {
				System.out.println(
						" *User entry validation failed: please type a string with size between 10..300 (commas not allowed)");
			}
		}

		// MR Capacity user entry and validation
		String mrCapacityString = "";
		int mrCapacity;
		// curMR.setCapacity(Integer.parseInt(capacityFilter));
		while (true) {
			mrCapacityString = Choices.getInput("Enter Capacity of Meeting Room: ");
			try {
				mrCapacity = Integer.parseInt(mrCapacityString);
				if ((mrCapacity >= 1) && (mrCapacity <= 100)) {
					curMR.setCapacity(mrCapacity);
					break;
				} else {
					System.out.println(
							" *User entry validation failed (wrong number range): please type a number between 1..100");

				}
			} catch (Exception e) {
				System.out
						.println(" *User entry validation failed (not a number): please type a number between 1..100");
				continue;
			}
		}

		// MR video capable?
		String mrHasVideo = "";
		loop: while (true) {
			mrHasVideo = Choices.getInput("Enter if meeting room is video conference capable (Y/N): ");
			switch (mrHasVideo) {
			case "Y":
				curMR.setHasVideoConference(true);
				break loop;
			case "N":
				curMR.setHasVideoConference(false);
				break loop;
			default:
				System.out.println(" *User entry validation failed: please type Y or N");
				continue;
			}
		}

		curMR.setMeetingCentre(meetingCentre);
		logger.debug("#addMeeMeetingRoom - going to return" + curMR, "OL");
		return curMR;
	}

	/**
	 * Method to show meeting centre details by id.
	 */
	public void showMeetingCentreDetails(String input) {
		logger.debug("#showMeetingCentreDetails entered ", "OL");
		logger.debug("input param: " + input, "OL");

		boolean foundMC = false;
		for (MeetingCentre meetingCentre : meetingCentres) {
			if (meetingCentre.getCode().equals(input)) {
				logger.debug("found one MC! " + meetingCentre, "OL");
				foundMC = true;

				System.out.println("\nMEETING CENTRE:\n---------------");
				System.out.println("\tName: " + meetingCentre.getName());
				System.out.println("\tCode:" + meetingCentre.getCode());
				System.out.println("\tDescription: " + meetingCentre.getDescription());

				List<MeetingRoom> curMeetingRooms = meetingCentre.getMeetingRooms();
				System.out.println("\nMEETING ROOMS:\n-------------");
				if (curMeetingRooms != null) {
					for (MeetingRoom meetingRoom : curMeetingRooms) {
						System.out.println("\tRoom name: " + meetingRoom.getName());
						System.out.println("\t\tID:" + meetingRoom.getCode());
						System.out.println("\t\tDescription: " + meetingRoom.getDescription());
						System.out.println("\t\tCapacity: " + meetingRoom.getCapacity());
						if (meetingRoom.isHasVideoConference()) {
							System.out.println("\t\tProjector: YES \n");
						} else {
							System.out.println("\t\tProjector: NO \n");
						}
					}
				} else {
					System.out.println("\t(no meeting rooms are defined in this meeting centre)");
				}

			}
		}

		// if not found
		if (foundMC == false) {
			System.out.println("\n*************************************************");
			System.out.println("  Error - chosen meeting centre " + input + " was not found.");
			System.out.println("*************************************************\n");

		}

	}

	/**
	 * Method to edit meeting centre data by id.
	 */
	public void editMeetingCentre(String input) {
		logger.debug("#editMeetingCentre entered ", "OL");
		int meetingCentreFound = 0;
		MeetingCentre mcToEdit = null;
		for (Iterator<MeetingCentre> iterator = meetingCentres.iterator(); iterator.hasNext();) {
			MeetingCentre meetingCentre = iterator.next();

			if (meetingCentre.getCode().equals(input)) {
				String mcToEditName = meetingCentre.getName();
				logger.debug("Found MC to edit: " + mcToEditName, "OL");
				meetingCentreFound += 1;
				mcToEdit = meetingCentre;
			}
		}

		if (meetingCentreFound != 1) {
			System.out.println("\n *user input error: desired Meeting Centre " + input
					+ " was not found in repository. \nReturn to the main menu");
			return;
		}

		System.out.println("\n*************************************************");
		System.out.println("Set the new values for <" + mcToEdit.getName() + ">, or press enter to skip:");
		logger.debug("MC to edit" + mcToEdit, "OL");

		// Name [2..100]
		String mcName = mcToEdit.getName();
		while (true) {
			String mcNameNew = Choices.getInput("Enter NEW Name of Meeting Centre (" + mcName + "): ");
			// keep original
			if (mcNameNew.isEmpty()) {
				break;
			}
			// validate new
			if ((mcNameNew.length() >= 2) && (mcNameNew.length() <= 100) && (mcNameNew.contains(",") == false)) {
				mcToEdit.setName(mcNameNew);
				break;
			} else {
				System.out.println(
						" *User entry validation failed: please type a string with size between 2..100 (commas not allowed), or press enter to skip.");
			}
		}

		// MC code, unique, [5..50], a..Z, .:_
		String mcCode = mcToEdit.getCode();
		loop: while (true) {
			String mcCodeNew = Choices.getInput("Enter NEW Code of Meeting Centre (" + mcCode + "): ");
			// keep original if enter, or if the same value
			if ((mcCodeNew.isEmpty() ) || mcCodeNew.equals(mcCode)) {
				break;
			}
			// validate new
			if (mcCodeNew.matches("^[\\w._:-]{5,50}$")) {
				logger.debug("got good code: " + mcCode, "OL");
				// check uniqueness
				for (MeetingCentre meetingCentre : meetingCentres) {
					if (meetingCentre.getCode().equals(mcCodeNew)) {
						System.out.println(" *User entry validation failed: The given meeting centre <" + mcCodeNew
								+ "> code already existed in repository. code has to be unique. Please try again");
						continue loop;
					}
				}
				// passed both checks, insert to object
				mcToEdit.setCode(mcCodeNew);
				break;
			} else {
				System.out.println(
						" *User entry validation failed: please type a string with size between 5..50, with characters a..Z and/or special characters: .:_ (numbers and dash are supported as well), or press enter to skip.");
				continue loop;
			}
		}

		// description
		String mcDescription = mcToEdit.getDescription();
		while (true) {
			String mcDescriptionNew = Choices
					.getInput("Enter NEW Description of Meeting Centre (" + mcDescription + "): ");
			// keep original
			if (mcDescriptionNew.isEmpty()) {
				break;
			}
			// validate new
			if ((mcDescriptionNew.length() >= 10) && (mcDescriptionNew.length() <= 300)
					&& (mcDescriptionNew.contains(",") == false)) {
				mcToEdit.setDescription(mcDescriptionNew);
				break;
			} else {
				System.out.println(
						" *User entry validation failed: please type a string with size between 10..300 (commas not allowed), or press enter to skip.");
			}
		}

		// update meeting rooms of the given meeting
		// option to add, delete, update - of the current meetingCenter
		updateMeetingRoomsOuter(mcToEdit);

	}

	/*
	 * updateMeetingRoomsOuter - list over meeting rooms and gives options to
	 * handle them
	 */
	public void updateMeetingRoomsOuter(MeetingCentre meetingCentre) {
		List<String> choices;
		loop: while (true) {

			logger.debug("-loop begin", "OL");
			if ((meetingCentre.getMeetingRooms() == null) || (meetingCentre.getMeetingRooms().isEmpty() )) {
				// special menu, if no rooms are present on the meeting center
				logger.debug("meetingRooms are empty, show menu with updates/deletes", "OL");
				choices = new ArrayList<String>();
				choices.add("Add a meeting room to meeting centre " + meetingCentre.getName());
				choices.add("Go Back to main menu");

				loopEmptyMR: while (true) {
					logger.debug("-loopEmptyMR begin", "OL");

					Choices.showChoices("\nSelect an option on one of the meeting centres:", choices);
					int chosenOption = Choices.getChoice("Select an option: ", choices);
					switch (chosenOption) {
					case 1:
						logger.debug("  Chosen 1 - adding room", "OL");
						meetingCentre.addMC(addMeeMeetingRoom(meetingCentre));
						logger.debug("continue loop", "OL");

						continue loop;
					case 2:
						logger.debug("  Chosen 2 - return home", "OL");
						break loop;
					default:
						System.out.println("User specified unexpected option. Please choose 1 or 2.");
						continue loopEmptyMR;
					}
				}
			}

			// different menu, if some rooms are present
			if (meetingCentre.getMeetingRooms().isEmpty() == false) {
				logger.debug("meetingRooms are not empty (" + meetingCentre.getMeetingRooms()
						+ "), show menu with updates/deletes", "OL");
				// at least one exist => list rooms
				System.out.println("\nList of Current Meeting rooms of Meeting centre: " + meetingCentre.getName());
				for (MeetingRoom meetingRoom : meetingCentre.getMeetingRooms()) {
					System.out.println("  " + meetingRoom.getCode() + "\t\t" + meetingRoom.getName());
				}

				// show options also for existing rooms
				choices = new ArrayList<String>();
				choices.add("Delete a Meeting Room with code:");
				choices.add("Update a Meeting Room with code:");
				choices.add("Add a new Meeting Room (no code):");
				choices.add("Return to the main menu");

				// ask user for his wish
				Choices.showChoices("\nSelect an option on one of the meeting centres:", choices);
				String chosenOption = Choices
						.getInput("Choose option (including meeting room code after '-', example 1-EBC-C7-MR:1_1): ");

				System.out.println("chosen:" + chosenOption);
				int option = 0;
				String code = "";
				try {
					option = chosenOption.contains("-") ? Integer.parseInt(chosenOption.substring(0, 1))
							: Integer.parseInt(chosenOption);
					code = chosenOption.contains("-") ? chosenOption.substring(2, chosenOption.length()) : "";

					// return
					if (option == 4) {
						System.out.println("\n*************************************************");
						System.out.println("User selected option, to return to main menu.");
						System.out.println("*************************************************\n");
						return;
					}

					// check for emptyness of 2nd param
					if (((code.isEmpty()) && (option < 3)) || (option > 4) || (option < 1)) {
						throw new Exception();
					}

				} catch (Exception e) {
					System.out.println("\n*************************************************");
					System.out.println(
							"  *Error in the input string. should be either value 3 or 4, or should be in format [number 1..2]-[meeting room code]. "
									+ "   And received string was: " + chosenOption);
					System.out.println("   please try again");
					System.out.println("*************************************************\n");
					continue loop;
				}

				// at this point, have activity and meeting room => call real
				// action
				// for delete/modify, find if element exist
				MeetingRoom selectedMR = null;
				if (meetingCentre.getMeetingRooms() != null) {
					for (MeetingRoom meetingRoom : meetingCentre.getMeetingRooms()) {
						if (meetingRoom.getCode().equals(code)) {
							logger.debug("Meeting Room - 1..2 found object: " + meetingRoom, "OL");
							selectedMR = meetingRoom;
							break;
						}
					}
					if ((selectedMR == null) && (option >= 1) && (option <= 2)) {
						System.out.println("\n*************************************************");
						System.out.println("  *Error in the input string. non-existing Meeting Room code <" + code
								+ "> selected with option: " + option);
						System.out.println("   please try again");
						System.out.println("*************************************************\n");
						continue loop;
					}

					switch (option) {
					case 1:
						System.out.println("\nDeleting Meeting Room: " + code + "...");
						deleteMeetingRoom(selectedMR);

						break;
					case 2:
						System.out.println("\nUpdating Meeting Room: " + code + "...");
						updateMeetingRoom(selectedMR);
						break;
					case 3:
						System.out.println("\nAdding one Meeting Room:");
						meetingCentre.addMC(addMeeMeetingRoom(meetingCentre));
						break;
					case 4:
						System.out.println("\nLeaving the Meeting Room handling...");
						break loop;
					default:
						System.out.println("\n *User error detected. only options 1..4 are ONLY 1..4, try again");
						continue loop;
					}
				}
			}
		}
	}

	/*
	 * delete Meeting room
	 * 
	 */
	public void deleteMeetingRoom(MeetingRoom meetingRoom) {
		// get name and log
		String mrToDelete = meetingRoom.getName();
		logger.debug("Found MR to delete: " + mrToDelete, "OL");

		// ask for confirm
		String chosenOption = Choices
				.getInput("Are you sure, you want to delete MR " + mrToDelete + "? To confirm, press (Y):");
		if (chosenOption.equalsIgnoreCase("Y")) {
			System.out.println("User confirmed to delete the object");

			// 1. delete from meetingCentre.meetingRooms (create new list,
			// without the deleted one
			MeetingCentre meetingCentre = meetingRoom.getMeetingCentre();
			int mcRoomsCountBefore = meetingCentre.getMeetingRooms().size();
			List<MeetingRoom> newMeetingRooms = meetingCentre.getMeetingRooms();
			newMeetingRooms.remove(meetingRoom);
			int mcRoomsCountAfter = meetingCentre.getMeetingRooms().size();

			// validate count decreased
			if (mcRoomsCountAfter == mcRoomsCountBefore) {
				System.out.println(" *error appeared during deleting from the list of meetingRooms ");
			} else {
				System.out.println(" room " + mrToDelete + "was deleted from the MeetingCentre list");

				// 2. delete item itself
				meetingRoom = null;
			}
		} else {
			System.out.println("User didn't confirm to delete the object");

		}
	}

	/*
	 * update Meeting rooms of a given meeting centre
	 * 
	 */
	public void updateMeetingRoom(MeetingRoom meetingRoom) {
		logger.debug("#entered updateMeetingRoom", "OL");

		// MR Name
		String mrName = meetingRoom.getName();
		while (true) {
			String mrNameNew = Choices.getInput("Enter NEW Name of Meeting Room (" + mrName + "): ");
			// no change
			if ((mrNameNew.isEmpty() ) || (mrName == mrNameNew)) {
				break;
			}
			// validation of new name
			if ((mrNameNew.length() >= 2) && (mrNameNew.length() <= 100) && (mrNameNew.contains(",") == false)) {
				meetingRoom.setName(mrNameNew);
				break;
			} else {
				System.out.println(
						" *User entry validation failed: please type a string with size between 2..100 (commas not allowed). Or hit enter to keep original value");
			}
		}

		// MR code, unique, [5..50], a..Z, .:_ //uniqueness only in boundaries
		// of the given meeting centre
		String mrCode = meetingRoom.getCode();
		loop: while (true) {
			String mrCodeNew = Choices.getInput("Enter NEW Code of Meeting Room (" + mrCode + "): ");
			// no change
			if ((mrCodeNew.isEmpty() ) || (mrCodeNew.equals(mrCode))) {
				break;
			}
			// validation of new string
			if (mrCodeNew.matches("^[\\w._:-]{5,50}$")) {
				logger.debug("got good code: " + mrCodeNew, "OL");

				// check uniqueness
				MeetingCentre meetingCentre = meetingRoom.getMeetingCentre();
				for (MeetingRoom curMeetingRoom : meetingCentre.getMeetingRooms()) {
					if (curMeetingRoom.getCode().equals(mrCodeNew)) {
						System.out.println(" *User entry validation failed: The given meeting room <" + mrCodeNew
								+ "> code already existed in repository for current Meeting Centre. Code has to be unique. Please try again");
						continue loop;

					}
				}
				// passed both checks, insert to object
				meetingRoom.setCode(mrCodeNew);
				break;
			} else {
				System.out.println(
						" *User entry validation failed: please type a string with size between 5..50, with characters a..Z and/or special characters: .:_ (numbers and dash are supported as well)");
				continue;
			}
		}

		// MR description validaiton and input
		String mrDescription = meetingRoom.getDescription();
		loop: while (true) {
			String mrDescriptionNew = Choices
					.getInput("Enter NEW Description of Meeting Room (" + mrDescription + "): ");
			// no change
			if ((mrDescriptionNew.isEmpty()) || (mrDescriptionNew == mrDescription)) {
				break;
			}
			// validate length
			if ((mrDescriptionNew.length() >= 10) && (mrDescriptionNew.length() <= 300)
					&& (mrDescriptionNew.contains(",") == false)) {
				meetingRoom.setDescription(mrDescriptionNew);
				break;
			} else {
				System.out.println(
						" *User entry validation failed: please type a string with size between 10..300 (commas not allowed). "
								+ " please try again");
				continue loop;
			}
		}

		// MR Capacity user entry and validation
		String mrCapacityStringNew = "";
		int mrCapacity = meetingRoom.getCapacity();
		while (true) {
			mrCapacityStringNew = Choices.getInput("Enter NEW Capacity of Meeting Room (" + mrCapacity + "): ");
			// no change
			if (mrCapacityStringNew.isEmpty()) {
				break;
			}
			// validate changed value
			try {
				int mrCapacityNew = Integer.parseInt(mrCapacityStringNew);
				if ((mrCapacityNew >= 1) && (mrCapacityNew <= 100)) {
					meetingRoom.setCapacity(mrCapacityNew);
					break;
				} else {
					System.out.println(
							" *User entry validation failed (wrong number range): please type a number between 1..100");
				}
			} catch (Exception e) {
				System.out
						.println(" *User entry validation failed (not a number): please type a number between 1..100");
				continue;
			}
		}

		// MR video capable?
		boolean mrHasVideo = meetingRoom.isHasVideoConference();
		String mrHasVideoString;
		loop: while (true) {
			// conversion Y/N from boolean
			if (mrHasVideo) {
				mrHasVideoString = "Y";
			} else {
				mrHasVideoString = "N";
			}
			String mrHasVideoStringNew = Choices
					.getInput("Set, if the room is video capable (" + mrHasVideoString + "): ");

			// if empty
			if (mrHasVideoStringNew.isEmpty()) {
				break;
			}

			// check and decode values
			switch (mrHasVideoStringNew) {
			case "Y":
				meetingRoom.setHasVideoConference(true);
				break loop;
			case "N":
				meetingRoom.setHasVideoConference(false);
				break loop;
			default:
				System.out.println(" *User entry validation failed: please type Y or N");
				continue loop;
			}
		}
	}

	/**
	 * Method to delete by id
	 */
	public void deleteMeetingCentre(String input) {
		logger.debug("#deleteMeetingCentre entered ", "OL");

		int meetingCentreDeleted = 0;

		for (Iterator<MeetingCentre> iterator = meetingCentres.iterator(); iterator.hasNext();) {
			MeetingCentre meetingCentre = iterator.next();

			if (meetingCentre.getCode().equals(input)) {
				String mcToDelete = meetingCentre.getName();
				logger.debug("Found MC to delete: " + mcToDelete, "OL");
				// ask
				String chosenOption = Choices.getInput(
						"Are you sure, you want to delete MC " + mcToDelete + " with its meeting rooms? (Y/N)");
				System.out.println("chosen:" + chosenOption);
				if (chosenOption.equalsIgnoreCase("Y")) {
					// actual delete after confirmation
					if (meetingCentre.getMeetingRooms() != null) {
						for (MeetingRoom meetingRoom : meetingCentre.getMeetingRooms()) {
							logger.debug("  setting the object of meeting room: " + meetingRoom + " to null", "OL");
							meetingRoom = null;
						}
						meetingCentre.setMeetingRooms(null);
					}
					int mcBeforeDel = meetingCentres.size();
					iterator.remove();
					int mcAfterDel = meetingCentres.size();
					meetingCentre = null;
					if (mcBeforeDel != mcAfterDel) {
						meetingCentreDeleted += 1;
						logger.debug("deleting MC succeeded. size before deleting was: <" + mcBeforeDel
								+ "> and after deleting was: <" + mcAfterDel + ">", "OL");
					} else {
						System.out.println(
								" UNEXPECTED ERROR when deleting MC. size of meetingCentres before and after deleting is the same: "
										+ mcBeforeDel);
					}

				} else {
					System.out.println("  user chose <" + chosenOption
							+ ">. User didn't confirm deleting of the meeting centre, so it was not deleted.");
					return;
				}

			}

		}

		if (meetingCentreDeleted == 0) {
			System.out.println(
					"  Error with the request for deleting meeting centre. Requested MC: " + input + " was not found.");
		}

		logger.debug("#deleteMeetingCentre entered: " + input, "OL");
	}

	/**
	 * Method to get all data to save in string format
	 * 
	 * @return
	 */
	public String toSaveString() {
		logger.debug("#toSaveString entered ", "OL");
		String outputMC = "MEETING_CENTRES,,,,,\n";
		String outputMR = "MEETING_ROOMS,,,,,\n";
		// Meeting centres
		for (MeetingCentre meetingCentre : meetingCentres) {
			outputMC = outputMC + meetingCentre.getName() + "," + meetingCentre.getCode() + ","
					+ meetingCentre.getDescription() + ",,,\n";
			// Meeting rooms
			if (meetingCentre.getMeetingRooms() != null) {
				for (MeetingRoom meetingRoom : meetingCentre.getMeetingRooms()) {
					if (meetingRoom != null) {
						outputMR = outputMR + meetingRoom.getName() + "," + meetingRoom.getCode() + ","
								+ meetingRoom.getDescription() + "," + meetingRoom.getCapacity() + ",";
						if (meetingRoom.isHasVideoConference()) { // true/false=>YES/NO
							outputMR += "YES,";
						} else {
							outputMR += "NO,";
						}

						outputMR = outputMR + meetingRoom.getMeetingCentre().getCode() + "\n";
					}

				}
			}
		}

		logger.debug("\n" + outputMC + outputMR, "OL");
		return outputMC + outputMR;
	}

}
