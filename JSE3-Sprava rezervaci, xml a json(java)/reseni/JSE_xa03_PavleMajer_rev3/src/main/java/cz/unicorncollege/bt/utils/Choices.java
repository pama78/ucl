package cz.unicorncollege.bt.utils;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.List;

public class Choices {

	/**
	 * Method to get the user choice from some list of options.
	 *
	 * @param choiceText
	 *            String - Information text about options.
	 * @param choices
	 *            List - list of options given to the user.
	 * @return int - choosen option.
	 */
	public static int getChoice(String choiceText, List<String> choices) {
		
		System.out.println(choiceText);
		for (int i = 0; i < choices.size(); i++) {
			if(choices.get(i).length() > 0){
				System.out.println("  " + (i + 1) + " - " + choices.get(i));
			}else{
				System.out.println("");
			}
		}
		
		System.out.print("> ");
		BufferedReader r = new BufferedReader(new InputStreamReader(System.in));

		try {
			return Integer.parseInt(r.readLine().trim());
		} catch (Exception e) {
			return -1;
		}
	}

	/**
	 * Method to just to show choices, without explicit need of choosing them
	 */
	public static int showChoices(String choiceText, List<String> choices) {

		System.out.println(choiceText);
		for (int i = 0; i < choices.size(); i++) {
			System.out.println("  " + (i + 1) + " - " + choices.get(i));
		}

		System.out.print("> ");
		return 0;
	}

	/**
	 * Method to get the response from the user, typicaly some text or another
	 * data to fill in some object
	 *
	 * @param choiceText
	 *            String - Info about what to enter.
	 * @return String - user's answer.
	 */
	public static String getInput(String choiceText) {
		String result = null;
		System.out.print(choiceText);

		BufferedReader r = new BufferedReader(new InputStreamReader(System.in));
		try {
			result = r.readLine().trim();
		} catch (Exception e) {
		}

		return result;
	}
}
