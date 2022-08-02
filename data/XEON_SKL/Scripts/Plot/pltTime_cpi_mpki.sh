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
    echo "stats '$6'" >> $1
    echo "f(x) = m * x + c" >> $1
    echo "fit f(x) '${11}' u 4:2 via m, c" >> $1
    echo "plot '$6' using (\$1/$9):((\$2 - c) / \$4) with lines ls 1 notitle">> $1
    echo "set terminal '$2'" >> $1
    echo "set output '$3'" >> $1
    echo "set style line 1 lc rgb 'black' lt 1 lw 2 pt 7 ps 1.5" >> $1
    echo "set ylabel '$4'" >> $1
    echo "set xlabel 'Instrucciones (${10})'" >> $1
    echo "set mxtics 2" >> $1
    echo "set title '$5'" >> $1
    echo "unset key" >> $1
    echo "set grid ytics xtics lc rgb '#bbbbbb' lw 1 lt 0" >> $1
    #echo "set key title sprintf(\"Pendiente: %.2f\", c)" >> $1
    # Get information from simpoint
    echo "set xrange [GPVAL_DATA_X_MIN:GPVAL_DATA_X_MAX]" >> $1
    echo "set yrange [-0.30:0.30]" >> $1
    echo "set ytics -0.30,.1,0.30" >> $1
    echo "set key right inside horiz" >> $1
    echo "set format y '%.2f'" >> $1
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
        mkdir -p $j/Plot/time
        name=$(echo "$j" | cut -d'/' -f4 | sed -e 's/_/\\_/g')
        echo $name

        if [ "$name" == "CPU2006" ]; then
            div=100000000000
            ti="x10^{11}"
            te="\$x10^{11}\$"
        else
            div=1000000000000
            ti="x10^{12}"
            te="\$x10^{12}\$"
        fi

        ##########################################################################
        ## Every 1
        ##########################################################################

        # CPI
        #awk '{ if ($4 > 0.0000000000000000001){ div = $2 / $4; print $1, div } }' $j/data/time.Perf++.dat > $j/data/tmp.dat
        #f1 $j/tmp.plot 'pngcairo dashed size 600,20' $j/Plot/png/cpi.mpki.time.Perf++.png CPI-MPKI $name $j/data/tmp.dat 2 $j/data/simpoint.csv $div $ti
        #gnuplot $j/tmp.plot > /dev/null 2>&1
        #rm $j/tmp.plot

        #f1 $j/tmp.plot "epslatex color" $j/Plot/time/cpi.mpki.tex CPI-MPKI $name $j/data/tmp.dat 2 $j/data/simpoint.csv $div $te
        #gnuplot $j/tmp.plot > /dev/null 2>&1
        #rm $j/tmp.plot $j/data/tmp.dat

        ##########################################################################
        ## Every 100
        ##########################################################################
        paste -d" " $j/data/asoc.cpi.prefetch.dat $j/data/asoc.mpki.prefetch.dat | tail -n +2 > $j/data/tmp2.tmp
        paste -d" " $j/data/asoc.cpi.no_prefetch.dat $j/data/asoc.mpki.no_prefetch.dat | tail -n +2 > $j/data/tmp1.tmp
        cat $j/data/tmp1.tmp $j/data/tmp2.tmp > $j/data/merge.dat

        # CPI
        #awk '{ if ($4 > 0.0000000000000000001){ div = $2 / $4; print $1, div } }' $j/data/time.100.Perf++.dat > $j/data/tmp.dat
        f1 $j/tmp.plot 'pngcairo dashed size 600,20' $j/Plot/time/cpi.mpki.time.100.png CPI-MPKI $name $j/data/time.100.Perf++.dat 2 $j/data/simpoint.csv $div $ti $j/data/merge.dat
        gnuplot $j/tmp.plot> /dev/null 2>&1
        rm $j/tmp.plot

        f1 $j/tmp.plot 'epslatex color' $j/Plot/time/cpi.mpki.time.100.tex CPI-MPKI $name $j/data/time.100.Perf++.dat 2 $j/data/simpoint.csv $div $ti $j/data/merge.dat
        gnuplot $j/tmp.plot > /dev/null 2>&1
        rm $j/tmp.plot $j/data/tmp.dat        
        echo $name
    done
done
