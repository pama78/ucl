int curPos = 0; // pozice serva
int pos = 0;    // variable to store the servo position
int servoDirection = SERVO_LEFT;
int distance;
int buttonState = 0;
int buttonOld = 0;
int arduinoMod = 0; // 0 - ostrazity, 1 - jede i dopredu
int servoLeftMin = SERVO_LEFT_MIN;
int servoRightMin = SERVO_RIGHT_MIN;
unsigned long previousMillisMotor = 0; // will store last time LED was updated
unsigned long previousMillisServo = 0; // will store last time LED was updated
Servo myServo;  // create servo object to control a servo
NewPing sonar(TRIGGER_PIN, ECHO_PIN, MAX_DISTANCE);
