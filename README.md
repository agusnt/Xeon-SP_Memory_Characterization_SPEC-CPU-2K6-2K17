# Intel Xeon Skylake-SP memory hierarchy characterization under SPEC CPU2006 and CPU2017

This repository contains the source code and scripts used to perform the experiments in the following article:

[Agustín Navarro-Torres, Jesús Alastruey-Benedé, Pablo Ibáñez-Marín, Víctor Viñals-Yúfera, Memory hierarchy characterization of SPEC CPU2006 and SPEC CPU2017 on the Intel Xeon Skylake-SP, PLOS ONE, 2019](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0220135)


## Platform

The characterization was done on an Intel Skylake-SP Gold5120.
The system was running Centos 7, Linux Kernel 3.10.


## Prerequisites

This repository requires:
* _msr-tool_ package
* _Perf_ application
* _intel-cmt-cat_ package
* Intel processor that supports Intel Resource Directory Technology
* GNU/Linux system
* C compiler
* SPEC CPU2006 and CPU2017 benchmark suites

## Folders

This repository contains three folders:
* **2k6**: scripts to execute and characterize the CPU2006 benchmarks.
* **2k17**: scripts to execute and characterize the CPU2017 benchmarks.
* **perfplusplus**: a C program which allows to read the hardware performance 
  counters every *x* samples of one of them

## Building and Running

Each folder has his own _README.md_ that explains how to build (if it is 
necessary) and run the scripts/application.

## Notes

Most of the hardware counters used have a clearly identifiable alias. The only
two hardware counters without alias are: `ef24` which refers to *Retired
Instructions* and `08d1` which refers to *L1D Miss*.
