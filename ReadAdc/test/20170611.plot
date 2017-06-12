reset
set style data linespoints
set xlabel "Pin voltage (V)"
set ylabel "Output - ideal (ADU)"
set key bottom right
set yrange [-40:30]
plot \
"20170611.A0-103.log" us 2:($1-1024*$2/4.91) tit "4.91V-4.61k-A0-10Kmax-GND",\
"20170611.A1-103.log" us 2:($1-1024*$2/4.91) tit "4.91V-4.67k-A1-10Kmax-GND"
set term push
set term png small size 480,360
set output "20170611.png"
replot
unset output
set term pop
