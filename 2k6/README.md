# Scripts CPU2006

This folder contains four scripts that take metrics of all CPU2006 benchmarks
(application + reference inputs).

You should probably have to changes some variables. They are at the beginning of 
each file and every variable comes with an small description.

## Requirements

- _msr-tool_ package
- _intel-cmt-cat_ package
- _perf_
- An Intel processor

## Scripts

- __Bandwidth__: measure the total access (read/write) to main memory.
- __HW\_Prefetch__: measure misses/access to LLC and CPI with different
  configuration of hardware prefetching.
- __LLC\_size__: measure misses/access to LLC and CPI with different
  sizes of LLC.
- __Time__: measure misses/access to LLC and CPI every one million of
  instructions. 
- __L1Miss__: measure L1 misses.

## Running

To run any scripts just:
* Change the initial vars with your proper values (e.g. folder where the 
  SPEC CPU2006 where compiled)
* Type:
```
./script_name.sh
```

The binary and all necessary files to execute a benchmark must be in
a folder whose name is the benchmark (e.g.: _400.perlbench_ must contain
the executable and all other files and folder necessary to run the program).
All these folders must be in the same directory.
