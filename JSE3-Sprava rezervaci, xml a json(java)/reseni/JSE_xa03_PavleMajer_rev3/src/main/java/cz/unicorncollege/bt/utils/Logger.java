package cz.unicorncollege.bt.utils;


import java.io.PrintStream;

public class Logger {
	boolean DEBUG = false; // true/false - switch on/off debug messages
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
