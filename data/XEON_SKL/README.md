# Data XEON\_SKL

This directory stores the data to reproduce figures 2 to 12.

## Data

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