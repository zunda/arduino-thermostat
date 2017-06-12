/*
	read-serial.c - read text from a serial line
	like output from an Arduino through an FTDI friend

	Copyright (C) 2014 zunda <zunda at freeshell.org>

	Permission is granted for use, copying, modification,
	distribution, and distribution of modified versions of this work
	as long as the above copyright notice is included.

	Based upon an introduction at http://www.cmrr.umn.edu/~strupp/serial.html
*/

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

	/* canonical input, no echo, enable interruptions */
	options.c_lflag |= ICANON;
	options.c_lflag &= ~(ECHO | ECHOE);

	tcsetattr(fd, TCSANOW, &options);

	/* terminate when receiving SIGINT or SIGTERM */
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
			if (n > 1)
				{
					time(&t);
					localtime_r(&t, &tm);
					strftime(timestr, sizeof(timestr), "%Y-%m-%d %H:%M:%S\t", &tm);
					fputs(timestr, stdout);
					fwrite(buffer, n, 1, stdout);
					fflush(stdout);
				}
		}
	
	fputs("Stopping\n", stdout);
	tcsetattr(fd, TCSANOW, &orig_options);
	return EXIT_SUCCESS;
}
