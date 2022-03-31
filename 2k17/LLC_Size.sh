#!/bin/bash

################################################################################
# This script run all SPEC CP2017 benchmarks with their reference inputs and
# get eight metrics about their execution with different sizes of LLC.
#  
# The eight metrics are:
# - LLC-load-misses
# - LLC-load
# - LLC-store-misses
# - LLC-store
# - Instructions Retired
# - Cycles executed
#
# You need the msr-tools and intel-cmt-cat package. This program is prepared to 
# run on an Intel processor.
#
# BE CAREFUL: This program reset Hardware Prefetching and Intel RDT
# configurations
#
# @Author: agusnt@unizar.es (http://webdiis.unizar.es/~/agusnt)
################################################################################

################################################################################
# Global variables, change them according to your workstation
################################################################################
# Modify this to the benchmarks path
SOURCE=$(pwd)
BIN="$SOURCE/bin" # Integer benchmarks
RES="$SOURCE/result/2k17/" # Where save the result?
REP=1 # Number of repeat the proofs

################################################################################
# Benchmarks and inputs declarations
################################################################################
declare -A BENCH
BENCH=(
# Rate Benchmarks
["500.perlbench_r.1"]="./perlbench_r -I./lib checkspam.pl 2500 5 25 11 150 1 1 1 1"
["500.perlbench_r.2"]="./perlbench_r -I./lib diffmail.pl 4 800 10 17 19 300"
["500.perlbench_r.3"]="./perlbench_r -I./lib splitmail.pl 6400 12 26 16 100 0"
["502.gcc_r.1"]="./cpugcc_r gcc-pp.c -O3 -finline-limit=0 -fif-conversion -fif-conversion2 -o file"
["502.gcc_r.2"]="./cpugcc_r gcc-pp.c -O2 -finline-limit=36000 -fpic -o file"
["502.gcc_r.3"]="./cpugcc_r gcc-smaller.c -O3 -fipa-pta -o f"
["502.gcc_r.4"]="./cpugcc_r ref32.c -O5 -o f"
["502.gcc_r.5"]="./cpugcc_r ref32.c -O3 -fselective-scheduling -fselective-scheduling2 -o f"
["503.bwaves_r.1"]="./bwaves_r"
["503.bwaves_r.2"]="./bwaves_r"
["503.bwaves_r.3"]="./bwaves_r"
["503.bwaves_r.4"]="./bwaves_r"
["505.mcf_r.1"]="./mcf_r inp.in"
["507.cactuBSSN_r.1"]="./cactusBSSN_r spec_ref.par"
["508.namd_r.1"]="./namd_r --input apoa1.input --output apoa1.ref.output --iterations 65 "
["520.omnetpp_r.1"]="./omnetpp_r -c General -r 0"
["510.parest_r.1"]="./parest_r ref.prm"
["511.povray_r.1"]="./povray_r SPEC-benchmark-ref.ini"
["519.lbm_r.1"]="./lbm_r 3000 reference.dat 0 0 100_100_130_ldc.of"
["521.wrf_r.1"]="./wrf_r"
["523.xalancbmk_r.1"]="./cpuxalan_r -v t5.xml xalanc.xsl"
["525.x264_r.1"]="./x264_r --pass 1 --stats x264_stats.log --bitrate 1000 --frames 1000 -o BuckBunny_New.264 BuckBunny.yuv 1280x720"
["525.x264_r.2"]="./x264_r --pass 2 --stats x264_stats.log --bitrate 1000 --dumpyuv 200 --frames 1000 -o BuckBunny_New.264 BuckBunny.yuv 1280x720"
["525.x264_r.3"]="./x264_r --seek 500 --dumpyuv 200 --frames 1250 -o BuckBunny_New.264 BuckBunny.yuv 1280x720"
["526.blender_r.1"]="./blender_r sh3_no_char.blend --render-output sh3_no_char_ --threads 1 -b -F RAWTGA -s 849 -e 849 -a"
["527.cam4_r.1"]="./cam4_r"
["531.deepsjeng_r.1"]="./deepsjeng_r ref.txt"
["538.imagick_r.1"]="./imagick_r -limit disk 0 refrate_input.tga -edge 41 -resample 181% -emboss 31 -colorspace YUV -mean-shift 19x19+15% -resize 30% refrate_output.tga"
["541.leela_r.1"]="./leela_r ref.sgf"
["544.nab_r.1"]="./nab_r 1am0 1122214447 122"
["548.exchange2_r.1"]="./exchange2_r 6"
["549.fotonik3d_r.1"]="./fotonik3d_r"
["557.xz_r.1"]="./xz_r cld.tar.xz 160 19cf30ae51eddcbefda78dd06014b4b96281456e078ca7c13e1c0c9e6aaea8dff3efb4ad6b0456697718cede6bd5454852652806a657bb56e07d61128434b474 59796407 61004416 6"
["557.xz_r.2"]="./xz_r cpu2006docs.tar.xz 250 055ce243071129412e9dd0b3b69a21654033a9b723d874b2015c774fac1553d9713be561ca86f74e4f16f22e664fc17a79f30caa5ad2c04fbc447549c2810fae 23047774 23513385 6e"
["557.xz_r.3"]="./xz_r input.combined.xz 250 a841f68f38572a49d86226b7ff5baeb31bd19dc637a922a972b2e6d1257a890f6a544ecab967c313e370478c74f760eb229d4eef8a8d2836d233d3e9dd1430bf 40401484 41217675 7"
["554.roms_r.1"]="./roms_r"
#Speed
["600.perlbench_s.1"]="./perlbench_s -I./lib checkspam.pl 2500 5 25 11 150 1 1 1 1"
["600.perlbench_s.2"]="./perlbench_s -I./lib diffmail.pl 4 800 10 17 19 300"
["600.perlbench_s.3"]="./perlbench_s -I./lib splitmail.pl 1600 12 26 16 4500"
["602.gcc_s.1"]="./sgcc gcc-pp.c -O5 -fipa-pta"
["602.gcc_s.2"]="./sgcc gcc-pp.c -O5 -finline-limit=1000 -fselective-scheduling -fselective-scheduling2"
["602.gcc_s.3"]="./sgcc gcc-pp.c -O5 -finline-limit=24000 -fgcse -fgcse-las -fgcse-lm -fgcse-sm"
["605.mcf_s.1"]="./mcf_s inp.in"
["620.omnetpp_s.1"]="./omnetpp_s -c General -r 0"
["623.xalancbmk_s.1"]="./xalancbmk_s -v t5.xml xalanc.xsl"
["625.x264_s.1"]="./ldecod_s -i BuckBunny.264 -o BuckBunny.yuv"
["625.x264_s.2"]="./x264_s --pass 1 --stats x264_stats.log --bitrate 1000 --frames 1000 -o BuckBunny_New.264 BuckBunny.yuv 1280x720"
["625.x264_s.3"]="./x264_s --pass 1 --stats x264_stats.log --bitrate 1000 --frames 1000 -o BuckBunny_New.264 BuckBunny.yuv 1280x720"
["625.x264_s.4"]="./x264_s --pass 1 --stats x264_stats.log --bitrate 1000 --frames 1000 -o BuckBunny_New.264 BuckBunny.yuv 1280x720"
["631.deepsjeng_s.1"]="./deepsjeng_s ref.txt"
["641.leela_s.1"]="./leela_s ref.sgf"
["648.exchange2_s.1"]="./exchange2_s 6 "
["657.xz_s.1"]="./xz_s cpu2006docs.tar.xz 6643 055ce243071129412e9dd0b3b69a21654033a9b723d874b2015c774fac1553d9713be561ca86f74e4f16f22e664fc17a79f30caa5ad2c04fbc447549c2810fae 1036078272 1111795472 4"
["657.xz_s.2"]="./xz_s cld.tar.xz 1400 19cf30ae51eddcbefda78dd06014b4b96281456e078ca7c13e1c0c9e6aaea8dff3efb4ad6b0456697718cede6bd5454852652806a657bb56e07d61128434b474 536995164 539938872 8"
)

