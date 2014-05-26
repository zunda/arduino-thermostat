# http://en.wikipedia.org/wiki/Thermistor#Steinhart.E2.80.93Hart_equation
t(r)=1/(a+b*log(r)+c*(log(r)**3))-273.16
a=1.4e-3
b=2.37e-4
c=9.9e-8
fit t(x) "resistance-vs-temperature.dat" using 1:2 via a,b,c

#Final set of parameters            Asymptotic Standard Error
#=======================            ==========================
#
#a               = 0.00112974       +/- 1.089e-07    (0.009643%)
#b               = 0.00023399       +/- 2.012e-08    (0.0086%)
#c               = 8.8342e-08       +/- 9.727e-11    (0.1101%)

set term png
set output "resistance-vs-temperature.png"
set log x
set style data lines
set xlabel "Resistance (Ohm)"
set ylabel "Temperature (C)"
plot "resistance-vs-temperature.dat" using 1:2 tit "SAS-10",\
t(x) tit "Fit"
unset output
