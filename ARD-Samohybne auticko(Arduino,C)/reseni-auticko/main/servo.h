void servoMove()  {
  curPos = myServo.read();
  if (servoDirection == SERVO_RIGHT )  {
    if (curPos > servoLeftMin  ) {
      int newPos = curPos - SERVO_STEPS;
      myServo.write(newPos);
      Serial.println("Servo pozice :");
      Serial.println(curPos);
    } else {
      Serial.println("Servo pozice :");
      Serial.println(curPos);
      servoDirection = SERVO_LEFT;
    }
  } else {  // servo right
    if (curPos < servoRightMin ) {
      Serial.println("Servo pozice :");
      Serial.println(curPos);
      int newPos = curPos + SERVO_STEPS;
      myServo.write(newPos);
    } else {
      servoDirection = SERVO_RIGHT;
    }
  }
}
