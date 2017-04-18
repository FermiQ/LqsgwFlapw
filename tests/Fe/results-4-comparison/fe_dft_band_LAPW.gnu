 set loadpath "C:/P4Win/Gnuplot/gnuplot/bin/share/PostScript/"
 set terminal postscript "fontsize" 26
 set output "fe_lda_bnd_LAPW.eps"
set data style lines
set nokey
set xrange [0: 5.14626]
set yrange [-13.60535 :  8.16321]
set arrow from  1.00000, -13.60535 to  1.00000,   8.16321 nohead
set arrow from  1.86603, -13.60535 to  1.86603,   8.16321 nohead
set arrow from  2.73205, -13.60535 to  2.73205,   8.16321 nohead
set arrow from  3.43916, -13.60535 to  3.43916,   8.16321 nohead
set arrow from  3.93916, -13.60535 to  3.93916,   8.16321 nohead
set arrow from  4.43916, -13.60535 to  4.43916,   8.16321 nohead
set xtics (" G "  0.00000," H "  1.00000," P "  1.86603," G "  2.73205," N "  3.43916," P "  3.93916," N "  4.43916," H "  5.14626)
 plot "fe_dft_band_LAPW.dat" with lines lw 3 lt 1 lc 1
 unset output
 unset terminal
 unset loadpath
