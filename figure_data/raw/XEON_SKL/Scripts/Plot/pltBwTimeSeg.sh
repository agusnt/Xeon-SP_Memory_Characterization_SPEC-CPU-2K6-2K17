#!/bin/bash

function f1 {
    # Parameters:
    # $1 -> output file
    # $2 -> png/tex
    # $3 -> output plot file
    # $4 -> ylabel
    # $5 -> title
    # $6 -> data
    # $7 -> column to plot
    # $8 -> simpoint files
    # $9 -> labelx
    # $10 -> div title
    echo "set terminal unknown" > $1
    echo "plot '$6' using (\$1/$8):2 with lines ls 1" >> $1
    echo "set terminal '$2'" >> $1
    echo "set output '$3'" >> $1
    echo "set style line 1 lc rgb 'black' lt 1 lw 2 pt 7 ps 1.5" >> $1
    echo "set ylabel '$4'" >> $1
    echo "set xlabel 'Instrucciones (${9})'" >> $1
    echo "set mxtics 2" >> $1
    echo "set mytics 2" >> $1
    echo "set title '$5'" >> $1
    echo "unset key" >> $1
    echo "set grid ytics xtics lc rgb '#bbbbbb' lw 1 lt 0" >> $1
    # Get information from simpoint
    echo "set grid ytics, xtics lw 1.5 lc 'black'" >> $1
    echo "set border lw 1.5" >> $1
    echo "set xrange [GPVAL_DATA_X_MIN:GPVAL_DATA_X_MAX]" >> $1
    echo "set yrange [0:500]" >> $1
    echo "set ytics 0,50,500" >> $1
    echo "set format y '%.0f'" >> $1
    echo "replot" >> $1
}

if [ $# -ne 1 ]
then
    echo "I need the input/output folder (one parameter)"
    exit 1
fi

for i in $1/*
do
    for j in $i/*
    do
        mkdir -p $j/Plot/MBs/ 
        name=$(echo "$j" | cut -d'/' -f3 | sed -e 's/_/\\_/g')
        m=$(echo $j | cut -d'/' -f 4 | sed -e 's/_/\\_/g')
        l=$(echo $m | cut -d'.' -f 1)

        if [ "$name" == "CPU2006" ]; then
            div=100000000000
            ti="x10^{11}"
            te="\$x10^{11}\$"
        else
            div=1000000000000
            ti="x10^{12}"
            te="\$x10^{12}\$"
        fi

        # MPKI
        f1 $j/tmp.plot "png" $j/Plot/MBs/$l.png MB/s $m $j/data/bw.second.time.100.dat 4 $div $ti
        gnuplot $j/tmp.plot 
        rm $j/tmp.plot
    done
done
