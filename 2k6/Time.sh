#!/bin/bash

################################################################################
# This script runs all SPEC CP2006 benchmarks with their reference inputs and 
# obtains their MPKI3 and CPI evolution throughout their executions.
#
# You need the perf-tools package and msr-tools. This program is prepared to run 
# on an Intel processor
#
# NOTE: This program must be run alone, otherwise it will give wrong measures.
#
# BE CAREFUL: This program modifies hardware prefetching and Intel CAT configurations
#
# @Author: agusnt@unizar.es (http://webdiis.unizar.es/~/agusnt)
################################################################################

################################################################################
# Global variables, change them according to your workstation
################################################################################
SAMPLE="100000000"
SOURCE=$(pwd)
BIN="$SOURCE/bin" # benchmarks binaries
RES="$SOURCE/result/2k6/" # results directory
PERF="$HOME/bin/Perf++/main" # Pef++
REP=1 # number of measurement repetitions
CORE=0 # core to pin the application


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

# Execution variables
EXEC="$PERF -n 4 -c PERF_COUNT_HW_INSTRUCTIONS PERF_COUNT_HW_CPU_CYCLES"
EXEC="$EXEC PERF_COUNT_HW_CACHE_LL_ACCESS_W PERF_COUNT_HW_CACHE_LL_MISS_W"
EXEC="$EXEC -s $SAMPLE"
EXECBIS="$PERF -n 3 -c PERF_COUNT_HW_INSTRUCTIONS"
EXECBIS="$EXECBIS PERF_COUNT_HW_CACHE_LL_ACCESS_R PERF_COUNT_HW_CACHE_LL_MISS_R"
EXECBIS="$EXECBIS -s $SAMPLE"

################################################################################
# Below here is the actual body (and brain) of the shell script
################################################################################

# Restrict LLC ways with Intel CAT (pqos)
# You need to run it as administrator (you need intel-cmt-cat package)
pqos -e "llc:1=0x0001;llc:2=0x0003;llc:3=0x000f;llc:4=0x00ff" > /dev/null 2>&1
pqos -a "llc:1=0" > /dev/null 2>&1

# Enable all hardware prefetchers
wrmsr -p $CORE 0x1a4 0x0 > /dev/null 2>&1

# Iterate over the benchmarks and run it
for i in "${!BENCH[@]}"
do 
    dummy=${i::-2} # Remove last two characters
    echo -n "$i: "

    #----------------------------------------------------------------------#
    #                           Rate Benchmarks                            #
    #----------------------------------------------------------------------#
    cd $BIN/$dummy # Move to the benchmarks folder
    out="$RES/$i/Time/"
    mkdir -p $out

    if [ -z ${INP[$i]} ]; then
        eval "$EXEC -o $out/data.1.txt -- taskset -c $CORE ${BENCH[$i]} > /dev/null 2>&1"
        eval "$EXECBIS -o $out/data.2.txt -- taskset -c $CORE ${BENCH[$i]} > /dev/null 2>&1"
    else
        eval "$EXEC -o $out/data.1.txt -- taskset -c $CORE ${BENCH[$i]} < ${INP[$i]} > /dev/null 2>&1"
        eval "$EXECBIS -o $out/data.2.txt -- taskset -c $CORE ${BENCH[$i]} < ${INP[$i]} > /dev/null 2>&1"
    fi

    echo "OK"
    cd $SOURCE
done

# Reset ALL Intel CAT Mask and configurations
pqos -R > /dev/null 2>&1
