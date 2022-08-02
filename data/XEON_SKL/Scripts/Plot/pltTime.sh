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
    echo "plot '$6' using (\$1/$9):$7 with lines ls 1" >> $1
    echo "set terminal '$2'" >> $1
    echo "set output '$3'" >> $1
    echo "set style line 1 lc rgb 'black' lt 1 lw 2 pt 7 ps 1.5" >> $1
    echo "set ylabel '$4'" >> $1
    echo "set xlabel 'Instructions (${10})'" >> $1
    echo "set mxtics 2" >> $1
    echo "set mytics 2" >> $1
    echo "set title '$5'" >> $1
    echo "unset key" >> $1
    echo "set grid ytics xtics lc rgb '#bbbbbb' lw 1 lt 0" >> $1
    # Get information from simpoint
    echo "if (GPVAL_DATA_Y_MAX < 1){" >> $1
        echo "set yrange [0:1]" >> $1
        echo "set ytics 0,1,1" >> $1
    echo "} else {" >> $1
        echo "if (GPVAL_DATA_Y_MAX < 10){" >> $1
            echo "set yrange [0:10]" >> $1
            echo "set ytics 0,1,10" >> $1
            echo "set mytics 2" >> $1
        echo "} else {" >> $1
            echo "if (GPVAL_DATA_Y_MAX < 30){" >> $1
                echo "set yrange [0:30]" >> $1
                echo "set ytics 0,5,30" >> $1
                echo "set mytics 5" >> $1       
            echo "} else {" >> $1
                echo "if (GPVAL_DATA_Y_MAX < 60){" >> $1
                    echo "set yrange [0:60]" >> $1
                    echo "set ytics 0,10,60" >> $1
                    echo "set mytics 10" >> $1     
                echo "} else {" >> $1
                    echo "set yrange [0:80]" >> $1
                    echo "set ytics 0,20,80" >> $1
                    echo "set mytics 20" >> $1
                echo "}" >> $1
           echo "}" >> $1
       echo "}" >> $1
    echo "}" >> $1
    #echo "set ytics GPVAL_DATA_Y_MIN,1,GPVAL_DATA_Y_MAX" >> $1
    #echo "set xrange [GPVAL_DATA_X_MIN:GPVAL_DATA_X_MAX+1]" >> $1
    echo "set xrange [GPVAL_DATA_X_MIN:GPVAL_DATA_X_MAX]" >> $1
    echo "set format y '%.0f'" >> $1
    echo "replot" >> $1
}

