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
    echo -n "plot '$6/bw.no_prefetch.dat' u 2:xtic(1) with linespoints ls 1 t" >> $1
    echo -n "'Without Prefetch', '$6/bw.prefetch.dat' u 2:xtic(1) with " >> $1
    echo "linespoints ls 2 t 'With Prefetch'" >> $1
    echo "set terminal '$2'" >> $1
    echo "set output '$3'" >> $1
    echo "set style line 1 lc rgb 'black' lt 1 lw 5 pt 2 pi -1 ps 1.5" >> $1
    echo "set style line 2 lc rgb '#8c8c8c' lt 1 lw 5 pt 5 ps 1.5" >> $1
    echo "set ylabel 'BPKI'" >> $1
    echo "set border lw 5" >> $1
    #echo "set lmargin at screen .1;" >> $1
    #echo "set rmargin at screen .9;" >> $1
    echo "set xlabel 'LLC (MB)'" >> $1
    echo "set title '$5'" >> $1
    echo "unset key" >> $1
    echo "set grid ytics xtics" >> $1
    echo "if (GPVAL_DATA_Y_MAX < 500){" >> $1
        echo "set yrange [0:500]" >> $1
        echo "set ytics 0,100,500" >> $1
    echo "} else{ " >> $1
        echo "if (GPVAL_DATA_Y_MAX < 1000){" >> $1
            echo "set yrange [0:1000]" >> $1
            echo "set ytics 0,100,1000" >> $1
        echo "} else{ " >> $1
            echo "if (GPVAL_DATA_Y_MAX < 2000){" >> $1
                echo "set yrange [0:2000]" >> $1
                echo "set ytics 0,200,2000" >> $1
                echo "set mytics 2" >> $1
                echo "set grid mytics" >> $1
            echo "} else{" >> $1
                echo "if (GPVAL_DATA_Y_MAX < 3000){" >> $1
                    echo "set yrange [0:3000]" >> $1
                    echo "set ytics 0,200,3000" >> $1
                    echo "set mytics 2" >> $1
                    echo "set grid mytics" >> $1
                echo "} else{" >> $1
                    echo "if (GPVAL_DATA_Y_MAX < 4000){" >> $1
                    echo "set yrange [0:4000]" >> $1
                    echo "set ytics 0,400,4000" >> $1
                    echo "set mytics 4" >> $1
                    echo "set grid mytics" >> $1
                    echo "} else{" >> $1
                        echo "set yrange [0:6000]" >> $1
                        echo "set ytics 0,600,6000" >> $1
                        echo "set mytics 6" >> $1
                        echo "set grid mytics" >> $1
                    echo "}" >> $1
                echo "}" >> $1
            echo "}" >> $1
        echo "}" >> $1
    echo "}" >> $1
    echo "set ylabel 'BPKI'" >> $1
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
    echo -n "plot '$6/bw.no_prefetch.dat' u 3:xtic(1) with linespoints ls 1 t" >> $1
    echo -n "'Without Prefetch', '$6/bw.prefetch.dat' u 3:xtic(1) with " >> $1
    echo "linespoints ls 2 t 'With Prefetch'" >> $1
    echo "set terminal '$2'" >> $1
    echo "set output '$3'" >> $1
    echo "set style line 1 lc rgb 'black' lt 1 lw 5 pt 2 pi -1 ps 1.5" >> $1
    echo "set style line 2 lc rgb '#8c8c8c' lt 1 lw 5 pt 5 ps 1.5" >> $1
    echo "set ylabel 'Gb/s'" >> $1
    echo "set border lw 5" >> $1
    #echo "set lmargin at screen .1;" >> $1
    #echo "set rmargin at screen .9;" >> $1
    echo "set xlabel 'LLC (MB)'" >> $1
    echo "set title '$5'" >> $1
    echo "unset key" >> $1
    echo "set grid ytics xtics" >> $1
    echo "if (GPVAL_DATA_Y_MAX < 1){" >> $1
        echo "set yrange [0:1]" >> $1
        echo "set ytics 0,.5,1" >> $1
    echo "} else{ " >> $1
        echo "if (GPVAL_DATA_Y_MAX < 3){" >> $1
            echo "set yrange [0:3]" >> $1
            echo "set ytics 0,.5,3" >> $1
        echo "} else{ " >> $1
            echo "if (GPVAL_DATA_Y_MAX < 6){" >> $1
                echo "set yrange [0:6]" >> $1
                echo "set ytics 0,1,6" >> $1
                echo "set mytics 2" >> $1
                echo "set grid mytics" >> $1
            echo "} else{" >> $1
                echo "if (GPVAL_DATA_Y_MAX < 10){" >> $1
                    echo "set yrange [0:10]" >> $1
                    echo "set ytics 0,1,10" >> $1
                    echo "set mytics 2" >> $1
                    echo "set grid mytics" >> $1
                echo "} else{" >> $1
                    echo "if (GPVAL_DATA_Y_MAX < 12){" >> $1
                    echo "set yrange [0:12]" >> $1
                    echo "set ytics 0,1,12" >> $1
                    echo "set mytics 2" >> $1
                    echo "set grid mytics" >> $1
                    echo "} else{" >> $1
                        echo "set yrange [0:13]" >> $1
                        echo "set ytics 0,1,13" >> $1
                        echo "set mytics 2" >> $1
                        echo "set grid mytics" >> $1
                    echo "}" >> $1
                echo "}" >> $1
            echo "}" >> $1
        echo "}" >> $1
    echo "}" >> $1
    echo "set ylabel 'Gb/s'" >> $1
    echo "set format y '%.2f'" >> $1
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
        mkdir -p $j/Plot/BW_Barrido/
        name=$(echo "$j" | cut -d'/' -f3 | sed -e 's/_/\\_/g')
        m=$(echo $j | cut -d'/' -f 4 | sed -e 's/_/\\_/g')
        out=$(echo "$j" | cut -d'/' -f4 | cut -d'.' -f1)

        # BPKI
        f $j/tmp.plot png $j/Plot/BW_Barrido/bpki.png BPKI $name $j/data "BPKI"
        gnuplot $j/tmp.plot  > /dev/null 2>&1
        rm $j/tmp.plot

        #f $j/tmp.plot "epslatex color" $j/Plot/Asoc/$out.tex MPKI3 $m $j/data "mpki"
        #gnuplot $j/tmp.plot > /dev/null 2>&1
        #rm $j/tmp.plot

        # GB/S
        f1 $j/tmp.plot png $j/Plot/BW_Barrido/gbs.png GB/s $name $j/data "Gbs"
        gnuplot $j/tmp.plot  > /dev/null 2>&1
        rm $j/tmp.plot
    done
done
