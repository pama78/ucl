package cz.unicorncollege.controller;

import java.util.ArrayList;
import java.util.List;

import cz.unicorncollege.bt.model.MeetingCentre;
import cz.unicorncollege.bt.utils.Choices;
import cz.unicorncollege.bt.utils.FileParser;

/**
 * Main controller class.
 * Contains methods to communicate with user and methods to work with files.
 *
 * @author UCL
 */
public class MainController {
	private MeetingController controll;
	
	/**
	 * Constructor of main class.
	 */
	public MainController() {
		controll = new MeetingController();
		controll.init();
	}

	
    /**
	 * Main method, which runs the whole application.
	 *
	 * @param argv String[]
	 */
	public static void main(String[] argv) {
		MainController instance = new MainController();
		instance.run();
	}

	/**
	 * Method which shows the main menu and end after user chooses Exit.
	 */
	private void run() {
		List<String> choices = new ArrayList<String>();
		choices.add("List all Meeting Centres");
		choices.add("Add new Meeting Centre");
		choices.add("Import Data");
		choices.add("Exit and Save");
		choices.add("Exit");

		while (true) {
			switch (Choices.getChoice("Select an option: ", choices)) {
			case 1:
				controll.listAllMeetingCentres();
				break;
			case 2:
				controll.addMeeMeetingCentre();
				break;
			case 3:
				controll.setMeetingCentres(FileParser.importData());
				controll.listAllMeetingCentres();
				break;
			case 4:
				FileParser.saveData(controll.toSaveString());
				return;
			case 5:
				return;
			}
		}
	}
}
