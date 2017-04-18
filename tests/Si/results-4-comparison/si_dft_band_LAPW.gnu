 set loadpath "C:/P4Win/Gnuplot/gnuplot/bin/share/PostScript/"
 set terminal postscript "fontsize" 26
 set output "si_lda_bnd_LAPW.eps"
set data style lines
set nokey
set xrange [0: 6.59739]
set yrange [ -4.08160 :  4.08160]
set arrow from  1.00000,  -4.08160 to  1.00000,   4.08160 nohead
set arrow from  1.50000,  -4.08160 to  1.50000,   4.08160 nohead
set arrow from  2.20711,  -4.08160 to  2.20711,   4.08160 nohead
set arrow from  3.07313,  -4.08160 to  3.07313,   4.08160 nohead
set arrow from  4.13379,  -4.08160 to  4.13379,   4.08160 nohead
set arrow from  4.92436,  -4.08160 to  4.92436,   4.08160 nohead
set arrow from  5.27792,  -4.08160 to  5.27792,   4.08160 nohead
set arrow from  5.63147,  -4.08160 to  5.63147,   4.08160 nohead
set arrow from  5.98502,  -4.08160 to  5.98502,   4.08160 nohead
set xtics (" G "  0.00000," X "  1.00000," W "  1.50000," L "  2.20711," G "  3.07313," K "  4.13379," X "  4.92436," U "  5.27792," W "  5.63147," K "  5.98502," L "  6.59739)
 plot "si_dft_band_LAPW.dat" with lines lw 3 lt 1 lc 1
 unset output
 unset terminal
 unset loadpath
