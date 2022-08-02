#!/bin/bash

function f {
    # Parameters:
    # $1 -> output file
    # $2 -> png/tex
    # $3 -> output plot file
    # $4 -> ylabel
    # $5 -> title
    # $6 -> data
    # $7 -> data 2
    echo "set terminal unknown" > $1
    echo "plot '$5/speed.dat' pt 7 lc '#808080' notitle, '' u (\$1 + 0.005):(\$2):(stringcolumn(3)) with labels left notitle" >> $1
    echo "set terminal '$2'" >> $1
    echo "set output '$3'" >> $1
    echo "set ylabel 'SpeedUp Pre-búsqueda'" >> $1
    echo "set border lw 5" >> $1
    echo "set xlabel 'SpeedUp Tamaño'" >> $1
    #echo "set title '$5'" >> $1
    echo "unset key" >> $1
    echo "set grid ytics xtics" >> $1
    #echo "set title '$5'" >> $1
    echo "unset key" >> $1
    echo "set grid ytics xtics" >> $1
    echo "set format y '%.0f'" >> $1
    echo "set yrange[1:3.1]" >> $1
    echo "set xrange[1:1.8]" >> $1
    #echo "set key invert reverse Left outside spacing 1.5 box" >> $1
    #echo "set key center bmargin spacing 2.5 horizontal" >> $1
    #echo "unset title" >> $1
    echo "replot" >> $1
}

if [ $# -ne 1 ]
then
    echo "I need the input/output folder (one parameter)"
    exit 1
fi

for i in $1/*
do
    echo $i
    j=$(echo $i | cut -d'/' -f 3)
    f $i/tmp.plot "epslatex color" $i/$j.tex MPKI3 $m $i "mpki"
    gnuplot $i/tmp.plot > /dev/null 2>&1
    rm $i/tmp.plot
done
