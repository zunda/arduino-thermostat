/*
 ReadAdc.ino - read ADCs
 
 Based upon an example code ReadAnalogVoltage in the public domain
 that comes with the Arduino IDE.
 
 Copyright (C) 2014 zunda <zunda at freeshell.org>
 
 Permission is granted for use, copying, modification,
 distribution, and distribution of modified versions of this work
 as long as the above copyright notice is included.
 */

const int pin1 = A0;
const int pin2 = A1;

void setup() {
  Serial.begin(9600);
}

void loop() {
  Serial.print(analogRead(pin1));
  Serial.print("\t");
  Serial.println(analogRead(pin2));
  delay(1000);
}

