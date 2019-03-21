package cz.unicorncollege.bt.utils;



import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.stream.XMLOutputFactory;
import javax.xml.stream.XMLStreamException;
import javax.xml.stream.XMLStreamWriter;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import cz.unicorncollege.bt.model.MeetingCentre;
import cz.unicorncollege.bt.model.MeetingRoom;
import cz.unicorncollege.bt.model.Reservation;

public class FileParser {

	/**
	 * set static variables for storing links to repository files
	 */
	private static Logger logger = Logger.getInstance();
	private static final String DATE_SLASH_FMT = "dd/MM/yyyy";
	private static final String DATE_DOT_FMT = "dd.MM.yyyy";
	public static final String RESERVATIONS_FILE = "src/data/reservations.xml";
	public static final String MEETING_CENTRES_FILE = "src/data/meetingCentres.csv";

	/**
	 * Method import data from customer file (external)
	 */
	public static List<MeetingCentre> importData() {
		List<MeetingCentre> allMeetingCentres = new ArrayList<>();

		while (true) {
			String input = Choices.getInput("Enter path of imported file (or press enter to main menu): ").trim();
			if (input.isEmpty()) {
				System.out.println("\n************************************************");
				System.out
						.println("User didn't specify external file to import. returning to main menu witout import.");
				System.out.println("************************************************\n");
				break;
			}
			File inputFile = new File(input);
			if (inputFile.exists() && inputFile.isFile()) {
				allMeetingCentres = parseData(inputFile);
				System.out.println("\n************************************************");
				System.out.println("Data was loaded correctly.");
				break;
			} else {
				System.out.println("\n************************************************");
				System.out.println("External File: " + input
						+ " doesn't exist. Please try again or press enter to get to main menu.");
				System.out.println("************************************************\n");
			}
		}

		return allMeetingCentres;
	}

	/**
	 * Method to parse the data from file (either internal or external)
	 */
	public static List<MeetingCentre> parseData(File locationFilter) {
		logger.debug("#parseData entered: " + locationFilter, "OL");
		List<MeetingCentre> allMeetingCentres = new ArrayList<>();

		try (BufferedReader reader = new BufferedReader(
				new InputStreamReader(new FileInputStream(locationFilter), "UTF-8"))) {
			String line = null;
			String centreOrRoom = null;
			while ((line = reader.readLine()) != null) {
				String[] lineSplit = line.split("\\s*,\\s*");
				logger.debug("  #Processing row: " + line, "OL");
				String firstString = lineSplit[0];

				// differentiate between MC and MR
				if (firstString.contains("MEETING_CENTRES")) {
					logger.debug(" #meeting centres started", "OL");
					centreOrRoom = "C";
					continue;
				}

				if (firstString.contains("MEETING_ROOMS")) {
					logger.debug(" #meeting rooms started", "OL");
					centreOrRoom = "R";
					continue;
				}

				// handling MCs
				if (centreOrRoom == "C") {
					logger.debug("   -processing  centre: " + firstString, "OL");
					MeetingCentre curMC = new MeetingCentre();
					curMC.setName(firstString);
					curMC.setCode(lineSplit[1]);
					curMC.setDescription(lineSplit[2]);
					curMC.setMeetingRooms(null); // initialize
					allMeetingCentres.add(curMC);
				}

				// handling MRs
				if (centreOrRoom == "R") {
					logger.debug("   -processing  room: " + firstString, "OL");
					MeetingRoom curMR = new MeetingRoom();
					curMR.setName(firstString);
					curMR.setCode(lineSplit[1]);
					curMR.setDescription(lineSplit[2]);
					curMR.setCapacity(Integer.valueOf(lineSplit[3]));
					curMR.setHasVideoConference(lineSplit[4].equalsIgnoreCase("YES")); // if
																						// YES=>true

					// map MC-MR. assumption: one and always one MC exist for
					// each MR. validations skipped
					String curMCCode = lineSplit[5];
					for (MeetingCentre oneMC : allMeetingCentres) {
						// add reference from MR to MC
						if (curMCCode.equals(oneMC.getCode())) {
							logger.debug(
									"    found object for the named MC code. MC:" + curMCCode + " its obj id: " + oneMC,
									"OL");
							curMR.setMeetingCentre(oneMC);
							// adding cross reference from MC to MR
							logger.debug("    curMR - addMC-curMR:" + curMR, "OL");
							oneMC.addMC(curMR);
						}
					}
				}
			}

			// print result, if no error
			System.out.println();
			System.out.println("**************************************************");
			if (allMeetingCentres.size() > 0) {
				System.out.println(
						"< " + allMeetingCentres.size() + " > MeetingCentres imported to the system from repository ");
			} else {
				System.out.println("No data was imported. " + allMeetingCentres.size()
						+ " objects of MeetingCentres was loaded from internal repository");
			}

			System.out.println("**************************************************");
			System.out.println();

		} catch (IOException e) {
			System.out.println("/n**************************************************");
			System.out.println("No data was imported. Objects of MeetingCentre internal repository was loaded");
			System.out.println("**************************************************/n");
		}

		return allMeetingCentres;
	}

