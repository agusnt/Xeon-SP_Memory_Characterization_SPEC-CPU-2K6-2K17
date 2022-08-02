#!/bin/bash

function f()
{
    local foo=$(awk -F',' '(NR > 2) {
        if ($3 != "instructions"){
            sum = sum + $1
        }
    } END {
        print sum
    }' $1)
    echo $foo
}

for i in $1/*/*; do
    bench=$(echo $i | cut -d'/' -f3)
    version=$(echo $i | cut -d'/' -f2)
    if [ $version == "CPU2017" ]; then
        version="CPU2017Rate"
    else
        continue
    fi
    out=$2/$version/$bench/data/bw.prefetch.dat
    echo "#Size BPKI GB/s" > $out

    inst=$(cat $i/Asoc/Prefetch/way.1_4.load.txt | tail -n 1 | cut -d',' -f1)
    cycles=$(cat $i/Asoc/Prefetch/way.1_4.load.txt | tail -n 2 | head -n 1 | cut -d',' -f1)
    bar=$(f "$i/Barrido_Prefetch/all.1_4.bw.rd.txt")
    foo=$(f "$i/Barrido_Prefetch/all.1_4.bw.wr.txt")
    bw=$(($bar + $foo))
    bw=$(bc <<< "scale=8; $bw / 2")
    bw=$(bc <<<"scale=8; $bw * 64")
    bpki=$(bc <<< "scale=8; $bw / ($inst / 1000)")
    gbs=$(bc <<< "scale=8; $bw / ($cycles * 2.2)")
    echo "0.43MB $bpki $gbs" >> $out

    inst=$(cat $i/Asoc/Prefetch/way.1_2.load.txt | tail -n 1 | cut -d',' -f1)
    cycles=$(cat $i/Asoc/Prefetch/way.1_2.load.txt | tail -n 2 | head -n 1 | cut -d',' -f1)
    bar=$(f "$i/Barrido_Prefetch/all.1_2.bw.rd.txt")
    foo=$(f "$i/Barrido_Prefetch/all.1_2.bw.wr.txt")
    bw=$(($bar + $foo))
    bw=$(bc <<< "scale=8; $bw / 2")
    bw=$(bc <<<"scale=8; $bw * 64")
    bpki=$(bc <<< "scale=8; $bw / ($inst / 1000)")
    gbs=$(bc <<< "scale=8; $bw / ($cycles * 2.2)")
    echo "0.87MB $bpki $gbs" >> $out

    inst=$(cat $i/Asoc/Prefetch/way.1.load.txt | tail -n 1 | cut -d',' -f1)
    cycles=$(cat $i/Asoc/Prefetch/way.1.load.txt | tail -n 2 | head -n 1 | cut -d',' -f1)
    bar=$(f "$i/Barrido_Prefetch/all.1.bw.rd.txt")
    foo=$(f "$i/Barrido_Prefetch/all.1.bw.wr.txt")
    bw=$(($bar + $foo))
    bw=$(($bw * 64))
    bpki=$(bc <<< "scale=8; $bw / ($inst / 1000)")
    gbs=$(bc <<< "scale=8; $bw / ($cycles * 2.2)")
    echo "1.75MB $bpki $gbs" >> $out

    inst=$(cat $i/Asoc/Prefetch/way.2.load.txt | tail -n 1 | cut -d',' -f1)
    cycles=$(cat $i/Asoc/Prefetch/way.2.load.txt | tail -n 2 | head -n 1 | cut -d',' -f1)
    bar=$(f "$i/Barrido_Prefetch/all.2.bw.rd.txt")
    foo=$(f "$i/Barrido_Prefetch/all.2.bw.wr.txt")
    bw=$(($bar + $foo))
    bw=$(($bw * 64))
    bpki=$(bc <<< "scale=8; $bw / ($inst / 1000)")
    gbs=$(bc <<< "scale=8; $bw / ($cycles * 2.2)")
    echo "3.5MB $bpki $gbs" >> $out

    inst=$(cat $i/Asoc/Prefetch/way.3.load.txt | tail -n 1 | cut -d',' -f1)
    cycles=$(cat $i/Asoc/Prefetch/way.3.load.txt | tail -n 2 | head -n 1 | cut -d',' -f1)
    bar=$(f "$i/Barrido_Prefetch/all.3.bw.rd.txt")
    foo=$(f "$i/Barrido_Prefetch/all.3.bw.wr.txt")
    bw=$(($bar + $foo))
    bw=$(($bw * 64))
    bpki=$(bc <<< "scale=8; $bw / ($inst / 1000)")
    gbs=$(bc <<< "scale=8; $bw / ($cycles * 2.2)")
    echo "7MB $bpki $gbs" >> $out

    inst=$(cat $i/Asoc/Prefetch/way.4.load.txt | tail -n 1 | cut -d',' -f1)
    cycles=$(cat $i/Asoc/Prefetch/way.4.load.txt | tail -n 2 | head -n 1 | cut -d',' -f1)
    bar=$(f "$i/Barrido_Prefetch/all.4.bw.rd.txt")
    foo=$(f "$i/Barrido_Prefetch/all.4.bw.wr.txt")
    bw=$(($bar + $foo))
    bw=$(($bw * 64))
    bpki=$(bc <<< "scale=8; $bw / ($inst / 1000)")
    gbs=$(bc <<< "scale=8; $bw / ($cycles * 2.2)")
    echo "14MB $bpki $gbs" >> $out

    inst=$(cat $i/Asoc/Prefetch/way.0.load.txt | tail -n 1 | cut -d',' -f1)
    cycles=$(cat $i/Asoc/Prefetch/way.0.load.txt | tail -n 2 | head -n 1 | cut -d',' -f1)
    bar=$(f "$i/Barrido_Prefetch/all.5.bw.rd.txt")
    foo=$(f "$i/Barrido_Prefetch/all.5.bw.wr.txt")
    bw=$(($bar + $foo))
    bw=$(($bw * 64))
    bpki=$(bc <<< "scale=8; $bw / ($inst / 1000)")
    gbs=$(bc <<< "scale=8; $bw / ($cycles * 2.2)")
    echo "19.25MB $bpki $gbs" >> $out

    out=$2/$version/$bench/data/bw.no_prefetch.dat
    echo "#Size BPKI GB/s" > $out

    inst=$(cat $i/Asoc/No_Prefetch/way.1_4.load.txt | tail -n 1 | cut -d',' -f1)
    cycles=$(cat $i/Asoc/No_Prefetch/way.1_4.load.txt | tail -n 2 | head -n 1 | cut -d',' -f1)
    bar=$(f "$i/Barrido_Prefetch/none.1_4.bw.rd.txt")
    foo=$(f "$i/Barrido_Prefetch/none.1_4.bw.wr.txt")
    bw=$(($bar + $foo))
    bw=$(bc <<< "scale=8; $bw / 2")
    bw=$(bc <<<"scale=8; $bw * 64")
    bpki=$(bc <<< "scale=8; $bw / ($inst / 1000)")
    gbs=$(bc <<< "scale=8; $bw / ($cycles * 2.2)")
    echo "0.43MB $bpki $gbs" >> $out

    inst=$(cat $i/Asoc/No_Prefetch/way.1_2.load.txt | tail -n 1 | cut -d',' -f1)
    cycles=$(cat $i/Asoc/No_Prefetch/way.1_2.load.txt | tail -n 2 | head -n 1 | cut -d',' -f1)
    bar=$(f "$i/Barrido_Prefetch/none.1_2.bw.rd.txt")
    foo=$(f "$i/Barrido_Prefetch/none.1_2.bw.wr.txt")
    bw=$(($bar + $foo))
    bw=$(bc <<< "scale=8; $bw / 2")
    bw=$(bc <<<"scale=8; $bw * 64")
    bpki=$(bc <<< "scale=8; $bw / ($inst / 1000)")
    gbs=$(bc <<< "scale=8; $bw / ($cycles * 2.2)")
    echo "0.87MB $bpki $gbs" >> $out

    inst=$(cat $i/Asoc/No_Prefetch/way.1.load.txt | tail -n 1 | cut -d',' -f1)
    cycles=$(cat $i/Asoc/No_Prefetch/way.1.load.txt | tail -n 2 | head -n 1 | cut -d',' -f1)
    bar=$(f "$i/Barrido_Prefetch/none.1.bw.rd.txt")
    foo=$(f "$i/Barrido_Prefetch/none.1.bw.wr.txt")
    bw=$(($bar + $foo))
    bw=$(($bw * 64))
    bpki=$(bc <<< "scale=8; $bw / ($inst / 1000)")
    gbs=$(bc <<< "scale=8; $bw / ($cycles * 2.2)")
    echo "1.75MB $bpki $gbs" >> $out

    inst=$(cat $i/Asoc/No_Prefetch/way.2.load.txt | tail -n 1 | cut -d',' -f1)
    cycles=$(cat $i/Asoc/No_Prefetch/way.2.load.txt | tail -n 2 | head -n 1 | cut -d',' -f1)
    bar=$(f "$i/Barrido_Prefetch/none.2.bw.rd.txt")
    foo=$(f "$i/Barrido_Prefetch/none.2.bw.wr.txt")
    bw=$(($bar + $foo))
    bw=$(($bw * 64))
    bpki=$(bc <<< "scale=8; $bw / ($inst / 1000)")
    gbs=$(bc <<< "scale=8; $bw / ($cycles * 2.2)")
    echo "3.5MB $bpki $gbs" >> $out

    inst=$(cat $i/Asoc/No_Prefetch/way.3.load.txt | tail -n 1 | cut -d',' -f1)
    cycles=$(cat $i/Asoc/No_Prefetch/way.3.load.txt | tail -n 2 | head -n 1 | cut -d',' -f1)
    bar=$(f "$i/Barrido_Prefetch/none.3.bw.rd.txt")
    foo=$(f "$i/Barrido_Prefetch/none.3.bw.wr.txt")
    bw=$(($bar + $foo))
    bw=$(($bw * 64))
    bpki=$(bc <<< "scale=8; $bw / ($inst / 1000)")
    gbs=$(bc <<< "scale=8; $bw / ($cycles * 2.2)")
    echo "7MB $bpki $gbs" >> $out

    inst=$(cat $i/Asoc/No_Prefetch/way.4.load.txt | tail -n 1 | cut -d',' -f1)
    cycles=$(cat $i/Asoc/No_Prefetch/way.4.load.txt | tail -n 2 | head -n 1 | cut -d',' -f1)
    bar=$(f "$i/Barrido_Prefetch/none.4.bw.rd.txt")
    foo=$(f "$i/Barrido_Prefetch/none.4.bw.wr.txt")
    bw=$(($bar + $foo))
    bw=$(($bw * 64))
    bpki=$(bc <<< "scale=8; $bw / ($inst / 1000)")
    gbs=$(bc <<< "scale=8; $bw / ($cycles * 2.2)")
    echo "14MB $bpki $gbs" >> $out

    inst=$(cat $i/Asoc/No_Prefetch/way.0.load.txt | tail -n 1 | cut -d',' -f1)
    cycles=$(cat $i/Asoc/No_Prefetch/way.0.load.txt | tail -n 2 | head -n 1 | cut -d',' -f1)
    bar=$(f "$i/Barrido_Prefetch/none.5.bw.rd.txt")
    foo=$(f "$i/Barrido_Prefetch/none.5.bw.wr.txt")
    bw=$(($bar + $foo))
    bw=$(($bw * 64))
    bpki=$(bc <<< "scale=8; $bw / ($inst / 1000)")
    gbs=$(bc <<< "scale=8; $bw / ($cycles * 2.2)")
    echo "19.25MB $bpki $gbs" >> $out

done
