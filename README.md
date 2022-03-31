# Intel Xeon Skylake-SP memory hirearchy characterization under SPEC CPU2006 and
# CPU2017

This is a repository how contain every script that will be necessary to
reproduce the experiments explained in the following paper: 

## Platform

The characterization was done on an Intel Skylake-SP Gold5120 which 
supports Intel Resource Directory Technology. The system was running Centos 7,
Linux Kernel 3.10.


## Prerequisites

This repository requires:
* _msr-tool_ package
* _Perf_ application
* _intel-cmt-cat_ package
* An Intel processor that support Intel Resource Directory Technology
* A GNU/Linux system
* A C compiler
* SPEC CPU2006 and CPU2017

## Folders

This repository contains three folders:
* **2k6**: scripts to execute and measure the CPU2006 benchmarks.
* **2k17**: scripts to execute and measure the CPU2017 benchmarks.
* **Perfplusplus**: a C program which allows to read the hardware performance 
  counter every *x* samples of one of them

### Building and Running

Every folder has his own _README.md_ that explains how to build (if it is 
necessary) and running the scripts/application.

## Publication

[Agustín Navarro-Torres, Jesús Alastruey-Benedé, Pablo Ibáñez-Marín, Víctor Viñals-Yúfera, Memory hierarchy characterization of SPEC CPU2006 and SPEC CPU2017 on the Intel Xeon Skylake-SP, PLOS ONE, 2019](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0220135)
 