	/**
	 * Method to save the data to file.
	 */
	public static void saveData(String output) {
		logger.debug("#entered saveData", "OL");
		String tryAgain = "";
		while (true) {
			try {
				// protection
			//	if (!REPOSITORY.getParentFile().exists()) {
			//		REPOSITORY.getParentFile().mkdirs();
			//		System.out.println("created directory " + REPOSITORY);
			//	}

				BufferedWriter out = new BufferedWriter(
						new OutputStreamWriter(new FileOutputStream(MEETING_CENTRES_FILE), "UTF-8"));
				
				out.write(output);
				out.close();
				System.out.println();
				System.out.println("**************************************************");
				System.out.println("Meeting centres/rooms repository was saved correctly to " + MEETING_CENTRES_FILE);
				System.out.println("**************************************************");
				System.out.println();
				break;
			} catch (IOException ex) {
				//ex.printStackTrace();
				System.out.println("**************************************************");
				System.out.println(
						"ERROR: Meeting centres/rooms repository not saved correctly to " +MEETING_CENTRES_FILE + ". Please check the issue (free disk space, existing directory...), and try again later.");
				System.out.println("**************************************************");

				tryAgain = Choices.getInput("Error in saving the repository to: " + MEETING_CENTRES_FILE
						+ ". Exit without saving? (Y=Yes, anything else to retry saving): ");
				switch (tryAgain) {
				case "Y":
					System.out.println("Meeting centers application finished without saving to the repository.");
					return;
				default:
					continue;
				}

			}
		}
	}

	/**
	 * Method to load the data from file. (meeting centres)
	 * 
	 * @return
	 */
	public static List<MeetingCentre> loadDataFromFile() {
		List<MeetingCentre> allMeetingCentres = new ArrayList<>();
		System.out.println("\n************************************************");

		File repositoryCsv = new File(MEETING_CENTRES_FILE);
		if (repositoryCsv.exists() && repositoryCsv.isFile()) {
			allMeetingCentres = parseData(repositoryCsv);
		} else {
			System.out.println("Internal repository " + repositoryCsv + " doesn't exist yet. Skipped import of data");
		}

		return allMeetingCentres;
	}

	// ****************************************************************************************************
	// DU3
	// ****************************************************************************************************
	/**
	 * Method to save the data to file. export to xml - rezervace
	 * 
	 * Aplikace si musí sama uchovávat svá data, která musejí být po ukonèení
	 * aplikace uloženy a pøi opìtovném spuštìní naèteny. Uložení dat proveïte
	 * do souboru ve formátu XML. Jeho strukturu si zvolte samostatnì. zajimave
 */
	public static void saveReservationsToXml(List<MeetingCentre> meetingCentres) {
		try {			
			XMLOutputFactory factory = XMLOutputFactory.newInstance();
			FileWriter fileWriter = new FileWriter(RESERVATIONS_FILE);
			XMLStreamWriter writer = factory.createXMLStreamWriter(fileWriter);

			// header
			writer.writeStartDocument();
			writer.writeStartElement("reservationsList");

			if (meetingCentres != null) {
				for (MeetingCentre meetingCentre : meetingCentres) {
					writer.writeStartElement("meetingCentres");
					writer.writeAttribute("meetingCentreCode", meetingCentre.getCode());

					if (meetingCentre.getMeetingRooms() != null) {
						for (MeetingRoom meetingRoom : meetingCentre.getMeetingRooms()) {
							writer.writeStartElement("meetingRooms");
							writer.writeAttribute("meetingRoomCode", meetingRoom.getCode());

							if (meetingRoom.getReservations() != null) {

								for (Reservation reservation : meetingRoom.getReservations()) {
									writer.writeStartElement("Reservation");
									writer.writeAttribute("date", reservation.getFormattedDate());
									writer.writeAttribute("timeFrom", reservation.getTimeFrom());
									writer.writeAttribute("timeTo", reservation.getTimeTo());
									writer.writeAttribute("personsCount",
											String.valueOf(reservation.getExpectedPersonCount()));
									writer.writeAttribute("customerName", reservation.getCustomer());
									writer.writeAttribute("note", reservation.getNote());
									writer.writeAttribute("videoNeeded",
											String.valueOf(reservation.isNeedVideoConference()));
									writer.writeAttribute("meetingRoomCode", reservation.getMeetingRoom().getCode());
									writer.writeEndElement(); // reservation
								}
							}
							writer.writeEndElement(); // Room
						}
						writer.writeEndElement(); // Centre
					}
				}
			}
			writer.writeEndDocument();
			writer.flush();
			writer.close();

			System.out.println();
			System.out.println("**************************************************");
			System.out.println("Reservation data was saved correctly to " + RESERVATIONS_FILE );
			System.out.println("**************************************************");
			System.out.println();

		} catch (XMLStreamException | IOException e) {
			System.out.println("ERROR occured while storing file with reservations to " + RESERVATIONS_FILE
					+ ". \nPlease fix the issue or contact your support team. The error was: " + e);
		}

	}

