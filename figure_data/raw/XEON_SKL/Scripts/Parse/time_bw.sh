#!/bin/bash

for i in $1/*/*/Perf++/BW; do
    cpu=$(echo $i | cut -f3 -d/)
    ben=$(echo $i | cut -f4 -d/)
    echo $ben

    foo=$(echo $ben | cut -f1 -d. | head -c 1)
    if [[ $foo -eq 5 ]]; then cpu="CPU2017Rate"; fi
    mkdir -p $2/$cpu/$ben/ > /dev/null 2>&1

    in=$i/tmp.txt
    awk '(NR < 2) {
            printf("%d %f\n", $1, (($2/($1/1000))*8)); 
            pIns = $1
            pBw = $2; 
        } (NR > 1) {
            foo = $1 - pIns; 
            bar = $2 - pBw; 
            pIns = $1
            pBw = $2; 
            printf("%d %f\n", $1, (bar / (foo / 1000)) * 8);
            #printf("%d - %d - %d - %f\n", $1, foo, bar, ((bar/($foo/1000))*8))
        }' $i/data.1.txt > $in
    rm $2/$cpu/$ben/data/bw.time.dat
    cp $in $2/$cpu/$ben/data/bw.time.dat

    out=$2/$cpu/$ben/data/bw.time.100.dat
    rm $out
    awk '{sum += $2} (NR % 100) == 0 {printf("%d %f\n", $1, sum/100); 
        sum = 0;}' $in > $out
   rm $in
done
