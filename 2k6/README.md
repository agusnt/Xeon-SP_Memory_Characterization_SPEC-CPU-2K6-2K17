# Scripts CPU2006

This directory contains five scripts that take metrics of all CPU2006 benchmarks
(application + reference inputs).

You should probably have to change some variables.
They are initialized at the beginning of each file and come with a brief description.

## Requirements

- GNU/Linux system
- Intel processor with Intel Resource Directory Technology support
- _msr-tool_ package
- _intel-cmt-cat_ package
- _perf_


## Scripts

- __Bandwidth__: measures the main memory bandwidth consumption (read/write).
- __HW\_Prefetch__: measures misses/accesses to LLC and CPI with different
  hardware prefetching configurations.
- __LLC\_size__: measures misses/accesses to LLC and CPI with differentf LLC sizes.
- __Time__: measures misses/accesses to LLC and CPI every one million of instructions. 
- __L1Miss__: measures L1 misses.

## Running

To run any scripts just:
* Change the initial vars with your proper values (e.g. folder where the 
  SPEC CPU2006 were compiled)
* Type:
```
./script_name.sh
```

The binary and all necessary files to execute a benchmark must be in
a folder whose name is the benchmark (e.g.: _400.perlbench_ must contain
the executable and all other files and folder necessary to run the program).
All these folders must be in the same directory.
