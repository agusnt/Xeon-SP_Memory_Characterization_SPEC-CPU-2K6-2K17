#!/bin/bash
# $1 input folder (Result)
# $2 output file

function fawk {
    local dummy=$(awk -F "," 'NR > 2 { if ($5 == "instructions" ) instr += $3; 
        else access += $3 } END { printf "%f", (access / (instr / 1000) * 8) }' $1)
    echo "$dummy"
}

echo ";Read;;;;;;Write;;;;;;ALL" > $2
echo -n ";None;DCUI;DCUP;L2A;L2P;ALL;None;DCUI;DCUP;L2A;L2P;ALL;" >> $2
echo "None;DCUI;DCUP;L2A;L2P;ALL;" >> $2

for j in $1/*/*/BW; do
    name=$(echo $j | cut -f4 -d/)
    echo $name
    folder=$(echo $2 | cut -f2 -d/)
    ben=$(echo $j | cut -f3 -d/)
    aux=$(echo $name | head -c 1)

    if [[ $aux -eq 5 ]]; then ben="CPU2017Rate"; fi

    echo -n "$name;">> $2
    
    # Prefetch
    pr=$(fawk $j/RD/Ninguno.txt)
    echo -n "$pr;" >> $2
    pdi=$(fawk $j/RD/Enable_DCUI.txt $2)
    echo -n "$pdi;" >> $2
    pdp=$(fawk $j/RD/Enable_DCUP.txt $2)
    echo -n "$pdp;" >> $2
    pla=$(fawk $j/RD/Enable_L2A.txt $2)
    echo -n "$pla;" >> $2
    plp=$(fawk $j/RD/Enable_L2P.txt $2)
    echo -n "$plp;" >> $2
    pa=$(fawk $j/RD/Todos.txt $2)
    echo -n "$pa;" >> $2

    # No Prefetch
    nr=$(fawk $j/WR/Ninguno.txt $2)
    echo -n "$nr;" >> $2
    ndi=$(fawk $j/WR/Enable_DCUI.txt $2)
    echo -n "$ndi;" >> $2
    ndp=$(fawk $j/WR/Enable_DCUP.txt $2)
    echo -n "$ndp;" >> $2
    nla=$(fawk $j/WR/Enable_L2A.txt $2)
    echo -n "$nla;" >> $2
    nlp=$(fawk $j/WR/Enable_L2P.txt $2)
    echo -n "$nlp;" >> $2
    na=$(fawk $j/WR/Todos.txt $2)
    echo -n "$na;" >> $2

    out="$folder/$ben/$name/data/bw.dat"
    echo "#Type Value" > $out
    # Sum and data file
    dummy=$(echo $pr + $nr | bc)
    echo -n "$dummy;" >> $2
    echo "None $dummy" >> $out
    dummy=$(echo $pdi + $ndi | bc)
    echo -n "$dummy;" >> $2
    echo "DCUI $dummy" >> $out
    dummy=$(echo $pdp + $ndp | bc)
    echo -n "$dummy;" >> $2
    echo "DCUP $dummy" >> $out
    dummy=$(echo $pla + $nla | bc)
    echo -n "$dummy;" >> $2
    echo "L2A $dummy" >> $out
    dummy=$(echo $plp + $nlp | bc)
    echo -n "$dummy;" >> $2
    echo "L2P $dummy" >> $out
    dummy=$(echo $pa + $na | bc)
    echo -n "$dummy;" >> $2
    echo "" >> $2
    echo "All $dummy" >> $out
done

