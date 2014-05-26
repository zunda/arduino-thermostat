/*
 Control.ino - read temperature from thermometers and control a relay

 Based upon an example code ReadAnalogVoltage in the public domain
 that comes with the Arduino IDE.

 Copyright (C) 2014 zunda <zunda at freeshell.org>

 Permission is granted for use, copying, modification,
 distribution, and distribution of modified versions of this work
 as long as the above copyright notice is included.
 */

const int pin1 = A0;
const float r1 = 4610;  /* measured */

/*
 reads voltage from the analog input (pin) and returns
 resistance of register connected between the pin and GND
 provided that another fixed register connects between the pin
 and Vcc

 returns -1 for infinity
 */
float readResistance(int pin, float r)
{
	int sensorValue = analogRead(pin);
	if (sensorValue >= 1023) return -1;
	return r * (float) sensorValue / (float) (1023 - sensorValue);
}

void setup() {
  Serial.begin(9600);
}

void loop() {
  Serial.println(readResistance(pin1, r1));
  /* Measured Shown (Ohm)      */
  /* 215      187.59           */
  /* 968      931.75 or 938.27 */
  delay(1000);
}
