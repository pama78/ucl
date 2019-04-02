void buttonCheck()  {
  buttonState = digitalRead(BUTTON_PIN);
  if (buttonState != buttonOld)  {
    Serial.print("*** Stav tlacitka zmenen***");

    if (arduinoMod == 1) {
      arduinoMod = 0;
    } else {
      arduinoMod = 1;
    }
  }

  Serial.print(buttonState);
  if (arduinoMod == 1) {
    // turn LED on:
    digitalWrite(LED_PIN, HIGH);
  } else {
    // turn LED off:
    digitalWrite(LED_PIN, LOW);
  }
}
