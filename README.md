arduino-thermostat
==================

Trying to replace a broken Differential Temperature Thermostat DTT-94 with an Arduino


太陽熱温水器のサーモスタットが壊れたので代わりのものをつくる

壊れたもの
--------

Differential Temperature Thermostat DTT-94, Heliotrope General

温度計はSAS-10というもののようだ。パネルから温水が戻ってくる配管のタンクの近くにひとつとりつけられている。もうひとつはパネルにとりつけられているものと思われる。回路計では両方とも温度を検出しているような抵抗値を示していた。

温度計の仕様
----------

下記にSAS-10の温度(F)-抵抗のテーブルがある
* http://www.heliodyne.com/products_systems/control_units/SAS-10-RT.pdf
* http://www.heliodyne.com/products_systems/control_units/DeltaT.pdf
これを
[resistance-vs-temperature.xlsx](SAS-10/resistance-vs-temperature.xlsx)
にまとめた。
0℃から100℃までを測定しようとすると、32.65kΩから678.4Ωまでを測定する必要がある。

### 近似式
http://en.wikipedia.org/wiki/Thermistor#Steinhart.E2.80.93Hart_equation
より
`t(r)=1/(a+b*log(r)+c*(log(r)**3))-273.16`
ただしrは抵抗値(Ω)、tは温度(℃)。

[resistance-vs-temperature.plot](SAS-10/resistance-vs-temperature.plot)
でフィットすると

| Parameter | Best fit (1/K) |
|---|------------|
| a | 0.00112974 |
| b | 0.00023399 |
| c | 8.8342e-08 |

![resistance-vs-temperature](SAS-10/resistance-vs-temperature.png)

Arduinoでの抵抗値の読み
--------------------
* `analogRead(pin)`は0から5ボルトの入力電圧を0から1023の数字に変換する
* `analogReference(type)`はアナログ入力で使われる基準電圧を設定する。
  * `DEFAULT`: 電源電圧(5V)
  * `INTERNAL`: 内蔵基準電圧(1.1V、2.56V)
  * `EXTERNAL`: AREFピンへの電圧(0-5V、32KΩでGNDへ)

* http://www.eleki-jack.com/FC/2011/09/arduino2-3.html
  温度計はGNDとアナログ入力の間、アナログ入力と電源の間に固定抵抗
* http://homepage3.nifty.com/sudamiyako/zk/AVR_ADC/AVR_ADC.html
  Sample & Holdコンデンサに注意

分圧抵抗の大きさで分解能が変わるんだねえ。
Vcc 5VからR1と温度計を直列にGNDまで接続してその接続点の電圧Vadcを読む場合。
[resistance-vs-temperature.xlsx](SAS-10/resistance-vs-temperature.xlsx)より、
温度分解能は0-100℃で抵抗値がリニアに変化すると近似した場合。

Rthermo (Ω) | Vadc | Vadc | Vadc | Vadc | Vadc | Vadc | Vadc
-------|-------|-------|-------|-------|-------|-------|--------
678.4 | 2.02 | 1.56 | 1.18 | 0.85 | 0.63 | 0.45 | 0.32
32,650.0 | 4.85 | 4.78 | 4.68 | 4.54 | 4.37 | 4.14 | 3.83
R1 (Ω) | 1,000 | 1,500 | 2,200 | 3,300 | 4,700 | 6,800 | 10,000
Imax (mA) | 5.0 | 3.3 | 2.3 | 1.5 | 1.1 | 0.7 | 0.5
Resolution (C/ADC) | 0.173 | 0.152 | 0.139 | 0.133 | 0.131 | 0.133 | 0.139

E6系列内では6.8kΩを分圧抵抗に使うのが良さそう。

MintDuinoでの試験
-----------------
最小の回路図
https://twitter.com/zundan/status/470310026058285056

