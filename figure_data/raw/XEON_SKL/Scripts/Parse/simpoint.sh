#!/bin/bash

ARRAY1=(
"500.perlbench_r" "502.gcc_r" "505.mcf_r" "520.omnetpp_r" "523.xalancbmk_r" "525.x264_r"
"531.deepsjeng_r" "541.leela_r" "548.exchange2_r" "557.xz_r"
"503.bwaves_r" "554.roms_r" "507.cactuBSSN_r" "508.namd_r"
"510.parest_r" "511.povray_r" "519.lbm_r" "521.wrf_r"
"526.blender_r" "527.cam4_r" "538.imagick_r" "544.nab_r" "549.fotonik3d_r"
)

ARRAY2=(
"600.perlbench_s" "602.gcc_s" "605.mcf_s" "620.omnetpp_s"
"623.xalancbmk_s" "625.x264_s" "631.deepsjeng_s" "641.leela_s" "648.exchange2_s"
)

if [ "$#" -ne 2 ]; then
    echo "Wrong number of parameters"
    exit 1
fi

for i in $1/*/*; do
    # Get info
    version=$(echo $i | cut -d'/' -f3)
    version2=$(echo $i | cut -d'/' -f3)
    program=$(echo $i | cut -d'/' -f4)
    program2=$(echo $i | cut -d'/' -f4 | cut -d'.' -f-2)
    if [ $version == "CPU2017" ]; then
        for item in "${ARRAY1[@]}"; do
            [[ $program2 == "$item" ]] && version2="CPU2017Rate"
        done
        for item in "${ARRAY2[@]}"; do
            [[ $program2 == "$item" ]] && version2="CPU2017SSpeed"
        done
    fi

    cd $i

    if [ ! -e simpoint.csv ]; then
        echo $i
        cd ../../../
        continue
    fi

    # Sed over the simpoint file
    sed 's/#.*//g' simpoint.csv | sed '/^\s*$/d' | sed 's/cluster [0-9] from slice //g' | sed 's/,/ /g' | sort -n -k 6 > tmp.csv

    # Go to root folder
    cd ../../../

    # Move file
    mv $1/$version/$program/tmp.csv $2/$version2/$program/data/simpoint.csv
done
