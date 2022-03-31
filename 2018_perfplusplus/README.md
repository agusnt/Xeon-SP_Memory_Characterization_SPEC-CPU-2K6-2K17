# Perf++

C program which allows, using Perf, to read the hardware performance counter
every *x* samples of one of them.

## Prerequisites

You should install in your GNU/Linux computer:
* Linux Kernel >= 3.0
* A C compiler
* linux-tools

## Installation

Download or clone the code and execute in your terminal:

```
gcc -O3 main.c -o main
```

## How to use

Execute the following command in your terminal:
```
./main -n [number of events] -o [output file] -s [Sample] -c [Counters] [-r] -- Program args
```

Parameters:
* **-n**: Number of events.
* **-o**: Path for the output file.
* **-s**: Number of samples
* **-c**: Name of the counters to measure, the first counter also represent the
  interrupt counter associated with the **-s** parameter.
* **-r**: Use raw counter, you can only use raw counters or O.S defined
  counters.
* **Program args**: Command line of the program to be measure.

The different counter that can be available to be measure can be seen with:
```
main -l
```

**Note**: some of these counter may not available in your processor or can
not be used together.

For more information, please type:

```
./main -h
```

## Example

To measure the number of Cycles every 1000 instructions of a program:
```
./main -n 2 -c PERF_COUNT_HW_INSTRUCTIONS PERF_COUNT_HW_CPU_CYCLES -s 1000 -o test.txt -- ls 
```

The output file, in these case test.txt:

```
#PERF_COUNT_HW_INSTRUCTIONS #PERF_COUNT_HW_CPU_CYCLES 
1014 10389 
2082 14627 
3145 21427 
4004 23810 
5033 25556 
6087 31684 
7507 38020 
9002 41449 
10018 43511 
11025 45575 
12017 47599 
12915 49209 
14012 52209 
15043 54142 
15998 55753 
16403 58551 
17024 60022 
18008 63106 
19013 69182 
20037 72045 
22057 74882 
23052 76315 
24041 78286 
24041 78286 
25071 80903 
26659 85010 
27116 87036 
28077 89043 
29009 91731 
31015 96905 
31015 96905 
32616 100724 
33020 103631 
34005 107968 
35018 111565 
35018 111565 
```
