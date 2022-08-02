#!/usr/bin/python3
# Imports
import sys, glob, os

############# HERE START THE CODE, YOU SHOULD NOT TOUCH IT #####################

def read(folder):
    single = ["600.perlbench_s", "602.gcc_s", "605.mcf_s", "620.omnetpp_s",
            "623.xalancbmk_s", "625.x264_s", "631.deepsjeng_s", "641.leela_s",
            "648.exchange2_s"]
    bench = {}
    '''
    Read files and save the information in a big csv to be exported into excel
    or similar programs
    '''
    for filename in glob.glob(folder + '/*/*/BW/*.txt'):
        version = filename.split('/')[2]
        program = filename.split('/')[3]
        type_ = filename.split('/')[4]
        
        if version == 'CPU2017':
            if int(program.split('.')[0][0]) == 6:
                if '.'.join(program.split('.')[:-1]) in single:
                    # If is single-thread
                    version = 'CPU2017SSpeed'
                else:
                    # If is multi-thread
                    version = 'CPU2017MSpeed'
            else:
                version = 'CPU2017Rate'
        if version not in bench:
            bench[version] = {}
        if program not in bench[version]:
            bench[version][program] = {}

        # Reading file
        with open(filename) as f:
            # Read file except first and second lines, also we split it by ";"
            data = [i.split(',') for i in f.read().splitlines(True)[2:]]
            # Get version of prefetch simulation
            v = filename.split('/')[-1].split('.')[0]

            if v not in bench[version][program]:
                bench[version][program][v] = {}

            mb = 0
            if int(data[6][2]) > int(data[-1][2]):
                for i in data[:6]:
                    mb += int(i[2])
                instr = int(data[6][2])
            else:
                for i in data[7:-1]:
                    mb += int(i[2])
                instr = int(data[-1][2])
            bench[version][program][v] = (mb / (instr / 1000)) * 64


    return bench

if __name__ == "__main__":
    '''
    This code is a big shit... I should improve it, but it works and for me,
    now, it's enough
    '''

    if len(sys.argv) != 3:
        print('Arguments: Data folder and Output folder')
        sys.exit(1)

    # Parameters
    file_ = sys.argv[1]
    out_ = sys.argv[2]

    # 'Sorted' dictionary for printing data
    sdic = {}
    sdic[0] = 'Ninguno'
    sdic[1] = 'Enable_DCUI'
    sdic[2] = 'Enable_DCUP'
    sdic[3] = 'Enable_L2A'
    sdic[4] = 'Enable_L2P'
    sdic[5] = 'Todos'
    fdic = {}
    fdic[0] = 'None'
    fdic[1] = 'DCUI'
    fdic[2] = 'DCUP'
    fdic[3] = 'L2A'
    fdic[4] = 'L2P'
    fdic[5] = 'All'

    bench = read(file_)
    for i in sorted(bench):

        # We create a CSV
        csv = 'Benchmark;None;DCUI;DCUP;L2A;L2P;All\n'
        for j in sorted(bench[i]):
            # Let's go
            output = '#Type Value\n'
            csv += j + ';'

            for k in range(0, 6):
                mb = bench[i][j][sdic[k]]
                output += fdic[k] + ' ' + str(mb) + '\n'
                csv += str(mb) + ';'
            csv += '\n'

            # Make dir if don't exists
            if not os.path.exists(out_ + '/' + i + '/' + j + '/data'):
                os.makedirs(out_ + '/' + i + '/' + j + '/data')

            # Write File
            f = open(out_ + '/' + i + '/' + j + '/data/bw.dat', 'w+')
            f.write(output)
            f.close()

        # Write CSV
        if not os.path.exists(out_ + '/' + i + '/csv'):
            os.makedirs(out_ + '/' + i + '/csv')
        f = open(out_ + '/' + i + '/csv/bw.csv', 'w+')
        f.write(csv)
        f.close()