function f2 {
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
    echo "plot '$6' using (\$1/$9):$7 with lines ls 1" >> $1
    echo "set terminal '$2'" >> $1
    echo "set output '$3'" >> $1
    echo "set style line 1 lc rgb 'black' lt 1 lw 2 pt 7 ps 1.5" >> $1
    echo "set ylabel '$4'" >> $1
    echo "set xlabel 'Instructions (${10})'" >> $1
    echo "set mxtics 2" >> $1
    echo "set mytics 2" >> $1
    echo "set title '$5'" >> $1
    echo "unset key" >> $1
    echo "set grid ytics xtics lc rgb '#bbbbbb' lw 1 lt 0" >> $1
    # Get information from simpoint
    #echo "A="`head -n1 $8 | cut -d' ' -f4`"" >> $1
    echo "A="`bc -l <<< \"\`head -n1 $8 | cut -d' ' -f4\`/$9\"`"" >> $1
    echo "D="`bc -l <<< \"\`head -n1 $8 | cut -d' ' -f5\`/$9\"`"" >> $1
    echo "B="`bc -l <<< \"\`head -n2 $8 | tail -n1 | cut -d' ' -f4\`/$9\"`"" >> $1
    echo "E="`bc -l <<< \"\`head -n2 $8 | tail -n1 | cut -d' ' -f5\`/$9\"`"" >> $1
    echo "C="`bc -l <<< \"\`head -n3 $8 | tail -n1 | cut -d' ' -f4\`/$9\"`"" >> $1
    echo "F="`bc -l <<< \"\`head -n4 $8 | tail -n1 | cut -d' ' -f5\`/$9\"`"" >> $1
    #echo "D="`head -n1 $8 | cut -d' ' -f5`"" >> $1
    #echo "B="`head -n2 $8 | tail -n1 | cut -d' ' -f4`"" >> $1
    #echo "E="`head -n2 $8 | tail -n1 | cut -d' ' -f5`"" >> $1
    #echo "C="`head -n3 $8 | tail -n1 | cut -d' ' -f4`"" >> $1
    #echo "F="`head -n3 $8 | tail -n1 | cut -d' ' -f5`"" >> $1
    echo "set style line 3 lt 3 dashtype 3" >> $1
    echo "if (GPVAL_DATA_X_MIN > A){" >> $1
        echo "A=GPVAL_DATA_X_MIN" >> $1
    echo "}" >> $1
    echo "if (GPVAL_DATA_X_MIN > B){" >> $1
        echo "B=GPVAL_DATA_X_MIN" >> $1
    echo "}" >> $1
    echo "if (GPVAL_DATA_X_MIN > C){" >> $1
        echo "C=GPVAL_DATA_X_MIN" >> $1
    echo "}" >> $1
    echo "if (GPVAL_DATA_X_MIN > D){" >> $1
        echo "D=GPVAL_DATA_X_MIN" >> $1
    echo "}" >> $1
    echo "if (GPVAL_DATA_X_MIN > E){" >> $1
        echo "E=GPVAL_DATA_X_MIN" >> $1
    echo "}" >> $1
    echo "if (GPVAL_DATA_X_MIN > F){" >> $1
        echo "F=GPVAL_DATA_X_MIN" >> $1
    echo "}" >> $1
    echo "if (GPVAL_DATA_Y_MAX < 1){" >> $1
        echo "set yrange [0:1]" >> $1
        echo "set ytics 0,1,1" >> $1
        echo "set arrow 1 from A, 0 to D, 1 nohead lw 3.5 dt 3 lc rgb '#000000'" >> $1
        echo "set arrow 2 from B, 0 to E, 1 nohead lw 3.5 dt (15,6) lc rgb '#000000'" >> $1
        echo "set arrow 3 from C, 0 to F, 1 nohead lw 3.5 lc rgb '#000000'" >> $1
    echo "} else {" >> $1
        echo "if (GPVAL_DATA_Y_MAX < 10){" >> $1
            echo "set yrange [0:10]" >> $1
            echo "set ytics 0,1,10" >> $1
            echo "set mytics 2" >> $1
            echo "set arrow 1 from A, 0 to D, 10 nohead lw 3.5 dt 3 lc rgb '#000000'" >> $1
            echo "set arrow 2 from B, 0 to E, 10 nohead lw 3.5 dt (15,6) lc rgb '#000000'" >> $1
            echo "set arrow 3 from C, 0 to F, 10 nohead lw 3.5 lc rgb '#000000'" >> $1
        echo "} else {" >> $1
            echo "if (GPVAL_DATA_Y_MAX < 30){" >> $1
                echo "set yrange [0:30]" >> $1
                echo "set ytics 0,5,30" >> $1
                echo "set mytics 5" >> $1       
                echo "set arrow 1 from A, 0 to D, 30 nohead lw 3.5 dt 3 lc rgb '#000000'" >> $1
                echo "set arrow 2 from B, 0 to E, 30 nohead lw 3.5 dt (15,6) lc rgb '#000000'" >> $1
                echo "set arrow 3 from C, 0 to F, 30 nohead lw 3.5 lc rgb '#000000'" >> $1
            echo "} else {" >> $1
                echo "if (GPVAL_DATA_Y_MAX < 60){" >> $1
                    echo "set yrange [0:60]" >> $1
                    echo "set ytics 0,10,60" >> $1
                    echo "set mytics 10" >> $1     
                    echo "set arrow 1 from A, 0 to D, 60 nohead lw 3.5 dt 3 lc rgb '#000000'" >> $1
                    echo "set arrow 2 from B, 0 to E, 60 nohead lw 3.5 dt (15,6) lc rgb '#000000'" >> $1
                    echo "set arrow 3 from C, 0 to F, 60 nohead lw 3.5 lc rgb '#000000'" >> $1
                echo "} else {" >> $1
                    echo "set yrange [0:80]" >> $1
                    echo "set ytics 0,20,80" >> $1
                    echo "set mytics 20" >> $1
                    echo "set arrow 1 from A, 0 to D, 80 nohead lw 3.5 dt 3 lc rgb '#000000'" >> $1
                    echo "set arrow 2 from B, 0 to E, 80 nohead lw 3.5 dt (15,6) lc rgb '#000000'" >> $1
                    echo "set arrow 3 from C, 0 to F, 80 nohead lw 3.5 lc rgb '#000000'" >> $1
                echo "}" >> $1
           echo "}" >> $1
       echo "}" >> $1
    echo "}" >> $1
    #echo "set ytics GPVAL_DATA_Y_MIN,1,GPVAL_DATA_Y_MAX" >> $1
    #echo "set xrange [GPVAL_DATA_X_MIN:GPVAL_DATA_X_MAX+1]" >> $1
    echo "set xrange [GPVAL_DATA_X_MIN:GPVAL_DATA_X_MAX]" >> $1
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
        mkdir -p $j/Plot/time
        name=$(echo "$j" | cut -d'/' -f3 | sed -e 's/_/\\_/g')
        m=$(echo $j | cut -d'/' -f 4 | sed -e 's/_/\\_/g')

        l=$(echo $m | cut -d'.' -f 1)

        if [ -f "$j/data/simpoint.csv" ]; then
            f=f2
        else
            f=f1
        fi

        if [ "$name" == "CPU2006" ]; then
            div=100000000000
            ti="x10^{11}"
            te="\$x10^{11}\$"
        else
            div=1000000000000
            ti="x10^{12}"
            te="\$x10^{12}\$"
        fi

        # CPI
        #$f $j/tmp.plot 'pngcairo dashed size 600,20' $j/Plot/png/cpi.time.Perf++.100.png CPI $m $j/data/time.100.Perf++.dat 2 $j/data/simpoint.csv $div $ti
        #gnuplot $j/tmp.plot > /dev/null 2>&1
        #rm $j/tmp.plot

        #$f $j/tmp.plot "epslatex color" $j/Plot/tex/cpi.time.Perf++.100.tex CPI $m $j/data/time.100.Perf++.dat 2 $j/data/simpoint.csv $div $te
        #gnuplot $j/tmp.plot > /dev/null 2>&1
        #rm $j/tmp.plot
        # APKI
        #$f $j/tmp.plot 'pngcairo dashed size 600,30' $j/Plot/png/apki.time.Perf++.100.png APKI $m $j/data/time.100.Perf++.dat 3 $j/data/simpoint.csv $div $ti
        #gnuplot $j/tmp.plot > /dev/null 2>&1
        #rm $j/tmp.plot

        #$f $j/tmp.plot "epslatex color" $j/Plot/tex/apki.time.Perf++.100.tex APKI $m $j/data/time.100.Perf++.dat 3 $j/data/simpoint.csv $div $te
        #gnuplot $j/tmp.plot > /dev/null 2>&1
        #rm $j/tmp.plot

        # MPKI
        $f $j/tmp.plot epslatex $j/Plot/time/$l.tex MPKI3 $m $j/data/time.100.Perf++.dat 4 $j/data/simpoint.csv $div $te
        gnuplot $j/tmp.plot > /dev/null 2>&1
        rm $j/tmp.plot
        
        
    done
done
