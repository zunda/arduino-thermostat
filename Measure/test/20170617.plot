reset
set style data lines
set xlabel "Relative time (sec)"
set ylabel "Temperature (deg-C)"
set xrange [0:60]
plot \
'20170617-1.log' using (column(0)):3 tit 'Panel on A0 (with 47uF)' lt 1,\
'20170617-2.log' using (column(0)):4 tit 'Panel on A1 (without capacitor)' lt 2

set term push
set term png small
set output '20170617.png'
replot
set nooutput
set term pop