### アナログ入力を読んでシリアルポートに出力してみる
X1のDebianに入れたarduinoパッケージのarduinoコマンドがIDE。
* Tools-Board-Arduino Duemilanove w/ ATmega328
* Tools-Serial Port-/dev/ttyUSB0
* File-Upload (Ctrl+U) でコンパイル、アップロード、実行
* Tools-Serial Monitor (Ctrl+Shift+M)でシリアルモニター

File-Examples-Basics-ReadAnalogVoltageを改造して(delayを加えて)
下記のようにして、モニタを開いたら読めているようだ。

```
/*
  ReadAnalogVoltage
  Reads an analog input on pin 0, converts it to voltage, and prints the result to the serial monitor.
  Attach the center pin of a potentiometer to pin A0, and the outside pins to +5V and ground.

 This example code is in the public domain.
 */

// the setup routine runs once when you press reset:
void setup() {
  // initialize serial communication at 9600 bits per second:
  Serial.begin(9600);
}

// the loop routine runs over and over again forever:
void loop() {
  // read the input on analog pin 0:
  int sensorValue = analogRead(A0);
  // Convert the analog reading (which goes from 0 - 1023) to a voltage (0 - 5V):
  float voltage = sensorValue * (5.0 / 1023.0);
  // print out the value you read:
  Serial.println(voltage);
  delay(100);
}
```

* `delay(100)`で9V電池からの電流は31.5mA。
* `delay(1000)`で9V電池からの電流は28.6mA。

Cで読む。
DropBox/arduino-thermostat/serial-read/serial-read.c

``` serial-read.c
/* http://www.cmrr.umn.edu/~strupp/serial.html */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>
#include <termios.h>
#include <signal.h>
#include <time.h>

#define BUFFER_SIZE 256
#define SERIAL_PORT "/dev/ttyUSB0"

int continuing;
void terminate(int signum);

void
terminate(int signum)
{
	continuing = 0;
}

int
main(void)
{
	int fd;
	struct termios options, orig_options;
	char buffer[BUFFER_SIZE], timestr[BUFFER_SIZE];
	ssize_t n;
	struct tm tm;
	time_t t;

	fd = open(SERIAL_PORT, O_RDONLY | O_NOCTTY);
	if (fd == -1)
		{
			perror("open");
			return EXIT_FAILURE;
		}

	tcgetattr(fd, &options);
	memcpy(&orig_options, &options, sizeof(options));
	options.c_cflag |= (CLOCAL | CREAD);

	/* https://learn.adafruit.com/ftdi-friend/com-slash-serial-port-name */
	/* 9600 baud, 8 bit, no parity, 1 stop bit, no flow control */
	cfsetispeed(&options, B9600);
	options.c_cflag &= ~CSIZE;
	options.c_cflag &= ~PARENB;
	options.c_cflag &= ~CSTOPB;
	options.c_cflag &= ~CSIZE;
	options.c_cflag |= CS8;
	options.c_cflag &= ~CRTSCTS;
	options.c_iflag |= (INPCK | ISTRIP);
	options.c_iflag &= ~(IXON | IXOFF | IXANY);

	/* canonical input, no echo */
	options.c_lflag |= ICANON;
	options.c_lflag &= ~(ECHO | ECHOE);

	tcsetattr(fd, TCSANOW, &options);

	signal(SIGINT, terminate);
	signal(SIGTERM, terminate);

	continuing = 1;
	while(continuing)
		{
			n = read(fd, buffer, sizeof(buffer));
			if (n < 1)
				{
					if (n == -1) perror("read");
					break;
				}
			time(&t);
			localtime_r(&t, &tm);
			strftime(timestr, sizeof(timestr), "%Y-%m-%d %H:%M:%S ", &tm);
			fputs(timestr, stdout);
			fwrite(buffer, n, 1, stdout);
			fflush(stdout);
		}

	fputs("Stopping\n", stdout);
	tcsetattr(fd, TCSANOW, &orig_options);
	return EXIT_SUCCESS;
}
```

### 温度計と抵抗を配線して値をしばらく記録してみる

### 値を抵抗や温度に変換してみる
