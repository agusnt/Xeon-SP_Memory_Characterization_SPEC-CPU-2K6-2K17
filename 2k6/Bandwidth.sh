#!/bin/bash

################################################################################
# This script run all SPEC CP2006 benchmarks with their reference inputs and 
# measure their bandwidth consumption.
#
# You need the perf-tools package. This program is prepared to run on an Intel
# Xeon Skylake-SP Gold 5120. If you have a different processor it is highly 
# likely that you have to modify the hardware events counters.
#
# NOTE: This program must be run alone, otherwise it will give wrong measures.
#
# BE CAREFUL: This program reset Hardware Prefetching.
#
# @Author: agusnt@unizar.es (http://webdiis.unizar.es/~/agusnt)
################################################################################

################################################################################
# Global variables, change them according to your workstation
################################################################################
SOURCE=$(pwd) # Actual folder of execution
BIN="$SOURCE/bin" # Integer benchmarks
RES="$SOURCE/result/2k6" # Where save the result?
REP=1 # Number of repeat the measures
CORE=0 # Core to pinned the application


################################################################################
# Benchmarks and inputs declarations
################################################################################
declare -A BENCH
BENCH=(
["400.perlbench.1"]="./perlbench -I./lib checkspam.pl 2500 5 25 11 150 1 1 1 1"
["400.perlbench.2"]="./perlbench -I./lib diffmail.pl 4 800 10 17 19 300"
["400.perlbench.3"]="./perlbench -I./lib splitmail.pl 1600 12 26 16 4500"
["401.bzip2.1"]="./bzip2 input.source 280"
["401.bzip2.2"]="./bzip2 chicken.jpg 30"
["401.bzip2.3"]="./bzip2 liberty.jpg 30"
["401.bzip2.4"]="./bzip2 input.program 280"
["401.bzip2.5"]="./bzip2 text.html 280"
["401.bzip2.6"]="./bzip2 input.combined 200"
["403.gcc.1"]="./gcc 166.in -o 166.s"
["403.gcc.2"]="./gcc 200.in -o 200.s"
["403.gcc.3"]="./gcc c-typeck.in -o c-typeck.s"
["403.gcc.4"]="./gcc cp-decl.in -o cp-decl.s"
["403.gcc.5"]="./gcc expr.in -o expr.s"
["403.gcc.6"]="./gcc expr2.in -o expr2.s"
["403.gcc.7"]="./gcc g23.in -o g23.s"
["403.gcc.8"]="./gcc s04.in -o s04.s"
["403.gcc.9"]="./gcc scilab.in -o scilab.s"
["410.bwaves.1"]="./bwaves"
["416.gamess.1"]="./gamess"
["416.gamess.2"]="./gamess"
["416.gamess.3"]="./gamess"
["429.mcf.1"]="./mcf inp.in"
["433.milc.1"]="./milc"
["434.zeusmp.1"]="./zeusmp"
["435.gromacs.1"]="./gromacs -silent -deffnm gromacs -nice 0"
["436.cactusADM.1"]="./cactusADM benchADM.par"
["437.leslie3d.1"]="./leslie3d"
["444.namd.1"]="./namd --input namd.input --iterations 38 --output namd.out"
["445.gobmk.1"]="./gobmk --quiet --mode gtp"
["445.gobmk.2"]="./gobmk --quiet --mode gtp"
["445.gobmk.3"]="./gobmk --quiet --mode gtp"
["445.gobmk.4"]="./gobmk --quiet --mode gtp"
["445.gobmk.5"]="./gobmk --quiet --mode gtp"
["447.dealII.1"]="./dealII 23"
["450.soplex.1"]="./soplex -s1 -e -m45000 pds-50.mps"
["450.soplex.2"]="./soplex -m3500 ref.mps"
["453.povray.1"]="./povray SPEC-benchmark-ref.ini"
["454.calculix.1"]="./calculix -i hyperviscoplastic"
["456.hmmer.1"]="./hmmer nph3.hmm swiss41"
["456.hmmer.2"]="./hmmer --fixed 0 --mean 500 --num 500000 --sd 350 --seed 0 retro.hmm"
["458.sjeng.1"]="./sjeng ref.txt"
["459.GemsFDTD.1"]="./GemsFDTD"
["462.libquantum.1"]="./libquantum 1397 8"
["464.h264ref.1"]="./h264ref -d foreman_ref_encoder_baseline.cfg"
["464.h264ref.2"]="./h264ref -d foreman_ref_encoder_main.cfg"
["464.h264ref.3"]="./h264ref -d sss_encoder_main.cfg"
["465.tonto.1"]="./tonto"
["470.lbm.1"]="./lbm 3000 reference.dat 0 0 100_100_130_ldc.of"
["471.omnetpp.1"]="./omnetpp omnetpp.ini"
["473.astar.1"]="./astar BigLakes2048.cfg"
["473.astar.2"]="./astar rivers.cfg"
["481.wrf.1"]="./wrf"
["482.sphinx3.1"]="./sphinx_livepretend ctlfile . args.an4"
["483.xalancbmk.1"]="./Xalan -v t5.xml xalanc.xsl"
)

