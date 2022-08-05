#!/bin/bash

mkdir Processed
# Calculate things
echo "Processing"
python3 Parse/asoc.py ../FigData ./Processed > /dev/null 2>&1
python3 Parse/asoc_mitades.py ../FigData ./Processed > /dev/null 2>&1
python3 Parse/bw.py ../FigData ./Processed > /dev/null 2>&1
Parse/bw.sh ../FigData ./Processed/bw.csv > /dev/null 2>&1
python3 Parse/prefetch.py ../FigData ./Processed > /dev/null 2>&1
python3 Parse/time.py ../FigData ./Processed > /dev/null 2>&1
Parse/time_bw.sh ../FigData ./Processed > /dev/null 2>&1
Parse/time_bw_second.sh ../FigData ./Processed  > /dev/null 2>&1
Parse/simpoint.sh ../FigData ./Processed > /dev/null 2>&1
Parse/Prefetch.sh ../FigData ./Processed/ > /dev/null 2>&1
Parse/barrido_prefetch_all.sh ../FigData Processed > /dev/null 2>&1
Parse/barrido_prefetch_2017.sh ../FigData Processed

rm dummy*

# Plotting things
echo "Plotting"
Plot/pltAsoc.sh ./Processed > /dev/null 2>&1
Plot/pltPrefetch.sh ./Processed > /dev/null 2>&1
Plot/pltTime.sh ./Processed > /dev/null 2>&1
Plot/pltBwTime.sh  ./Processed > /dev/null 2>&1
Plot/pltBwTimeSeg.sh  ./Processed > /dev/null 2>&1 
Plot/pltTime_cpi_mpki.sh ./Processed  > /dev/null 2>&1
Plot/pltScatter.sh ./Processed > /dev/null 2>&1
Plot/pltBwBarrido.sh ./Processed > /dev/null 2>&1
