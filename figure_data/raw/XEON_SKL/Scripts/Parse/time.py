#!/usr/bin/python3
import sys, glob, os

def read(folder):
    single = ["600.perlbench_s", "602.gcc_s", "605.mcf_s", "620.omnetpp_s",
            "623.xalancbmk_s", "625.x264_s", "631.deepsjeng_s", "641.leela_s",
            "648.exchange2_s"]
    bench = {}
    
    # Read the information
    for filename in glob.glob(folder + "/*/*/Perf++/*.txt"):
        version = filename.split('/')[2]
        type_ = filename.split('/')[4]
        program = filename.split('/')[3]

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
        if type_ not in bench[version][program]:
            bench[version][program][type_] = {}
        
        with open(filename) as f:
            data = f.read().splitlines(True)[1:]
            data = [i.split(' ') for i in data]
            if (int(filename.split('/')[-1].split('.')[1]) == 1):
                bench[version][program][type_]['instruction'] = []
                bench[version][program][type_]['diff_instruction'] = []
                bench[version][program][type_]['cycles'] = []
                bench[version][program][type_]['write_access'] = []
                bench[version][program][type_]['write_miss'] = []

                bench[version][program][type_]['instruction'].append(data[0][0])
                bench[version][program][type_]['diff_instruction'].append(data[0][0])
                bench[version][program][type_]['cycles'].append(data[0][1])
                bench[version][program][type_]['write_access'].append(data[0][2])
                bench[version][program][type_]['write_miss'].append(data[0][3])
                for idx, i in enumerate(data[1:]):
                    bench[version][program][type_]['instruction'].append(i[0])
                    bench[version][program][type_]['diff_instruction'].append(int(data[idx - 1][0]) - int(i[0]))
                    bench[version][program][type_]['cycles'].append(int(data[idx - 1][1]) - int(i[1]))
                    bench[version][program][type_]['write_access'].append(int(data[idx - 1][2]) - int(i[2]))
                    bench[version][program][type_]['write_miss'].append(int(data[idx - 1][3]) - int(i[3]))
            if (int(filename.split('/')[-1].split('.')[1]) == 2):
                bench[version][program][type_]['read_access'] = []
                bench[version][program][type_]['read_miss'] = []

                bench[version][program][type_]['read_access'].append(data[0][1])
                bench[version][program][type_]['read_miss'].append(data[0][2])
                for idx, i in enumerate(data[1:]):
                    bench[version][program][type_]['read_access'].append(int(data[idx - 1][1]) - int(i[1]))
                    bench[version][program][type_]['read_miss'].append(int(data[idx - 1][2]) - int(i[2]))
    for filename in glob.glob(folder + "/*/*/Perf++/*/*.txt"):
        version = filename.split('/')[2]
        type_ = filename.split('/')[4]
        program = filename.split('/')[3]

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
        if type_ not in bench[version][program]:
            bench[version][program][type_] = {}
        
        with open(filename) as f:
            data = f.read().splitlines(True)[1:]
            data = [i.split(' ') for i in data]
            if (int(filename.split('/')[-1].split('.')[1]) == 1):
                bench[version][program][type_]['instruction'] = []
                bench[version][program][type_]['diff_instruction'] = []
                bench[version][program][type_]['cycles'] = []
                bench[version][program][type_]['write_access'] = []
                bench[version][program][type_]['write_miss'] = []

                bench[version][program][type_]['instruction'].append(data[0][0])
                bench[version][program][type_]['diff_instruction'].append(data[0][0])
                bench[version][program][type_]['cycles'].append(data[0][1])
                bench[version][program][type_]['write_access'].append(data[0][2])
                bench[version][program][type_]['write_miss'].append(data[0][3])
                for idx, i in enumerate(data[1:]):
                    bench[version][program][type_]['instruction'].append(i[0])
                    bench[version][program][type_]['diff_instruction'].append(int(data[idx - 1][0]) - int(i[0]))
                    bench[version][program][type_]['cycles'].append(int(data[idx - 1][1]) - int(i[1]))
                    bench[version][program][type_]['write_access'].append(int(data[idx - 1][2]) - int(i[2]))
                    bench[version][program][type_]['write_miss'].append(int(data[idx - 1][3]) - int(i[3]))
            if (int(filename.split('/')[-1].split('.')[1]) == 2):
                bench[version][program][type_]['read_access'] = []
                bench[version][program][type_]['read_miss'] = []

                bench[version][program][type_]['read_access'].append(data[0][1])
                bench[version][program][type_]['read_miss'].append(data[0][2])
                for idx, i in enumerate(data[1:]):
                    bench[version][program][type_]['read_access'].append(int(data[idx - 1][1]) - int(i[1]))
                    bench[version][program][type_]['read_miss'].append(int(data[idx - 1][2]) - int(i[2]))

    return bench