# Standard input for the benchmarks
declare -A INP
INP=(
["416.gamess.1"]="cytosine.2.config"
["416.gamess.2"]="h2ocu2+.gradient.config"
["416.gamess.3"]="triazolium.config"
["433.milc.1"]="su3imp.in"
["437.leslie3d.1"]="leslie3d.in"
["445.gobmk.1"]="13x13.tst"
["445.gobmk.2"]="nngs.tst"
["445.gobmk.3"]="score2.tst"
["445.gobmk.4"]="trevorc.tst"
["445.gobmk.5"]="trevord.tst"
)

# Hardware Prefetching Mask
PRE=(0 7 11 13 14 15)
declare -A PRENAME
PRENAME=(
[0]="All"
[7]="DCUI"
[11]="DCUP"
[13]="L2A"
[14]="L2P"
[15]="None"
)

################################################################################
# Below here is the actual body (and brain) of the shell script
################################################################################

echo "|---------------------------------------------------------------------|"
echo "| This program MUST run alone, otherwise it will give wrong measures. |"
echo "|---------------------------------------------------------------------|"
echo ""

# Iterate over the benchmarks and run it
for i in "${!BENCH[@]}"
do 
    echo -n "$i: "

    # Get the name of the benchmarks
    dummy=${i::-2}

    # Move to the benchmark directory
    cd $BIN/$dummy

    # Iterate over the hardware prefetching possibilities
    for j in  "${PRE[@]}"
    do

        # Create result output directory
        out="$RES/$i/Bandwidth/"
        mkdir -p $out

        # Write MSR register to enable/disable the hardware prefetchers
        # This must be run as administrator (you need msr-tools package)
        wrmsr -p $CORE 0x1a4 $j > /dev/null 2>&1

        # Prefetch
        if [ -z ${INP[$i]} ]; then
            perf stat -r $REP --field-separator=, -o $out/${PRENAME[$j]}.bw.wr.txt -a -e uncore_imc_0/event=0x4,umask=0xC/,uncore_imc_1/event=0x4,umask=0xC/,uncore_imc_2/event=0x4,umask=0xC/,uncore_imc_3/event=0x4,umask=0xC/,uncore_imc_4/event=0x4,umask=0xC/,uncore_imc_5/event=0x4,umask=0xC/ -e instructions -- taskset -c $CORE ${BENCH[$i]} > /dev/null 2>&1 
            perf stat -r $REP --field-separator=, -o $out/${PRENAME[$j]}.bw.rd.txt -a -e uncore_imc_0/event=0x4,umask=0x3/,uncore_imc_1/event=0x4,umask=0x3/,uncore_imc_2/event=0x4,umask=0x3/,uncore_imc_3/event=0x4,umask=0x3/,uncore_imc_4/event=0x4,umask=0x3/,uncore_imc_5/event=0x4,umask=0x3/ -e instructions -- taskset -c $CORE ${BENCH[$i]} > /dev/null 2>&1
        else        
            perf stat -r $REP --field-separator=, -o $out/${PRENAME[$j]}.bw.wr.txt -a -e uncore_imc_0/event=0x4,umask=0xC/,uncore_imc_1/event=0x4,umask=0xC/,uncore_imc_2/event=0x4,umask=0xC/,uncore_imc_3/event=0x4,umask=0xC/,uncore_imc_4/event=0x4,umask=0xC/,uncore_imc_5/event=0x4,umask=0xC/ -e instructions -- taskset -c $CORE ${BENCH[$i]} < ${INP[$i]} > /dev/null 2>&1
            perf stat -r $REP --field-separator=, -o $out/${PRENAME[$j]}.bw.rd.txt -a -e uncore_imc_0/event=0x4,umask=0x3/,uncore_imc_1/event=0x4,umask=0x3/,uncore_imc_2/event=0x4,umask=0x3/,uncore_imc_3/event=0x4,umask=0x3/,uncore_imc_4/event=0x4,umask=0x3/,uncore_imc_5/event=0x4,umask=0x3/ -e instructions -- taskset -c $CORE ${BENCH[$i]} < ${INP[$i]} > /dev/null 2>&1
        fi
    done

    # Reset hardware prefetching
    wrmsr -p $CORE 0x1a4 0 > /dev/null 2>&1

    echo "OK"
    cd $SOURCE
done
