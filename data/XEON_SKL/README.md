# Data XEON\_SKL

This directory stores the data to reproduce figures 2 to 12.

## Data

The results of this directory correspond to the characterization of a system
with the following characteristics:

| Processor   | Intel Xeon Gold 5120 (Skylake-SP)  |
|-------------|------------------------------------|
| Main Memory | 96 GiB DDR4                        |
| L1 I-Cache  | 32 KiB, 64 B line size, 8 ways     |
| L1 D-Cache  | 32 KiB, 64 B line size, 8 ways     |
| L2          | 1 MiB, 64 B line size, 8 ways      |
| LLC         | 19.25 MiB, 64 B line size, 11 ways |
| OS          | CentOS 7; kernel: 3.10             |

### Summary

The following `csv` files summarize the data information:
- *General_Info.csv*: Number of instructions, percentage of read (Lect),
  percentage of writes (Escr), MPKI1, MPKI2, MPKI3, and CPI by benchmark (Fig 2
  and 3).
- *Associativity_NoPrefetch.csv*: CPI vs LLC Cache Size without prefetch
- *Associativity_Prefetch.csv*: CPI vs LLC Cache Size with prefetch
- *MPKI_APKI_CPI_Prefetch.csv*: MPKI, APKI, and CPI buy prefetcher and
  benchmark.

### Data for figures

Folder *FigData* stores all the raw data to reproduce figures from 4 to 12:

```
| - FigData
|    | - CPU2006: CPU2006 benchmarks data
|    | - CPU2017: CPU2017 benchmarks data
|    |    | - [Benchmark Name]
|    |    |    | - Asoc: LLC load misses, cycles and instrucctions vs LLC Size
|    |    |    |    | - No_Prefetch: Without Prefetch
|    |    |    |    | - Prefetch: With Prefetch
|    |    |    | - BW: Data brought from memory by the different prefetchers
|    |    |    |    | - RD: Read data
|    |    |    |    | - WR: Write data 
|    |    |    | - Perf++: 
|    |    |    |    | - Prefetch: MPKI3 during the benchmark run
|    |    |    | - simpoint.csv
|    |    |    | - general.txt:  Loads, stores and instructions of the benchmark
|    |    |    | - l1.txt: L1D data
```


## Correlation between data and figures

The following is a correlation between the figures and the data that generate
them:

- **Fig 2 and 3**: *General_Info.csv*
- **Fig 4, 5 and 6**: *Associativity_Prefetch.csv* and *Associativity_NoPrefetch.csv*
  or *Asoc* folder
- **Fig 7 and 8**: *Asoc* folder
- **Fig 9 and 10**: *BW* folder
- **Fig 11 and 12**: *Perf++/Prefetch* folder

The data for figures **5** and **10** are in folder `CSVFigData`.

## Scripts

The directory `Scripts` contains all the scripts needed to generate the
figures.

- `exec.sh`: parse all the data (*FigData* folder) and generate the graphs.
- `Parse`: contains all the scripts to parse de data.
- `Plot`: contains all the scripts to generate the graphs.

After the execution a folder called *Processsed* appears. This folder contains
two directories (*CPU2006* and *CPU2017Rate*) and seven `csv` files which
summarize the data. The two directories contains one folder by every memory
intensive benchmark, with the data and the plots.

### Requirements

You will need `python3` to parse the files and `gnuplot` to generate the graphs.