	/*
	 * import rezervaci z xml - rezervace
	 * 
	 * Aplikace si musí sama uchovávat svá data, která musejí být po ukonèení
	 * aplikace uloženy a pøi opìtovném spuštìní naèteny. Uložení dat proveïte
	 * do souboru ve formátu XML. Jeho strukturu si zvolte samostatnì.
	 * http://stackoverflow.com/questions/13786607/normalization-in-dom-parsing-
	 * with-java-how-does-it-work
	 * 
	 */

	public static void importReservations(List<MeetingCentre> meetingCentres) {
		int reservationsCount = 0;
		SimpleDateFormat format = new SimpleDateFormat(DATE_SLASH_FMT);
		format.setLenient(false);

		try {
			File inputXmlFile = new File(RESERVATIONS_FILE);

			DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
			DocumentBuilder dBuilder = dbFactory.newDocumentBuilder();
			Document doc = dBuilder.parse(inputXmlFile);
			doc.getDocumentElement().normalize();
			NodeList nodeList = doc.getElementsByTagName("Reservation");

			for (int i = 0; i < nodeList.getLength(); i++) {
				Node node = nodeList.item(i);

				if (node.getNodeType() == Node.ELEMENT_NODE) {
					Element element = (Element) node;
					Reservation newReservation = new Reservation();
					newReservation.setTimeFrom(element.getAttribute("timeFrom"));
					newReservation.setTimeTo(element.getAttribute("timeTo"));
					newReservation.setExpectedPersonCount(Integer.parseInt(element.getAttribute("personsCount")));
					newReservation.setCustomer(element.getAttribute("customerName"));
					newReservation.setNote(element.getAttribute("note"));
					newReservation.setNeedVideoConference(Boolean.parseBoolean(element.getAttribute("videoNeeded")));
					newReservation.setDate(format.parse(element.getAttribute("date"))); // convert to date

					// link room-reservation
					String elementMeetingRoomCode = element.getAttribute("meetingRoomCode");
					MeetingRoom curMeetingRoomHelper = new MeetingRoom();
					for (MeetingCentre meetingCentre : meetingCentres) {
						curMeetingRoomHelper = getMeetingRoomByCode(meetingCentre.getMeetingRooms(), elementMeetingRoomCode);
						if (curMeetingRoomHelper != null) {
							curMeetingRoomHelper.addReservation(newReservation);
							break;
						}
					}
					if (curMeetingRoomHelper != null) {
						newReservation.setMeetingRoom(curMeetingRoomHelper);
						reservationsCount++;
					} else {
						System.out.println("ERROR - meeting room with code <" + elementMeetingRoomCode
								+ "> was not found. File is inconsistent, reservation was not loaded. Please contact your support team. ");
					}

				}
			}

		} catch (FileNotFoundException e) {
			System.out.println("\n****************************************************");
			System.out.println(
					"WARNING. System didn't find the file with the reservations. If it is running for the first time, it's OK. Otherwise please contact your support team.");
			System.out.println("****************************************************");

		} catch (Exception e) {
			System.out.println("\n****************************************************");
			System.out.println("ERROR while loading reservations to the system. Please contact your support team. ");
			e.printStackTrace();
			System.out.println("****************************************************");
		}

		System.out.println();
		System.out.println("**************************************************");
		System.out.println("< " + reservationsCount + " > Reservations imported to the system from the repository " + RESERVATIONS_FILE );
		System.out.println("**************************************************");
		System.out.println();

	}

