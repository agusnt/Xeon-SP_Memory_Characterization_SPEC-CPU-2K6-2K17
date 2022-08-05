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
    echo -n "plot '$6/asoc.$7.no_prefetch.dat' u 2:xtic(1) with linespoints ls 1 t" >> $1
    echo -n "'Without Prefetch', '$6/asoc.$7.prefetch.dat' u 2:xtic(1) with " >> $1
    echo "linespoints ls 2 t 'With Prefetch'" >> $1
    echo "set terminal '$2'" >> $1
    echo "set output '$3'" >> $1
    echo "set style line 1 lc rgb 'black' lt 1 lw 5 pt 2 pi -1 ps 1.5" >> $1
    echo "set style line 2 lc rgb '#8c8c8c' lt 1 lw 5 pt 5 ps 1.5" >> $1
    echo "set ylabel 'MPKI3'" >> $1
    echo "set border lw 5" >> $1
    echo "set lmargin at screen .1;" >> $1
    echo "set rmargin at screen .9;" >> $1
    echo "set xlabel 'LLC (MB)'" >> $1
    echo "set title '$5'" >> $1
    echo "unset key" >> $1
    echo "set grid ytics xtics" >> $1
    echo "if (GPVAL_DATA_Y_MAX < 5){" >> $1
        echo "set yrange [0:5]" >> $1
        echo "set ytics 0,1,5" >> $1
    echo "} else{ " >> $1
        echo "if (GPVAL_DATA_Y_MAX < 10){" >> $1
            echo "set yrange [0:10]" >> $1
            echo "set ytics 0,1,10" >> $1
        echo "} else{ " >> $1
            echo "if (GPVAL_DATA_Y_MAX < 30){" >> $1
                echo "set yrange [0:30]" >> $1
                echo "set ytics 0,5,30" >> $1
                echo "set mytics 5" >> $1
                echo "set grid mytics" >> $1
            echo "} else{" >> $1
                echo "set yrange [0:71]" >> $1
                    echo "set ytics 0,10,71" >> $1
                    echo "set mytics 10" >> $1
                    echo "set grid mytics" >> $1
            echo "}" >> $1
        echo "}" >> $1
    echo "}" >> $1
    echo "set format y '%.0f'" >> $1
    #echo "set key invert reverse Left outside spacing 1.5 box" >> $1
    #echo "set key center bmargin spacing 2.5 horizontal" >> $1
    #echo "unset title" >> $1
    echo "replot" >> $1
}

function f1 {
    # Parameters:
    # $1 -> output file
    # $2 -> png/tex
    # $3 -> output plot file
    # $4 -> ylabel
    # $5 -> title
    # $6 -> data
    # $7 -> data 2
    echo "set terminal unknown" > $1
    echo -n "plot '$6/asoc.$7.no_prefetch.dat' u 2:xtic(1) with linespoints ls 1 t" >> $1
    echo -n "'Without Prefetch', '$6/asoc.$7.prefetch.dat' u 2:xtic(1) with " >> $1
    echo "linespoints ls 2 t 'With Prefetch'" >> $1
    echo "set terminal '$2'" >> $1
    echo "set output '$3'" >> $1
    echo "set style line 1 lc rgb 'black' lt 1 lw 5 pt 2 pi -1 ps 1.5" >> $1
    echo "set style line 2 lc rgb '#8c8c8c' lt 1 lw 5 pt 5 ps 1.5" >> $1
    echo "set ylabel 'CPI'" >> $1
    echo "set border lw 5" >> $1
    echo "set lmargin at screen .1;" >> $1
    echo "set rmargin at screen .9;" >> $1
    echo "set xlabel 'LLC (MB)'" >> $1
    echo "set title '$5'" >> $1
    echo "unset key" >> $1
    echo "set grid ytics xtics" >> $1
    echo "if (GPVAL_DATA_Y_MAX < 1){" >> $1
        echo "set yrange[0:1]" >> $1
        echo "set ytics 0,1,1" >> $1
        echo "set mytics 4" >> $1
        echo "set grid mytics" >> $1
    echo "} else{ " >> $1
        echo "if (GPVAL_DATA_Y_MAX < 2){" >> $1
            echo "set yrange [0:2]" >> $1
            echo "set ytics 0,1,2" >> $1
            echo "set mytics 4" >> $1
            echo "set grid mytics" >> $1
        echo "} else{ " >> $1
            echo "if (GPVAL_DATA_Y_MAX < 3){" >> $1
                echo "set yrange [0:3]" >> $1
                echo "set ytics 0,1,3" >> $1
                echo "set mytics 4" >> $1
                echo "set grid mytics" >> $1
            echo "} else{" >> $1
                echo "set yrange [0:9]" >> $1
                echo "set ytics 0,1,9" >> $1
                echo "set mytics 4" >> $1
                echo "set grid mytics" >> $1
            echo "}" >> $1
        echo "}" >> $1
    echo "}" >> $1

    echo "set format y '%.0f'" >> $1
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
    for j in $i/*
    do
        mkdir -p $j/Plot/Asoc
        name=$(echo "$j" | cut -d'/' -f4 | sed -e 's/_/\\_/g')
        m=$(echo $j | cut -d'/' -f 4 | sed -e 's/_/\\_/g')
        out=$(echo "$j" | cut -d'/' -f4 | cut -d'.' -f1)

        # CPI
        #f1 $j/tmp.plot png $j/Plot/Asoc/$out.png CPI $name $j/data "cpi"
        #gnuplot $j/tmp.plot > /dev/null 2>&1
        #rm $j/tmp.plot

        f1 $j/tmp.plot "png" $j/Plot/Asoc/cpi.png CPI $name $j/data "cpi"
        gnuplot $j/tmp.plot > /dev/null 2>&1
        rm $j/tmp.plot

        # MPKI
        f $j/tmp.plot png $j/Plot/Asoc/$out.png MPKI $name $j/data "mpki"
        gnuplot $j/tmp.plot > /dev/null 2>&1
        rm $j/tmp.plot

        #f $j/tmp.plot "epslatex color" $j/Plot/Asoc/$out.tex MPKI3 $m $j/data "mpki"
        #gnuplot $j/tmp.plot > /dev/null 2>&1
        #rm $j/tmp.plot
    done
done
