#!/bin/bash

function f2 {
    # Parameters:
    # $1 -> output file
    # $2 -> png/tex
    # $3 -> output plot file
    # $4 -> title
    # $5 -> data
    # $6 -> ylabel
    echo "set terminal 'unknown'" > $1
    echo "set datafile separator ';'" >> $1
    echo "plot '$5' u 2:xtic(1) w boxes lt rgb '#8c8c8c' axes x1y1 t 'CPI', '' u 7:xtic(1) w linespoint lt rgb 'black' lw 5 pt 2 pi -1 ps 1.5 axes x1y2 t 'BPKI'" >> $1
    echo "set terminal '$2'" >> $1
    echo "set output '$3'" >> $1
    echo "set boxwidth 0.5" >> $1
    echo "set style fill solid 1" >> $1
    echo "set border lw 5" >> $1
    echo "set xtic rotate 90" >> $1
    echo "set auto x" >> $1
    echo "unset key" >> $1
    echo "set title '$4'" >> $1
    echo "set ylabel 'CPI' offset -.5, 0" >> $1
    echo "set lmargin at screen .1;" >> $1
    echo "set rmargin at screen .87;" >> $1
    echo "set y2label 'BPKI' offset 0,0" >> $1
    #echo "set title '$4'" >> $1
    echo "if (GPVAL_DATA_Y_MAX < 1){" >> $1
        echo "set yrange[0:3]" >> $1
        echo "set ytics 0,1,3" >> $1
        echo "set mytics 2" >> $1
    echo "} else{ " >> $1
        echo "if (GPVAL_DATA_Y_MAX < 5){" >> $1
            echo "set yrange [0:3]" >> $1
            echo "set ytics 0,1,3" >> $1
            echo "set mytics 2" >> $1
        echo "} else{ " >> $1
            echo "if (GPVAL_DATA_Y_MAX < 2){" >> $1
                echo "set yrange [0:2]" >> $1
                echo "set ytics 0,1,2" >> $1
            echo "} else{" >> $1
                echo "if (GPVAL_DATA_Y_MAX < 3){" >> $1
                    echo "set yrange [0:3]" >> $1
                    echo "set ytics 0,1,3" >> $1
                echo "} else{" >> $1
                    echo "if (GPVAL_DATA_Y_MAX < 5){" >> $1
                        echo "set yrange [0:5]" >> $1
                        echo "set ytics 0,1,5" >> $1
                    echo "} else{" >> $1
                        echo "set yrange [0:6]" >> $1
                        echo "set ytics 0,1,6" >> $1                      
                    echo "}" >> $1
                echo "}" >> $1
            echo "}" >> $1
        echo "}" >> $1
    echo "}" >> $1
    # Secon VAL
    echo "if (GPVAL_DATA_Y2_MAX < 100){" >> $1
        echo "set y2range[0:100]" >> $1
        echo "set y2tics 0,100,100" >> $1
    echo "} else{ " >> $1
        echo "if (GPVAL_DATA_Y2_MAX < 500){" >> $1
            echo "set y2range [0:500]" >> $1
            echo "set y2tics 0,100,500" >> $1
        echo "} else{ " >> $1
            echo "if (GPVAL_DATA_Y2_MAX < 1000){" >> $1
                echo "set y2range [0:1000]" >> $1
                echo "set y2tics 0,200,1000" >> $1
            echo "} else{ " >> $1
                    echo "if (GPVAL_DATA_Y2_MAX < 2000){" >> $1
                        echo "set y2range [0:2000]" >> $1
                        echo "set y2tics 0,400,2000" >> $1
                        echo "set my2tics 2" >> $1
                        echo "set grid mytics" >> $1
                    echo "} else{ " >> $1
                        echo "if (GPVAL_DATA_Y2_MAX < 3000){" >> $1
                            echo "set y2range [0:3000]" >> $1
                            echo "set y2tics 0,600,3000" >> $1
                            echo "set my2tics 2" >> $1
                            echo "set grid mytics" >> $1
                        echo "} else{" >> $1
                            echo "if (GPVAL_DATA_Y2_MAX < 4000){" >> $1
                                echo "set y2range [0:4000]" >> $1
                                echo "set y2tics 0,800,4000" >> $1
                                echo "set my2tics 5" >> $1
                                echo "set grid mytics" >> $1
                            echo "} else{" >> $1
                                echo "set y2range [0:6000]" >> $1
                                echo "set y2tics 0,1200,6000" >> $1
                                echo "set my2tics 5" >> $1
                                echo "set grid mytics" >> $1
                            echo "}" >> $1
                    echo "}" >> $1
                echo "}" >> $1
            echo "}" >> $1
        echo "}" >> $1
    echo "}" >> $1
    echo "set grid ytics lt 0" >> $1
    echo "set grid mytics" >> $1
    #echo "set grid y2tics lt 0" >> $1
    #echo "set key center bmargin spacing 2.5 horizontal" >> $1
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
        mkdir -p $j/Plot/Prefetch
        #k=$(echo $j | cut -d'/' -f 3)
        k=$(echo $j | cut -d'/' -f 3 | sed -e 's/_/\\_/g')
        m=$(echo $j | cut -d'/' -f 4 | sed -e 's/_/\\_/g')
        out=$(echo "$j" | cut -d'/' -f4 | cut -d'.' -f1)

        # MPKI
        f2 $j/tmp.plot png $j/Plot/Prefetch/$out.png "$k" $j/data/prefetch.dat
        gnuplot $j/tmp.plot 
        rm $j/tmp.plot

        f2 $j/tmp.plot epslatex $j/Plot/Prefetch/$out.tex "$m" $j/data/prefetch.dat
        gnuplot $j/tmp.plot > /dev/null 2>&1
        rm $j/tmp.plot
    done
done