# Standard input for the benchmarks
declare -A INP
INP=(
["503.bwaves_r.1"]="bwaves_1.in"
["503.bwaves_r.2"]="bwaves_2.in"
["503.bwaves_r.3"]="bwaves_3.in"
["503.bwaves_r.4"]="bwaves_4.in"
["554.roms_r.1"]="ocean_benchmark2.in.x"
["603.bwaves_s.1"]="bwaves_1.in"
["603.bwaves_s.2"]="bwaves_2.in"
["654.roms_s.1"]="ocean_benchmark3.in.x"
)


################################################################################
# Below here is the actual body (and brain) of the shell script
################################################################################

# Restrict LLC ways with Intel CAT (pqos)
# You need to run it as administrator (you need intel-cmt-cat package)
pqos -e "llc:1=0x0001;llc:2=0x0003;llc:3=0x000f;llc:4=0x00ff" > /dev/null 2>&1
pqos -a "llc:1=0" > /dev/null 2>&1

# Enable all hardware prefetchers
wrmsr -p $CORE 0x1a4 0x0 > /dev/null 2>&1

# Iterate over the benchmarks
for i in "${!BENCH[@]}"
do 
    dummy=${i::-2} # Remove last two characters
    echo -n "$i: "

    cd $BIN/$dummy # Move to the benchmarks folder
    out="$RES/$i/Asoc/Prefetch/"
    mkdir -p $out

    # We iterate from Mask 0 to Mask 4 on Intel CAT.
    # Mask 0 on Intel CAT is always set to all ways enable
    for j in {0..4}
    do
        # Set the LLC Mask
        pqos -a "llc:$j=$CORE" > /dev/null 2>&1

        if [ -z ${INP[$i]} ]; then
            perf stat -r $REP --field-separator=, -e LLC-load -e LLC-load-misses -e cycles -e instructions -o $out/way.$j.load.txt -- taskset -c $CORE ${BENCH[$i]} > /dev/null 2>&1 
            perf stat -r $REP --field-separator=, -e LLC-store -e LLC-store-misses -e cycles -e instructions -o $out/way.$j.store.txt -- taskset -c $CORE ${BENCH[$i]} > /dev/null 2>&1 
        else        
            perf stat -r $REP --field-separator=, -e LLC-load -e LLC-load-misses -e cycles -e instructions -o $out/way.$j.load.txt -- taskset -c $CORE ${BENCH[$i]} < ${INP[$i]} > /dev/null 2>&1
            perf stat -r $REP --field-separator=, -e LLC-store -e LLC-store-misses -e cycles -e instructions -o $out/way.$j.store.txt -- taskset -c $CORE ${BENCH[$i]} < ${INP[$i]} > /dev/null 2>&1
        fi
    done

    echo "OK"
    cd $SOURCE
