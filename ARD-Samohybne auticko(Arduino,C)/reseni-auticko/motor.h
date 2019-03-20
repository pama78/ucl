
// *** definice metod pro motor ***
void motor_stop(byte motor) {
  if (motor == MOTOR_L) {
    analogWrite(MOTOR_L_PWM_PIN, 0);
    digitalWrite(MOTOR_L_DIR_PIN, LOW);
  }
  else {
    analogWrite(MOTOR_R_PWM_PIN, 0);
    digitalWrite(MOTOR_R_DIR_PIN, LOW);
  }
}

void motor_very_fast_fwd(byte motor) {
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

void motor_fast_fwd(byte motor) {
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

void motor_slow_fwd(byte motor) {
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

void motor_very_fast_bwd(byte motor) {
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

void motor_fast_bwd(byte motor) {
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

void motor_slow_bwd(byte motor) {
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