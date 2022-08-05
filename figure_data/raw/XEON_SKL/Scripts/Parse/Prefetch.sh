#!/bin/bash

function f(){
    wr=$(awk -F "," '(NR > 3) {acum = prev + acum} 
        {prev = $1} END {print acum}' $1)
    rd=$(awk -F "," '(NR > 3) {acum = prev + acum} 
        {prev = $1} END {print acum}' $2)
    cat $3 $4 > dummy.txt
    awk -F "," 'BEGIN {access = 0; miss = 0; cycles = 0; inst = 0} 
            {
                if($3 == "LLC-load" || $3 == "LLC-store")
                {
                    access = access + $1
                } 
                else if($3 == "LLC-load-misses" || $3 == "LLC-store-misses")
                {
                    miss = miss + $1
                } 
                else if ($3 == "cycles")
                {
                    cycles = $1
                } 
                else if ($3 == "instructions")
                {
                    inst = $1
                }
            } 
            END {
                print access; print miss; print cycles; print inst
            }' dummy.txt > dummy_2.txt

}

function f2(){
    access=$(cat dummy_2.txt | head -n 1)
    misses=$(cat dummy_2.txt | head -n 2 | tail -n 1)
    cycles=$(cat dummy_2.txt | head -n 3 | tail -n 1)
    instrs=$(cat dummy_2.txt | head -n 4 | tail -n 1)
}

# Create summary csv
dcui=$2/dcui.csv
dcup=$2/dcup.csv
l2a=$2/l2a.csv
l2p=$2/l2p.csv
todos=$2/todos.csv
ninguno=$2/ninguno.csv

echo "Benchmark;CPI;MPKI2;MPKI3;BPKI_Read;BPKI_Write;BPKI_Total" > $dcui
echo "Benchmark;CPI;MPKI2;MPKI3;BPKI_Read;BPKI_Write;BPKI_Total" > $dcup
echo "Benchmark;CPI;MPKI2;MPKI3;BPKI_Read;BPKI_Write;BPKI_Total" > $l2p
echo "Benchmark;CPI;MPKI2;MPKI3;BPKI_Read;BPKI_Write;BPKI_Total" > $l2a
echo "Benchmark;CPI;MPKI2;MPKI3;BPKI_Read;BPKI_Write;BPKI_Total" > $ninguno
echo "Benchmark;CPI;MPKI2;MPKI3;BPKI_Read;BPKI_Write;BPKI_Total" > $todos

dir=$(pwd)
for i in $1/*; do
    for j in $i/*; do
        # Get name and spec
        spec=$(echo $j | cut -f2 -d/)
        benc=$(echo $j | cut -f3 -d/)
        echo $benc
        if [[ $spec == "CPU2017" ]]; then
            spec="CPU2017Rate"
        fi
        # Get complete path
        aux=$j/Prefetch/
        # Output file
        out=$2/$spec/$benc/data/prefetch.dat
        # Initialize prefetch
        echo "#Prefetch;CPI;MPKI2;MPKI3;BPKI_Read;BPKI_Write;BPKI_Total" > $out

        # Iterate over files inside the directory
        cd $aux
        f Ninguno.bw.wr.txt Ninguno.bw.rd.txt Ninguno.store.txt Ninguno.load.txt
        f2
        cd $dir
        cpi=$(bc <<< "scale=9;$cycles/$instrs")
        ins=$(bc <<< "scale=9;$instrs/1000")
        mp2=$(bc <<< "scale=9;$access/$ins")
        mp3=$(bc <<< "scale=9;$misses/$ins")
        brd=$(bc <<< "scale=9;($rd*64)/$ins")
        bwr=$(bc <<< "scale=9;($wr*64)/$ins")
        bbt=$(bc <<< "scale=9;($brd+$bwr)")
        echo "$benc;$cpi;$mp2;$mp3;$brd;$bwr;$bbt" >> $ninguno
        echo "Ninguno;$cpi;$mp2;$mp3;$brd;$bwr;$bbt" >> $out
        cd $aux
        f Enable_DCUI.bw.wr.txt Enable_DCUI.bw.rd.txt Enable_DCUI.store.txt Enable_DCUI.load.txt
        f2
        cd $dir
        cpi=$(bc <<< "scale=9;$cycles/$instrs")
        ins=$(bc <<< "scale=9;$instrs/1000")
        mp2=$(bc <<< "scale=9;$access/$ins")
        mp3=$(bc <<< "scale=9;$misses/$ins")
        brd=$(bc <<< "scale=9;($rd*64)/$ins")
        bwr=$(bc <<< "scale=9;($wr*64)/$ins")
        bbt=$(bc <<< "scale=9;($brd+$bwr)")
        echo "$benc;$cpi;$mp2;$mp3;$brd;$bwr;$bbt" >> $dcui
        echo "DCUI;$cpi;$mp2;$mp3;$brd;$bwr;$bbt" >> $out
        cd $aux
        f Enable_DCUP.bw.wr.txt Enable_DCUP.bw.rd.txt Enable_DCUP.store.txt Enable_DCUP.load.txt
        f2
        cd $dir
        cpi=$(bc <<< "scale=9;$cycles/$instrs")
        ins=$(bc <<< "scale=9;$instrs/1000")
        mp2=$(bc <<< "scale=9;$access/$ins")
        mp3=$(bc <<< "scale=9;$misses/$ins")
        brd=$(bc <<< "scale=9;($rd*64)/$ins")
        bwr=$(bc <<< "scale=9;($wr*64)/$ins")
        bbt=$(bc <<< "scale=9;($brd+$bwr)")
        echo "$benc;$cpi;$mp2;$mp3;$brd;$bwr;$bbt" >> $dcup
        echo "DCUP;$cpi;$mp2;$mp3;$brd;$bwr;$bbt" >> $out
        cd $aux
        f Enable_L2A.bw.wr.txt Enable_L2A.bw.rd.txt Enable_L2A.store.txt Enable_L2A.load.txt
        f2
        cd $dir
        cpi=$(bc <<< "scale=9;$cycles/$instrs")
        ins=$(bc <<< "scale=9;$instrs/1000")
        mp2=$(bc <<< "scale=9;$access/$ins")
        mp3=$(bc <<< "scale=9;$misses/$ins")
        brd=$(bc <<< "scale=9;($rd*64)/$ins")
        bwr=$(bc <<< "scale=9;($wr*64)/$ins")
        bbt=$(bc <<< "scale=9;($brd+$bwr)")
        echo "$benc;$cpi;$mp2;$mp3;$brd;$bwr;$bbt" >> $l2a
        echo "L2A;$cpi;$mp2;$mp3;$brd;$bwr;$bbt" >> $out
        cd $aux
        f Enable_L2P.bw.wr.txt Enable_L2P.bw.rd.txt Enable_L2P.store.txt Enable_L2P.load.txt
        f2
        cd $dir
        cpi=$(bc <<< "scale=9;$cycles/$instrs")
        ins=$(bc <<< "scale=9;$instrs/1000")
        mp2=$(bc <<< "scale=9;$access/$ins")
        mp3=$(bc <<< "scale=9;$misses/$ins")
        brd=$(bc <<< "scale=9;($rd*64)/$ins")
        bwr=$(bc <<< "scale=9;($wr*64)/$ins")
        bbt=$(bc <<< "scale=9;($brd+$bwr)")
        echo "$benc;$cpi;$mp2;$mp3;$brd;$bwr;$bbt" >> $l2p
        echo "L2P;$cpi;$mp2;$mp3;$brd;$bwr;$bbt" >> $out
        cd $aux
        f Todos.bw.wr.txt Todos.bw.rd.txt Todos.store.txt Todos.load.txt
        f2
        cd $dir
        cpi=$(bc <<< "scale=9;$cycles/$instrs")
        ins=$(bc <<< "scale=9;$instrs/1000")
        mp2=$(bc <<< "scale=9;$access/$ins")
        mp3=$(bc <<< "scale=9;$misses/$ins")
        brd=$(bc <<< "scale=9;($rd*64)/$ins")
        bwr=$(bc <<< "scale=9;($wr*64)/$ins")
        bbt=$(bc <<< "scale=9;($brd+$bwr)")
        echo "$benc;$cpi;$mp2;$mp3;$brd;$bwr;$bbt" >> $todos
        echo "Todos;$cpi;$mp2;$mp3;$brd;$bwr;$bbt" >> $out
        cd $dir
    done
done
