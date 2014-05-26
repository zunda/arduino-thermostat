/*
 Based upon an example code ReadAnalogVoltage in the public domain
 that comes with the Arduino IDE.
 */

void setup() {
  Serial.begin(9600);
}

void loop() {
  int sensorValue = analogRead(A0);
  float voltage = sensorValue * (5.0 / 1023.0);
  Serial.println(voltage);
  delay(1000);
}
