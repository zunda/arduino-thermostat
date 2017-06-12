set xdata time
set timefmt "%Y-%m-%d %H:%M:%S"
set style data lines
set format x "%H:%M"
set xlabel "HST"
set ylabel "Temperature (^oC)"
plot \
'20170611.log' using 1:4 tit 'Panel' lt 1,\
'20170611.log' using 1:3 tit 'Tank' lt 2,\
'20170612.log' using 1:4 not lt 2,\
'20170612.log' using 1:3 not lt 1