	/**
	 * Method to export data to file
	 * 
	 * @param controllReservation
	 *            Object of reservation controller to get all reservation and
	 *            other data if needed
	 *            http://stackoverflow.com/questions/17229418/jsonobject-why-jsonobject-changing-the-order-of-attributes
	 *            other option is to use - which is not much suitable for loops: JsonObject reservationJson = new
	 *                                                       JsonObject() .createObjectBuilder("aa").build();
	 *            jsckson json export is not suitable due to overloaded column name and cyclic model (room point to centre and centre points to room)
	 * 
	 */

	public static void exportDataToJSON(List<MeetingCentre> meetingCentres) {
		SimpleDateFormat jsonFormat = new SimpleDateFormat(DATE_DOT_FMT);
		String locationFilter = Choices.getInput("Enter name of the file for export: ");

		// heading
		JSONObject reservationsJson = new JSONObject();
		reservationsJson.put("schema", "PLUS4U.EBC.MCS.MeetingRoom_Schedule_1.0");
		reservationsJson.put("uri", "ues:UCL-BT:UCL.INF/DEMO_REZERVACE:EBC.MCS.DEMO/MR001/SCHEDULE");
		JSONArray reservationsDataArray = new JSONArray();
		reservationsJson.put("data", reservationsDataArray);

		// body
		for (MeetingCentre meetingCentre : meetingCentres) {
			if (meetingCentre.getMeetingRooms() != null) {
				JSONObject meetingRoomJson = new JSONObject();
				meetingRoomJson.put("Meetingcentre", meetingCentre.getCode());

				for (MeetingRoom meetingRoom : meetingCentre.getMeetingRooms()) {
					if (!meetingRoom.getAllReservationDates().isEmpty()) {
						meetingRoomJson.put("meetingRoom", meetingRoom.getCode());
						JSONObject reservationRoomJson = new JSONObject();
						JSONObject reservationDateJson = new JSONObject();
						reservationRoomJson.put("meetingCentre", meetingCentre.getCode());
						reservationRoomJson.put("meetingRoom", meetingRoom.getCode());

						for (Date meetingRoomDate : meetingRoom.getAllReservationDates()) {
							JSONArray reservationDateArray = new JSONArray();

							List<Reservation> reservationsOfDate = meetingRoom
									.getSortedReservationsByDate(meetingRoomDate);
							for (Reservation reservation : reservationsOfDate) {
								JSONObject reservationDetailsJson = new JSONObject();
								reservationDetailsJson.put("from", reservation.getTimeFrom());
								reservationDetailsJson.put("to", reservation.getTimeTo());
								reservationDetailsJson.put("expectedPersonsCount",reservation.getExpectedPersonCount());
								reservationDetailsJson.put("customer", reservation.getCustomer());
								reservationDetailsJson.put("videoConference", reservation.isNeedVideoConference());
								reservationDetailsJson.put("note", reservation.getNote());
								reservationDateArray.add(reservationDetailsJson);
								reservationDateJson.put(jsonFormat.format(meetingRoomDate), reservationDateArray);
								reservationDateJson.put(jsonFormat.format(meetingRoomDate), reservationDateArray);
							}
							reservationRoomJson.put("reservations", reservationDateJson);
						}
						reservationsDataArray.add(reservationRoomJson);
					}
				}
			}

		}
		try (FileWriter file = new FileWriter(locationFilter)) {
			file.write(reservationsJson.toString());
			System.out.println("\n****************************************************");
			System.out.println("Successfully exported file with reservations: " + locationFilter);
			System.out.println("****************************************************");

		} catch (IOException e) {
			System.out.println("\n****************************************************");
			System.out.println("ERROR while exporting reservations to file "+ locationFilter + ". Please try again or contact your local support team. ");
			//e.printStackTrace();
			System.out.println("****************************************************");

		}

	}

	private static MeetingRoom getMeetingRoomByCode(List<MeetingRoom> meetingRooms, String meetingRoomCode) {
		if (meetingRooms != null) {
			for (MeetingRoom meetingRoom : meetingRooms) {
				if (meetingRoom != null) {
					if (meetingRoom.getCode().equals(meetingRoomCode)) {
						return meetingRoom;
					}
				}
			}

		}
		return null; // meetingRoom null if not found
	}

}