if __name__ == '__main__':
    '''
    Transform Raw data from the experiments in good data in order to use gnuplot
    with them

    Parameters:
        $1 -> Raw Data directory
        $2 -> Output directory
    '''
    file_ = sys.argv[1]
    out_ = sys.argv[2]

    bench = read(file_)
    # Version of Spec
    for i in bench:
        for j in bench[i]:
            for k in bench[i][j]:
                if not os.path.exists(out_ + '/' + i + '/' + j + '/data'):
                    os.makedirs(out_ + '/' + i + '/' + j + '/data')
                f = open(out_ + '/' + i + '/' + j + '/data/time.' + k + '.dat', 'w+')
                f1 = open(out_ + '/' + i + '/' + j + '/data/time.100.' + k + '.dat', 'w+')
                last = 0
                for l in range(0, min(len(bench[i][j][k]['instruction']), len(bench[i][j][k]['read_access']))):
                    cpi = int(bench[i][j][k]['cycles'][l]) / int(bench[i][j][k]['diff_instruction'][l])
                    access = int(bench[i][j][k]['write_access'][l]) + int(bench[i][j][k]['read_access'][l])
                    misses = int(bench[i][j][k]['write_miss'][l]) + int(bench[i][j][k]['read_miss'][l])
                    apki = round(access / (int(bench[i][j][k]['diff_instruction'][l]) / 1000), 2)
                    mpki = round(misses / (int(bench[i][j][k]['diff_instruction'][l]) / 1000), 2)
                    f.write(bench[i][j][k]['instruction'][l] + '   ')
                    f.write(str(cpi) + '    ')
                    f.write(str(apki) + '   ')
                    f.write(str(mpki) + '\n')

                    ciclos = 0
                    instr = 0
                    access = 0
                    misess = 0
                    # Every 100
                    if l != 0 and (l % 100) == 0:
                        las = l
                        for n in range(l - 100, l):
                            ciclos += int(bench[i][j][k]['cycles'][n])
                            instr += int(bench[i][j][k]['diff_instruction'][n])
                            access += int(bench[i][j][k]['write_access'][n]) + int(bench[i][j][k]['read_access'][n])
                            misses += int(bench[i][j][k]['write_miss'][n]) + int(bench[i][j][k]['read_miss'][n])
                        try:
                            cpi = round(ciclos / instr, 2)
                            apki = round(access / (instr / 1000), 2)
                            mpki = round(misses / (instr / 1000), 2)
                            f1.write(bench[i][j][k]['instruction'][l] + '   ')
                            f1.write(str(abs(cpi)) + '    ')
                            f1.write(str(abs(apki)) + '   ')
                            f1.write(str(abs(mpki)) + '\n')
                        except:
                            pass
                for n in range(last, l):
                    ciclos += int(bench[i][j][k]['cycles'][n])
                    instr += int(bench[i][j][k]['diff_instruction'][n])
                    access += int(bench[i][j][k]['write_access'][n]) + int(bench[i][j][k]['read_access'][n])
                    misses += int(bench[i][j][k]['write_miss'][n]) + int(bench[i][j][k]['read_miss'][n])
                try:
                    cpi = round(ciclos / abs(instr), 2)
                    apki = round(access / (abs(instr) / 1000), 2)
                    mpki = round(misses / (abs(instr) / 1000), 2)
                    f1.write(bench[i][j][k]['instruction'][l] + '   ')
                    f1.write(str(abs(cpi)) + '    ')
                    f1.write(str(abs(apki)) + '   ')
                    f1.write(str(abs(mpki)) + '\n')
                except:
                    print(j)

                f.close()
                f1.close()
