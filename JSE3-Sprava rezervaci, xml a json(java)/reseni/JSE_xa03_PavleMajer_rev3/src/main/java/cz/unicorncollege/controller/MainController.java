/* Name:     Ultimate reservation system
 * Purpose:  Reservations text base solution
 * Author:   Pavel Majer
 * Revisions:
 *          #rev3, 18/12, fixes related to repository filename detection 
 *          
 * NOTES
 * 
 * Additional details:
 *   Anotations solution of DU3 depreciated, this is for future reference
 *   import com.fasterxml.jackson.annotation.JsonInclude;
 *   import javax.xml.bind.annotation.XmlType;
 *   @JsonInclude(JsonInclude.Include.NON_NULL) 
 *   @JsonProperty("meetingCentre") 
 *   @XmlType -- xmltype annotations also depreciated - as the model is cyclic, they are complex to use
 *   jackson annotations - depreciated
 *   @JsonProperty("meetingRoom")  private String code;  //Du3
 *  
 *   export of objects to xml pomoci xtreme - as the model is cyclic, they are complex to use
 *    http://tomaszdziurko.pl/2013/04/xstream-xstreamely-easy-work-xml-data-java/
 *    //import javax.json.JsonObject - this didnt work for this type of excercise (cyclic references, complex to use) 
 *    http://jsonprettyprint.com/

*/

package cz.unicorncollege.controller;

import java.util.ArrayList;
import java.util.List;

import cz.unicorncollege.bt.utils.Choices;
import cz.unicorncollege.bt.utils.FileParser;
import java.io.File;




/**
 * Main controller class. Contains methods to communicate with user and methods
 * to work with files.
 *
 * @author UCL
 */
public class MainController {
	private MeetingController controll;
	private ReservationController controllReservation;
	public String path = MainController.class.getResource("MainController.class").getPath();
	public final File f = new File(MainController.class.getProtectionDomain().getCodeSource().getLocation().getPath());

	//
	// MeetingController.init();
	/**
	 * Constructor of main class.
	 */
	public MainController() {
		controll = new MeetingController();
		controll.init();
		controllReservation = new ReservationController(controll);

	}

	/**
	 * Main method, which runs the whole application.
	 *
	 * @param argv
	 *            String[]
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
		choices.add("Reservations");
		choices.add("Import Data(Meeting Rooms)");
		choices.add("Export Data(Reservations to JSON)");
		choices.add("Save and Exit");
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
				controllReservation.showReservationMenu();
				break;
			case 4:
				controll.setMeetingCentres(FileParser.importData());
				controll.listAllMeetingCentres();
				break;
			case 5:
				FileParser.exportDataToJSON(controll.getMeetingCentres());
				break;
			case 6:
				FileParser.saveData(controll.toSaveString());
				FileParser.saveReservationsToXml(controll.getMeetingCentres());
				return;
			case 7:
				System.out.println("\n *Exitting without saving data... \n");
				return;
			default:
				System.out.println("\nERROR in user input. please choose value between 1 and 7 \n" );
			}
		}
	}
}
