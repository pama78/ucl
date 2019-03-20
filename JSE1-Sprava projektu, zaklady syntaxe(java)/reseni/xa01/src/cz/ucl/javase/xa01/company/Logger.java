package cz.ucl.javase.xa01.company;

// IMPLEMENTUJTE ZDE
// Upravte tuto tridu tak, aby v programu byla vzdy prave jedna a ta sama instance. 
// Jde o implementaci podle navrhoveho vzoru Singleton.
// Cilem teto tridy je poskytnout moznost zapisovani logovacich informaci. Zatim neumime
// pracovat se soubory nebo napr. s databazi, proto je logovani simulovano pouhym vypisem do konzole.
public class Logger {
	public void log(String message) {
		System.out.println("Logger: " + message);
	}
}
