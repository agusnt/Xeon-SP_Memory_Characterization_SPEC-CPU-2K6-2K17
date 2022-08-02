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
    for filename in glob.glob(folder + '/*/*/Asoc/*/*.txt'):
        version = filename.split('/')[2]
        program = filename.split('/')[3]
        type_ = filename.split('/')[4]
        pre = filename.split('/')[5]
        
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
        if pre not in bench[version][program]:
            bench[version][program][pre] = {}

        # Reading file
        with open(filename) as f:
            # Read file except first and second lines, also we split it by ";"
            data = f.read().splitlines(True)[2:]
            # Get version of prefetch simulation
            asoc = filename.split('/')[-1].split('.')[1]
            if asoc == '0':
                asoc = '7'
            elif asoc == '1_2':
                asoc = '2'
            elif asoc == '1_4':
                asoc = '1'
            else:
                asoc = str(int(asoc) + 2)
            # Split the file
            data = [i.split(',') for i in data]
            # We include the asociativity
            if asoc not in bench[version][program][pre]:
                bench[version][program][pre][asoc] = {}
            # Read the file
            for i in data:
                bench[version][program][pre][asoc][i[2]] = int(i[0])

    # Let's treat the reading file
    for i in bench:
        for j in bench[i]:
            for k in bench[i][j]:
                for m in bench[i][j][k]:
                    # Wow, so nested. I probably can improve it, but... I don't
                    # care

                    # Get the information
                    instr = bench[i][j][k][m]['instructions']
                    cycle = bench[i][j][k][m]['cycles']
                    acces = (bench[i][j][k][m]['LLC-load'] +
                            bench[i][j][k][m]['LLC-store'])
                    miss  = (bench[i][j][k][m]['LLC-load-misses'] +
                            bench[i][j][k][m]['LLC-store-misses'])

                    # Calculate the output
                    cpi = cycle / instr
                    mpki = (miss / (instr / 1000))
                    apki = (acces / (instr / 1000))
                    
                    # Save the result
                    bench[i][j][k][m]['cpi'] = str(cpi)
                    bench[i][j][k][m]['mpki'] = str(mpki)
                    bench[i][j][k][m]['apki'] = str(apki)
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
    sdic[1] = '0.43'
    sdic[2] = '0.87'
    sdic[3] = '1.75'
    sdic[4] = '3.5'
    sdic[5] = '7'
    sdic[6] = '14'
    sdic[7] = '19.25'

    bench = read(file_)
    for i in sorted(bench):
        # We create a CSV
        csv = '#X Y Name\n'
        for j in sorted(bench[i]):
            # We calculate BPKI (Bytes per Mil instruction) as MB/s * TC (ns)* CPI
            # For our processor, Xeon SP GOLD5120 Tc is 0.45 or 0.31 with
            # turbo-bust
            tc = 1 / 0.32
            
            # Let's go
            cpiPre = '#Size Value\n'
            cpiNoPre = '#Size Value\n'
            mpkiPre = '#Size Value\n'
            mpkiNoPre = '#Size Value\n'
            apkiPre = '#Size Value\n'
            apkiNoPre = '#Size Value\n'
            
            for k in range(1, 8):
                try:
                    # Get the data
                    cpi = bench[i][j]['Prefetch'][str(k)]['cpi']
                    mpki = bench[i][j]['Prefetch'][str(k)]['mpki']
                    apki = bench[i][j]['Prefetch'][str(k)]['apki']
                    # Save the info
                    cpiPre += sdic[k] + ' ' + cpi + '\n'
                    mpkiPre += sdic[k] + ' ' + mpki + '\n'
                    apkiPre += sdic[k] + ' ' + apki + '\n'
                    cpi = bench[i][j]['No_Prefetch'][str(k)]['cpi']
                    mpki = bench[i][j]['No_Prefetch'][str(k)]['mpki']
                    apki = bench[i][j]['No_Prefetch'][str(k)]['apki']
                    cpiNoPre += sdic[k] + ' ' + cpi + '\n'
                    mpkiNoPre += sdic[k] + ' ' + mpki + '\n'
                    apkiNoPre += sdic[k] + ' ' + apki + '\n'

                    # This is for calculate SpeedUp, (1) with prefetch minimun and maximun 
                    # size, (2) with minimun size with and without prefetch
                    if k == 1:
                        withoutMin = bench[i][j]['No_Prefetch'][str(k)]['cpi']
                        withMin = bench[i][j]['Prefetch'][str(k)]['cpi']
                    elif k == 5:
                        withoutMax = bench[i][j]['No_Prefetch'][str(k)]['cpi']                       
                except:
                    pass

            # Calculate SpeedUp
            speed_size = float(withoutMin) / float(withoutMax)
            speed_pref = float(withoutMin) / float(withMin)
            csv +=  str(speed_pref) + ' ' + str(speed_size) + ' \"' + j + '\"\n'

            # Make dir if don't exists
            if not os.path.exists(out_ + '/' + i + '/' + j + '/data'):
                os.makedirs(out_ + '/' + i + '/' + j + '/data')

            # Write File
            f = open(out_ + '/' + i + '/' + j + '/data/asoc.cpi.prefetch.dat', 'w+')
            f.write(cpiPre)
            f.close()
            f = open(out_ + '/' + i + '/' + j + '/data/asoc.cpi.no_prefetch.dat', 'w+')
            f.write(cpiNoPre)
            f.close()
            f = open(out_ + '/' + i + '/' + j + '/data/asoc.mpki.prefetch.dat', 'w+')
            f.write(mpkiPre)
            f.close()
            f = open(out_ + '/' + i + '/' + j + '/data/asoc.mpki.no_prefetch.dat', 'w+')
            f.write(mpkiNoPre)
            f.close()
            f = open(out_ + '/' + i + '/' + j + '/data/asoc.apki.prefetch.dat', 'w+')
            f.write(apkiPre)
            f.close()
            f = open(out_ + '/' + i + '/' + j + '/data/asoc.apki.no_prefetch.dat', 'w+')
            f.write(apkiNoPre)
            f.close()
        if not os.path.exists(out_ + '/' + i + '/csv'):
            os.makedirs(out_ + '/' + i + '/csv')
        f = open(out_ + '/' + i + '/speed.dat', 'w+')
        f.write(csv)
        f.close()

      
