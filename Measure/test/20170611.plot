set xdata time
set timefmt "%Y-%m-%d %H:%M:%S"
set style data lines
plot '20170611.log' using 1:3 tit 'Pipe', '20170611.log' using 1:4 tit 'Panel'
