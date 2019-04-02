void measureDistance()  {
  int avg = 0;
  int cnt = 0;
  int vzd = 0;
  distance = sonar.ping_cm();
  if (distance == 0) {
    distance = 999;
  }
  Serial.println(distance);
}
