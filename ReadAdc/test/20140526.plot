set xdata time
set timefmt "%Y-%m-%d %H:%M:%S"
set format x "%H:%M"
r(adu, r) = r * adu / (1023 - adu)
t(r) = 1/(a+b*log(r)+c*(log(r)**3)) - 273.16
a=0.00112974
b=0.00023399
c=8.8342e-08
set style data lines
set xlabel "HST"
set ylabel "Temperature (C)"
plot "20140526.log" using 1:(t(r($4, 4650))) tit "Panel",\
     "20140526.log" using 1:(t(r($3, 4610))) tit "Tank"
