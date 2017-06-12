/*
 Measure.ino - read temperature from thermometers

 Based upon an example code ReadAnalogVoltage in the public domain
 that comes with the Arduino IDE.

 Copyright (C) 2017 zunda <zunda at freeshell.org>

 Permission is granted for use, copying, modification,
 distribution, and distribution of modified versions of this work
 as long as the above copyright notice is included.
 */

const int pin1 = A0;
const int pin2 = A1;

/* Voltage divider (Ohm) */
const float dr1 = 4610;
const float dr2 = 4670;

/* Hart Equation for SAS-10 thermometer */
const float ha = 0.00112974;
const float hb = 0.00023399;
const float hc = 8.8342e-08;

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

/*
 converts resistance (ohm) of an SAS-10 thermometer into temperature (Deg-C)

 t(r)=1/(a+b*log(r)+c*(log(r)**3))-273.16
 http://en.wikipedia.org/wiki/Thermistor#Steinhart.E2.80.93Hart_equation

 SAS-10:
 a: 0.00112974
 b: 0.00023399
 c: 8.8342e-08
 */
float temperature(float r)
{
	return 1 / (ha + hb * log(r) + hc * pow(log(r), 3)) - 273.16;
}

void setup() {
	Serial.begin(9600);
}

void serialPrintFloat(float value, int digits) {
	if (value < 0) {
		Serial.print("-");
		value *= -1;
	}
		
	Serial.print(int(value));
	Serial.print(".");

	int i;
	for(i = 0; i < digits; i++) {
		value -= int(value);
		value *= 10;
		Serial.print(int(value));
	}
}


void loop() {
	float xr1 = readResistance(pin1, dr1);
	float xr2 = readResistance(pin2, dr2);

	if (xr1 > 0) {
		serialPrintFloat(temperature(xr1), 2);
	} else {
		Serial.print("*");
	}
	Serial.print("\t");
	if (xr2 > 0) {
		serialPrintFloat(temperature(xr2), 2);
	} else {
		Serial.print("*");
	}
	Serial.println("");

	delay(1000);
}
