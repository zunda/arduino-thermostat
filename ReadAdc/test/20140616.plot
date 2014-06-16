reset
set style data points
set xlabel "Pin voltage (V)"
set ylabel "Output - ideal (ADU)"
set key bottom right
plot \
"20140615.A0-103.log" us 2:($1-1024*$2/4.91) tit "4.91V-4.61k-A0-10Kmax-GND",\
"20140615.A0-104.log" us 2:($1-1024*$2/4.94) tit "4.94V-4.61k-A0-100Kmax-GND",\
"20140615.A1-103.log" us 2:($1-1024*$2/4.91) tit "4.91V-4.67k-A1-10Kmax-GND",\
"20140615.A1-104.log" us 2:($1-1024*$2/4.91) tit "4.91V-4.67k-A1-100Kmax-GND"
set term push
set term png small size 480,360
set output "20140616.png"
replot
unset output
set term pop
