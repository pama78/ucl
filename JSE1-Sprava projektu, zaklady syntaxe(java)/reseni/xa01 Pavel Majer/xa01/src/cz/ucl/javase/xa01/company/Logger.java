package cz.ucl.javase.xa01.company;

// IMPLEMENTUJTE ZDE
// Upravte tuto tridu tak, aby v programu byla vzdy prave jedna a ta sama instance. 
// Jde o implementaci podle navrhoveho vzoru Singleton.
// Cilem teto tridy je poskytnout moznost zapisovani logovacich informaci. Zatim neumime
// pracovat se soubory nebo napr. s databazi, proto je logovani simulovano pouhym vypisem do konzole.
    /*
    public class Logger {
	public void log(String message) {
		System.out.println("Logger: " + message);
	}*/
import java.io.PrintStream;

public class Logger {
	boolean DEBUG = false; // vypnout / zapnout debug hlasky
	private final java.io.PrintStream out;
	private static Logger instance;

	private Logger(PrintStream out) {
		this.out = out;
	}

	public static Logger getInstance() {
		if (instance == null) {
			instance = new Logger(System.out);
		}
		return instance;
	}

	public void log(String message) {
		out.println(message);
	}

	public void debug(String message, String isEOL) {

		if (isEOL == "EOL" && DEBUG == true) {
			out.println(message);
		}

		if (isEOL == "BOL" && DEBUG == true) {
			out.print("    DEBUG: " + message);
		}

		if (isEOL == "MOL" && DEBUG == true) {
			out.print(message);
		}

		if (isEOL == "OL" && DEBUG == true) {
			out.println("    DEBUG: " + message);
		}

	}
}
