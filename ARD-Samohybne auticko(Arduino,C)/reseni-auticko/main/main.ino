#include <NewPing.h>
#include <Servo.h>
#include "config.h"
#include "variables.h"
#include "servo.h"
#include "sensor.h"
#include "button.h"
#include "motor.h"

void setup() {
  pinMode(MOTOR_R_DIR_PIN, OUTPUT);
  pinMode(MOTOR_R_PWM_PIN, OUTPUT);
  pinMode(MOTOR_L_DIR_PIN, OUTPUT);
  pinMode(MOTOR_L_PWM_PIN, OUTPUT);
  pinMode(LED_PIN, OUTPUT);
  pinMode(BUTTON_PIN, INPUT);
  Serial.begin(9600);
  myServo.attach(9);
  myServo.write(90);
}

void loop() {
  unsigned long currentMillisMotor = millis();
  unsigned long currentMillisServo = millis();
  // tlačítko
  buttonCheck();
  //servo
  if (currentMillisServo - previousMillisServo >= INTERVAL_SERVO) {
    previousMillisServo = currentMillisServo;
    servoMove();
  }
  Serial.println("konec serva, zacatek mereni"  );

  // sensor
  measureDistance();

  // ovládání směrů
  if (currentMillisMotor - previousMillisMotor >= INTERVAL_MOTOR) {
    previousMillisMotor = currentMillisMotor;
    if (arduinoMod == 1) {
      if (distance > 140)   {
        Serial.println("*** Jedu velmi rychle  ***");      // prints another carriage return
        motorVeryFastFwd(MOTOR_L);
        motorVeryFastFwd(MOTOR_R);
        servoLeftMin = 45;
        servoRightMin = 135;
      }
      else if (distance > 80) {
        Serial.println("*** Jedu pomalu ***");      // prints another carriage return
        motorSlowFwd(MOTOR_L);
        motorSlowFwd(MOTOR_R);
        servoLeftMin = 45;
        servoRightMin = 135;
      }
      else if ((distance > 50) && (curPos < 90)) {
        Serial.println("zahybam do prava");
        motorFastFwd(MOTOR_L);
        motorStop(MOTOR_R);
        servoLeftMin = 90;
        servoRightMin = 170;
      }
      else if ((distance > 50) && (curPos >= 90)) {
        Serial.println("zahybam do leva");
        motorStop(MOTOR_L);
        motorFastFwd(MOTOR_R);
        servoLeftMin = 10;
        servoRightMin = 90;
      }
      else if ((distance > 1) && (curPos < 90)) {
        Serial.println("couvám");
        motorVeryFastBwd(MOTOR_R);
        motorSlowBwd(MOTOR_L);
      }
      else if ((distance > 1) && (curPos >= 90)) {
        Serial.println("couvám");
        motorSlowBwd(MOTOR_R);
        motorVeryFastBwd(MOTOR_L);
      }
      else if (curPos < 90) {
        Serial.println("*** otočka  ***");
        motorSlowFwd(MOTOR_L);
        motorFastBwd(MOTOR_R);
      }
      else {
        motorFastBwd(MOTOR_L);
        motorSlowFwd(MOTOR_R);
      }
    }
    // ostražitý mod
    else {
      if (distance < 40) {
        motorFastBwd(MOTOR_L);
        motorFastBwd(MOTOR_R);
      }
      else if (distance < 20) {
        motorVeryFastBwd(MOTOR_L);
        motorVeryFastBwd(MOTOR_R);
      }
      else {
        motorStop(MOTOR_L);
        motorStop(MOTOR_R);
      }
    }
  }
}

