#!/bin/bash

for i in $1/*/*/Perf++/BW; do
    cpu=$(echo $i | cut -f3 -d/)
    ben=$(echo $i | cut -f4 -d/)
    cpi=$(echo $i | cut -f1-5 -d/)/Prefetch/data.1.txt
    echo $ben

    foo=$(echo $ben | cut -f1 -d. | head -c 1)
    if [[ $foo -eq 5 ]]; then cpu="CPU2017Rate"; fi
    mkdir -p $2/$cpu/$ben/ > /dev/null 2>&1

    tail -n +2 $cpi > $i/tmp.1.txt

    awk '(NR < 2) {
            printf("%d %d\n", $1, $2);
            pBw = $2; 
        } (NR > 1) {
            bar = $2 - pBw;
            pBw = $2; 
            printf("%d %d\n", $1, bar);
        }' $i/tmp.1.txt > $i/tmp.3.txt

    awk '(NR < 2) {
            printf("%d %f\n", $1, $2);
            pBw = $2; 
        } (NR > 1) {
            bar = $2 - pBw; 
            pIns = $1
            pBw = $2; 
            printf("%d %d\n", $1, bar);
        }' $i/data.1.txt > $i/tmp.2.txt

    in=$i/tmp.txt
    awk '(FNR == NR) {
            a[NR] = $2;
            next;
        } (NR > 1) {
            gb=((a[FNR]*8)/($2*2.2))*1000;
            printf("%d %f\n", $1, gb);
        }' $i/tmp.2.txt $i/tmp.3.txt > $in
    rm $2/$cpu/$ben/data/bw.time.dat
    cp $in $2/$cpu/$ben/data/bw.second.time.dat

    out=$2/$cpu/$ben/data/bw.second.time.100.dat
    rm $out
    awk '{sum += $2} (NR % 100) == 0 {printf("%d %f\n", $1, sum/100); 
        sum = 0;}' $in > $out

    rm $in $i/tmp.1.txt $i/tmp.2.txt $i/tmp.3.txt
done
