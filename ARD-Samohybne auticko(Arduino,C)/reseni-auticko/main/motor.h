
// *** definice metod pro motor ***
void motorStop(byte motor) {
  if (motor == MOTOR_L) {
    analogWrite(MOTOR_L_PWM_PIN, 0);
    digitalWrite(MOTOR_L_DIR_PIN, LOW);
  }
  else {
    analogWrite(MOTOR_R_PWM_PIN, 0);
    digitalWrite(MOTOR_R_DIR_PIN, LOW);
  }
}

void motorVeryFastFwd(byte motor) {
  float speed = 255;
  if (motor == MOTOR_L) {
    analogWrite(MOTOR_L_PWM_PIN, speed);
    digitalWrite(MOTOR_L_DIR_PIN, LOW);
  }
  else {
    analogWrite(MOTOR_R_PWM_PIN, speed);
    digitalWrite(MOTOR_R_DIR_PIN, LOW);
  }
}

void motorFastFwd(byte motor) {
  float speed = 190;
  if (motor == MOTOR_L) {
    analogWrite(MOTOR_L_PWM_PIN, speed);
    digitalWrite(MOTOR_L_DIR_PIN, LOW);
  }
  else {
    analogWrite(MOTOR_R_PWM_PIN, speed);
    digitalWrite(MOTOR_R_DIR_PIN, LOW);
  }
}

void motorSlowFwd(byte motor) {
  float speed = 160;
  if (motor == MOTOR_L) {
    analogWrite(MOTOR_L_PWM_PIN, speed);
    digitalWrite(MOTOR_L_DIR_PIN, LOW);
  }
  else {
    analogWrite(MOTOR_R_PWM_PIN, speed);
    digitalWrite(MOTOR_R_DIR_PIN, LOW);
  }
}

void motorVeryFastBwd(byte motor) {
  float speed = 0;
  if (motor == MOTOR_L) {
    analogWrite(MOTOR_L_PWM_PIN, speed);
    digitalWrite(MOTOR_L_DIR_PIN, HIGH);
  }
  else {
    analogWrite(MOTOR_R_PWM_PIN, speed);
    digitalWrite(MOTOR_R_DIR_PIN, HIGH);
  }
}

void motorFastBwd(byte motor) {
  float speed = 65;
  if (motor == MOTOR_L) {
    analogWrite(MOTOR_L_PWM_PIN, speed);
    digitalWrite(MOTOR_L_DIR_PIN, HIGH);
  }
  else {
    analogWrite(MOTOR_R_PWM_PIN, speed);
    digitalWrite(MOTOR_R_DIR_PIN, HIGH);
  }
}

void motorSlowBwd(byte motor) {
  float speed = 95;
  if (motor == MOTOR_L) {
    analogWrite(MOTOR_L_PWM_PIN, speed);
    digitalWrite(MOTOR_L_DIR_PIN, HIGH);
  }
  else {
    analogWrite(MOTOR_R_PWM_PIN, speed);
    digitalWrite(MOTOR_R_DIR_PIN, HIGH);
  }
}
