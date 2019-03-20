package cz.unicorncollege.bt.utils;

import java.util.ArrayList;
import java.util.List;

import cz.unicorncollege.bt.model.MeetingCentre;

public class FileParser {
	
	/**
	 * Method to import data from the chosen file.
	 */
	public static List<MeetingCentre> importData() {
		
		String locationFilter = Choices.getInput("Enter path of imported file: ");
		
		List<MeetingCentre> allMeetingCentres = new ArrayList<>();

		//TODO: Nacist data z importovaneho souboru 
		System.out.println();
		
		System.out.println("**************************************************");
		System.out.println("Data was imported. " + allMeetingCentres.size() + " objects of MeetingCentres was loaded");
		System.out.println("**************************************************");
		
		System.out.println();
		
		return null;
	}
	
	/**
	 * Method to save the data to file.
	 */
	public static void saveData(String output) {
		//TODO: ulozeni dat do souboru
		
		System.out.println();
		
		System.out.println("**************************************************");
		System.out.println("Data was saved correctly.");
		System.out.println("**************************************************");
		
		System.out.println();
	}
	
	/**
	 * Method to load the data from file.
	 * @return
	 */
	public static List<MeetingCentre> loadDataFromFile() {
		//TODO: nacist data ze souboru
				
		System.out.println();
		
		System.out.println("**************************************************");
		System.out.println("Data was loaded correctly.");
		System.out.println("**************************************************");
		
		System.out.println();
		
		return null;
	}
}
