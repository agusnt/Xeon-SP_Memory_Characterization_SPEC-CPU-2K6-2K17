#!/bin/bash

function contains() {
    local n=$#
    local value=${!n}
    for ((i=1;i < $#;i++)) {
        if [ "${!i}" == "${value}" ]; then
            echo "y"
            return 0
        fi
    }
    echo "n"
    return 1
}

function f1 {
    # Parameters:
    # $1 -> output file
    # $2 -> png/tex
    # $3 -> output plot file
    # $4 -> directory
    # $5 -> title
    echo $6
    echo $7
    echo "set terminal unknown" > $1
    echo "set style line 2 lc rgb 'black' lt 1 lw 2 pt 2 pi -1 ps 1.5" >> $1
    echo "set style line 1 lc rgb '#696969' lt 1 lw 2 pt 5 ps 1.5" >> $1
    echo "set style line 3 lc rgb '#b3b3b3' lt 1 lw 2 pt 5 ps 1.5" >> $1
    #echo -n "plot '< paste $4/data/prefetch_cpi.dat $4/data/prefetch_mpki.dat' u 4:2 ls 1 title 'Con Pre-búsqueda'" >> $1
    #echo ",'< paste $4/data/no_prefetch_cpi.dat $4/data/no_prefetch_mpki.dat' u 4:2 ls 2 title 'Sin pre-búsqueda'" >> $1
    echo "f(x) = m * x + c" >> $1
    echo "fit f(x) '$4/data/merge.dat' u 4:2 via m,c" >> $1
    echo "set key title sprintf(\"Pendiente: %.2f\", m)" >> $1
    echo -n "plot '< paste $4/data/asoc.cpi.no_prefetch.dat $4/data/asoc.mpki.no_prefetch.dat' u 4:2 ls 2 title 'Sin pre-búsqueda'" >> $1
    echo -n ",'< paste $4/data/asoc.cpi.prefetch.dat $4/data/asoc.mpki.prefetch.dat' u 4:2 ls 1 title 'Con Pre-búsqueda'" >> $1
    echo ", f(x) with lines ls 3 notitle">> $1
    echo "set terminal '$2'" >> $1
    echo "set output '$3'" >> $1
    echo "set ylabel 'CPI'" >> $1
    echo "set xlabel 'MPKI'" >> $1
    #echo "set title '$5'" >> $1
    echo "unset key" >> $1
    echo "unset key" >> $1
    echo "set grid ytics xtics" >> $1
    echo "set format y '%.0f'" >> $1
    echo "set key center bmargin spacing 2.5 horizontal" >> $1
    echo "set xrange[0:$7]" >> $1
    echo "set xrange[0:$76]" >> $1
    echo "replot" >> $1
}

if [ $# -ne 1 ]
then
    echo "I need the input/output folder (one parameter)"
    exit 1
fi

A=("502.gcc_r.5" "505.mcf_r.1" "519.lbm_r.1" "549.fotonik3d_r.1")
B=("521.wrf_r.1" "523.xalancbmk_r.1" "557.xz_r.1" "507.cactuBSSN_r.1" "510.parest_r.1" "520.omnetpp_r.1" "554.roms_r.1")
C=("500.perlbench_r.3" "525.x264_r.1" "526.blender_r.1" "527.cam4_r.1" "503.bwaves_r.3")

for i in $1/*
do
    for j in $i/*
    do
        mkdir -p $j/Plot/Scatter
        name=$(echo "$j" | cut -d'/' -f4 )
        

        # Create a merge file
        paste -d" " $j/data/asoc.cpi.prefetch.dat $j/data/asoc.mpki.prefetch.dat | tail -n +2 > $j/data/tmp2.tmp
        paste -d" " $j/data/asoc.cpi.no_prefetch.dat $j/data/asoc.mpki.no_prefetch.dat | tail -n +2 > $j/data/tmp1.tmp
        cat $j/data/tmp1.tmp $j/data/tmp2.tmp > $j/data/merge.dat

        if [ $(contains "${A[@]}" "$name") == "y" ]; then
            a=3
            b=30
        elif [ $(contains "${B[@]}" "$name") == "y" ]; then
            a=2
            b=20
        elif [ $(contains "${C[@]}" "$name") == "y" ]; then
            a=1
            b=10
        else
            rm $j/data/tmp1.tmp $j/data/tmp2.tmp $j/data/merge.dat
            continue
        fi
        #f1 $j/tmp.plot png $j/Plot/png/scatter.combined.png $j $name $a $b
        #gnuplot $j/tmp.plot > /dev/null 2>&1
        #rm $j/tmp.plot

        f1 $j/tmp.plot "epslatex color" $j/Plot/Scatter/scatter.combined.tex $j $name $a $b
        gnuplot $j/tmp.plot > /dev/null 2>&1
        rm $j/tmp.plot

        rm $j/data/tmp1.tmp $j/data/tmp2.tmp $j/data/merge.dat
    done
done

rm fit.log
