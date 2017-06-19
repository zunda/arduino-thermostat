set xdata time
set timefmt "%Y-%m-%d %H:%M:%S"
set style data lines
set format x "%H:%M"
set xlabel "HST"
set ylabel "Temperature (deg-C)"
plot \
'20170618.log' using 1:3 tit 'Panel' lt 1,\
'20170618.log' using 1:4 tit 'Tank' lt 2

set term push
set term png small
set output '20170618.png'
replot
set nooutput
set term pop
