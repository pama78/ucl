package cz.unicorncollege.controller;

import java.util.ArrayList;
import java.util.List;

import cz.unicorncollege.bt.model.MeetingCentre;
import cz.unicorncollege.bt.utils.Choices;
import cz.unicorncollege.bt.utils.FileParser;

public class MeetingController {
	private List<MeetingCentre> meetingCentres;
	
	/**
	 * Method to initialize data from the saved datafile.
	 */
	public void init() {
		
		//TODO: nacist z ulozeneho souboru vsechna meeting centra a vypsat je na obrazovku
		meetingCentres = FileParser.loadDataFromFile();
	}
	
	/**
	 * Method to list all meeting centres to user and give him some options what to do next.
	 */
	public void listAllMeetingCentres() {
		
		//TODO: vypsat data o meeting centrech
		
		List<String> choices = new ArrayList<String>();
		choices.add("Show Details of Meeting Centre with code:");
		choices.add("Edit Meeting Centre with code:");
		choices.add("Delete Meeting Centre with code:");
		choices.add("Go Back to Home");
		
		String chosenOption = Choices.getInput("Choose option (including code after '-', example 1-M01): ");
		int option = chosenOption.contains("-") ? Integer.parseInt(chosenOption.substring(0, 1)) : Integer.parseInt(chosenOption);
		String code = chosenOption.contains("-") ? chosenOption.substring(2, chosenOption.length()) : "";
		
		while (true) {
			switch (option) {
			case 1:
				showMeetingCentreDetails(code);
				break;
			case 2:
				editMeetingCentre(code);
				break;
			case 3:
				deleteMeetingCentre(code);
				break;
			case 5:
				return;
			}
		}
		
	}
	
	/**
	 * Method to add a new meeting centre.
	 */
	public void addMeeMeetingCentre() {
		String locationFilter = Choices.getInput("Enter name of MeetingCentre: ");
		//TODO: doplnit zadavani vsech dalsich hodnot + naplneni do noveho objektu
	}
	
	/**
	 * Method to show meeting centre details by id.
	 */
	public void showMeetingCentreDetails(String input) {
		//TODO: doplnit nacteni prislusneho meeting centra a vypsani jeho zakladnih hodnot
		
		List<String> choices = new ArrayList<String>();
		choices.add("Show meeting rooms");
		choices.add("Add meeting room");
		choices.add("Edit detials");
		choices.add("Go Back");
		
		//TODO: doplnit metody pro obsluhu meeting rooms atd..
	}
	
	/**
	 * Method to edit meeting centre data by id.
	 */
	public void editMeetingCentre(String input) {
		String locationFilter = Choices.getInput("Enter new name of MeetingCentre: ");
		//TODO: doplneni editace, bud vsech polozek s moznosti preskoceni nebo vyber jednotlive polozky
	}
	
	/**
	 * Method to delete by id
	 */
	public void deleteMeetingCentre(String input) {
		String locationFilter = Choices.getInput("Enter name of MeetingCentre: ");
		//TODO: doplnit vymazani meeting centra a jeho mistnosti a vypsani potvrzeni o smazani
	}

	/**
	 * Method to get all data to save in string format
	 * @return
	 */
	public String toSaveString() {
		return null;
	}

	public List<MeetingCentre> getMeetingCentres() {
		return meetingCentres;
	}

	public void setMeetingCentres(List<MeetingCentre> meetingCentres) {
		this.meetingCentres = meetingCentres;
	}
}
