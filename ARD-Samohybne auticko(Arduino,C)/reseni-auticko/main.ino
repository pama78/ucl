#include <NewPing.h>
#include <Servo.h>
#include "config.h"
#include "motor.h"

Servo myservo;  // create servo object to control a servo
int pos = 0;    // variable to store the servo position
int button_state = 0;
int button_old = 0;
int arduino_mod = 0; // 0 - ostrazity, 1 - jede i dopredu
NewPing sonar(TRIGGER_PIN, ECHO_PIN, MAX_DISTANCE);
int servo_direction = SERVO_LEFT;
unsigned long previousMillisMotor = 0; // will store last time LED was updated
unsigned long previousMillisServo = 0; // will store last time LED was updated


void setup() {
  pinMode(MOTOR_R_DIR_PIN, OUTPUT);
  pinMode(MOTOR_R_PWM_PIN, OUTPUT);
  pinMode(MOTOR_L_DIR_PIN, OUTPUT);
  pinMode(MOTOR_L_PWM_PIN, OUTPUT);
  pinMode(LED_PIN, OUTPUT);
  pinMode(BUTTON_PIN, INPUT);
  Serial.begin(9600);
  myservo.attach(9);  // attaches the servo on pin 9 to the servo object
  myservo.write(90);              // tell servo to go to position in variable 'pos'
}


void loop() {
  unsigned long currentMillisMotor = millis();
  unsigned long currentMillisServo = millis();
  //servo
  int cur_pos = myservo.read();
  if (currentMillisServo - previousMillisServo >= INTERVAL_SERVO) {
    previousMillisServo = currentMillisServo;
    if ( servo_direction == SERVO_RIGHT )  {
      if (cur_pos > SERVO_LEFT_MIN  ) {
        //   Serial.println("SERVO RIGHT - begin"  );
        int new_pos = cur_pos - SERVO_STEPS;
        myservo.write(new_pos);
        //  Serial.println("current :" + servo_direction );
        Serial.println("Servo pozice :");
        Serial.println(cur_pos);
        //  Serial.println("jedu doprava"  );
        delay(1);                       // waits 15ms for the servo to reach the position

      } else {
        //  Serial.println("SERVO RIGHT - curpos >5 else"  );
        //  Serial.println( servo_direction );
        Serial.println("Servo pozice :");
        Serial.println(cur_pos);
        //  Serial.println( cur_pos );
        //  Serial.println("Menim servo direction na servo left"  );
        servo_direction = SERVO_LEFT;
      }
    } else {  // servo right
      if (cur_pos < SERVO_RIGHT_MIN ) {
        //   Serial.println("SERVO not RIGHT - curpos <170"  );
        //   Serial.println( servo_direction );
        //    Serial.println( cur_pos );
        Serial.println("Servo pozice :");
        Serial.println(cur_pos);
        int new_pos = cur_pos + SERVO_STEPS;
        myservo.write(new_pos);
        //   Serial.println("zmenil jsem cur pos +3");
        delay(1);                       // waits 15ms for the servo to reach the position
      } else {
        //     Serial.println("SERVO not RIGHT - curpos not <170"  );
        //     Serial.println( servo_direction );
        //     Serial.println( cur_pos );
        //     Serial.println("obracim pozici a od ted pojedu doprava current :"  );
        servo_direction = SERVO_RIGHT;
      }
    }
  }
  Serial.println("konec serva, zacatek mereni"  );

  //motory
  delay(10);
  //int uS = sonar.ping_cm();
  //int sonars[5]={0,0,0,0,0};
  int avg = 0;
  int cnt = 0;
  int vzd = 0;
  int uS;
  for (int i = 0; i < 5; i++) {
    //sonars[i] = sonar.ping_cm();
    // Serial.println(i);
    // sonars[i]=i;
    delay(10);
    cnt = cnt + 1;
    vzd = sonar.ping_cm();
    avg = avg + vzd;
    delay(100);

    //Serial.print(vzd);
    //Serial.println(avg);
  }
  Serial.println("konec mereni, zacatek motoru"  );

  uS = avg / cnt;
  Serial.print("zmereno a zprumerovano:"   );
  Serial.println(uS);      // prints another carriage return

  // tlačítko
  button_state = digitalRead(BUTTON_PIN);
  if (button_state != button_old)  {
    Serial.print("*** Stav tlacitka zmenen***");

    if (arduino_mod == 1) {
      arduino_mod = 0;
    } else {
      arduino_mod = 1;
    }
  }

  Serial.print(button_state);
  if (arduino_mod == 1) {
    // turn LED on:
    digitalWrite(LED_PIN, HIGH);
  } else {
    // turn LED off:
    digitalWrite(LED_PIN, LOW);
  }


  // ovládání směrů
  if (currentMillisMotor - previousMillisMotor >= INTERVAL_MOTOR) {
    previousMillisMotor = currentMillisMotor;
    if ((uS > 100) || (uS == 0))   {
      Serial.println("*** Jedu rychle  ***");      // prints another carriage return
      //digitalWrite(MOTOR_R_DIR_PIN, HIGH);   // turn the LED on (HIGH is the voltage level)
      //analogWrite(MOTOR_R_PWM_PIN, -200);   // turn the LED on (HIGH is the voltage level)
      //digitalWrite(MOTOR_L_DIR_PIN, HIGH);   // turn the LED on (HIGH is the voltage level)
      //analogWrite(MOTOR_L_PWM_PIN, -200);   // turn the LED on (HIGH is the voltage level)
      motor_very_fast_fwd(MOTOR_L);
      motor_very_fast_fwd(MOTOR_R);
    } else if ((uS > 80) || (uS == 0)) {
      Serial.println("*** Jedu pomalu ***");      // prints another carriage return
      motor_slow_fwd(MOTOR_L);
      motor_slow_fwd(MOTOR_R);
    }
    else if ((uS > 40) || (uS == 0)) {
      Serial.println(" *** Musim zmenit smer ***");      // prints another carriage return
      if (cur_pos < 90) {
        Serial.println("a honem zahybam do prava");
        motor_slow_fwd(MOTOR_L);
        motor_stop(MOTOR_R);
      }
      else {
        Serial.println("a honem zahybam do leva");
        motor_stop(MOTOR_L);
        motor_slow_fwd(MOTOR_R);
      }
    }
    else {
      Serial.println("*** Brzdim nebo couvam  ***");
      motor_slow_bwd(MOTOR_L);
      motor_slow_bwd(MOTOR_R);
    }
  }
  else {
    motor_stop(MOTOR_L);
    motor_stop(MOTOR_R);
  }
}