done

# Disable all hardware prefetchers
wrmsr -p $CORE 0x1a4 0xf > /dev/null 2>&1

# Iterate over the benchmarks
for i in "${!BENCH[@]}"
do 
    dummy=${i::-2} # Remove last two characters
    echo -n "$i: "

    cd $BIN/$dummy # Move to the benchmarks folder
    out="$RES/$i/Asoc/No_Prefetch/"
    mkdir -p $out

    # We iterate from Mask 0 to Mask 4 on Intel CAT.
    # Mask 0 on Intel CAT is always set to all ways enable
    for j in {0..4}
    do
        # Set the LLC Mask
        pqos -a "llc:$j=$CORE" > /dev/null 2>&1

        if [ -z ${INP[$i]} ]; then
            perf stat -r $REP --field-separator=, -e LLC-load -e LLC-load-misses -e cycles -e instructions -o $out/way.$j.load.txt -- taskset -c $CORE ${BENCH[$i]} > /dev/null 2>&1 
            perf stat -r $REP --field-separator=, -e LLC-store -e LLC-store-misses -e cycles -e instructions -o $out/way.$j.store.txt -- taskset -c $CORE ${BENCH[$i]} > /dev/null 2>&1 
        else        
            perf stat -r $REP --field-separator=, -e LLC-load -e LLC-load-misses -e cycles -e instructions -o $out/way.$j.load.txt -- taskset -c $CORE ${BENCH[$i]} < ${INP[$i]} > /dev/null 2>&1
            perf stat -r $REP --field-separator=, -e LLC-store -e LLC-store-misses -e cycles -e instructions -o $out/way.$j.store.txt -- taskset -c $CORE ${BENCH[$i]} < ${INP[$i]} > /dev/null 2>&1
        fi
    done

    echo "OK"
    cd $SOURCE
done

# Reset ALL Intel CAT Mask and configurations
pqos -R > /dev/null 2>&1
# Enable all Hardware prefetchers
wrmsr -p $CORE 0x1a4 0x0 > /dev/null 2>&1
