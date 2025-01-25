# Author: Annika Salpukas
# Date: September 2024

# For each gene/timepoint, program reports number of dsbs occurring in each g-run/loop
# To run the program from command line:
#   python3 path-to-pyfile/dsb_specific_positions_scaled.py path-to-input-dir path-to-output-file

# import libraries
import sys
import os
import multiprocessing as mp
from collections import defaultdict, Counter
import pandas as pd
import random

'''
line map:
- 0: chromosome
- 1: start g4
- 2: end g4
- 3: g4 length
- 4: 0
- 5: strand sign
- 6: raw sequence
- 7: sense sequence
- 8: peak
- 9: chromosome
- 10: dsb start
- 11: dsb end
- 12: label
- 13: ?
- 14: dsb strand
- 15: distance from dsb
'''

# function to get g-run length
def symbollength(wl):
    amount = 0
    wllen = len(wl)
    
    while amount < wllen - 1 and wl[amount] == wl[amount + 1]:
        amount += 1
    
    return amount + 1

# function to get loop length
def looplength(wl, s='g'):
    amount = 0
    wllen = len(wl)
    
    while amount < wllen - 1 and not (wl[amount] == s and wl[amount + 1] == s):
        amount += 1
    
    return amount

# function to find where DSB index is in G4, return element and position within element
def find_index(i, sequence, dist):
    
    # initialize variables
    num = 0
    parse = 0
    result = None
    position = None
    
    # while haven't parsed full sequence
    while parse < len(sequence):
        num += 1
        glen = symbollength(sequence[parse:])
        parse += glen
        
        if i == -1:
            result = 'G-run 1'
            position = 0
        
        if i < parse and i >= parse-glen:
            result = f'G-run {num}'
            position = (i + glen - parse + 1)/glen
        looplen = looplength(sequence[parse:])
        parse += looplen
        if i < parse and i >= parse-looplen:
            result = f'Loop {num}'
            position = (i + looplen - parse + 1)/looplen

    if num != 4:
        return 'Non-canonical', 0
    if dist < 0:
        return 'Before', dist
    if dist > 0:
        return 'After', dist
    
    return result, position

def read_file(path):
    data = defaultdict(list)
    shuffle_data = defaultdict(list)

    with open(path, 'r') as file:
        for line in file:
            splitLine = line.split('\t')

            distance = int(splitLine[15])
            if distance > 100 or distance < -100:
                continue

            sign = splitLine[5]
            if sign == '-': # antisense strand
                g4 = splitLine[7].lower()
                dsbIndex = int(splitLine[2]) - int(splitLine[11]) - 1 # end G4 - end DSB - 1
            else:
                g4 = splitLine[6].lower() # sense strand
                dsbIndex = int(splitLine[10]) - int(splitLine[1]) # start DSB - start G4
            
            element, pos = find_index(dsbIndex, g4, distance)
            
            # shuffle indices
            if distance < 0: # upstream DSB
                shuffleIndex = random.randint(-100, -1)
                shuffleElement, shufflePos = find_index(shuffleIndex, g4, shuffleIndex)
            elif distance > 0: # downstream DSB
                shuffleIndex = random.randint(1, 100)
                shuffleElement, shufflePos = find_index(shuffleIndex, g4, shuffleIndex)
            else: # overlapping DSB
                if sign == '-':
                    shuffleIndex = random.randint(-1, len(g4)-2)
                else:
                    shuffleIndex = random.randint(0, len(g4)-1)
                shuffleElement, shufflePos = find_index(shuffleIndex, g4, distance)

            data[element].append(pos)
            shuffle_data[shuffleElement].append(shufflePos)

        base = os.path.basename(path)
        counts = [(element, pos, count) for element, pos_list in data.items() for pos, count in dict(Counter(pos_list)).items()]
        result_df = pd.DataFrame(counts, columns=['Element', 'DSB Position', 'Frequency'])
        result_df.insert(0, 'Gene', base[:-17])
        result_df.insert(1, 'Rep', base[-16:-14])
        
        shuffle_counts = [(element, pos, count) for element, pos_list in shuffle_data.items() for pos, count in dict(Counter(pos_list)).items()]
        shuffle_df = pd.DataFrame(shuffle_counts, columns=['Element', 'DSB Position', 'Frequency'])
        shuffle_df.insert(0, 'Gene', base[:-17])
        shuffle_df.insert(1, 'Rep', base[-16:-14])
        
        print('Read file: ', base)
        return result_df, shuffle_df

def main():
    # first arg: input file directory, second: csv outpath
    inDir = sys.argv[1]
    outFile = sys.argv[2]
    outShuffleFile = outFile[:-4] + '_shuffle' + outFile[-4:]

    genes = [
        'siControl_veh_0h',
        'siBAZ2A_veh_0h',
        'siBAZ2B_veh_0h',
        'siControl_BRACO19_18h',
        'siBAZ2A_BRACO19_18h',
        'siBAZ2B_BRACO19_18h'
    ]
    
    reps = [
        'R1',
        'R2',
        'R3'
    ]

    files = [os.path.join(inDir, gene + '_' + rep + '_distances.bed') for rep in reps for gene in genes]

    workers = mp.cpu_count()  

    with mp.Pool(processes=workers) as pool:
        rows = pool.map(read_file, files)
    print('Read all files...')
    
    results, shuffle_results = map(list, zip(*rows))

    final_df = pd.concat(results, ignore_index=True)
    final_df['Percentage of Data for Gene/Rep'] = final_df['Frequency']*100/final_df.groupby(['Gene', 'Rep'])['Frequency'].transform('sum')
    
    element_order = ['Non-canonical', 'Before', 'G-run 1', 'Loop 1', 'G-run 2',
                     'Loop 2', 'G-run 3', 'Loop 3', 'G-run 4', 'After']
    final_df['Gene'] = pd.Categorical(final_df['Gene'], categories=genes, ordered=True)
    final_df['Rep'] = pd.Categorical(final_df['Rep'], categories=reps, ordered=True)
    final_df['Element'] = pd.Categorical(final_df['Element'], categories=element_order, ordered=True)
    
    final_df = final_df.sort_values(['Gene', 'Rep', 'Element', 'DSB Position'])
    
    ## shuffle
    shuffle_df = pd.concat(shuffle_results, ignore_index=True)
    shuffle_df['Percentage of Data for Gene/Rep'] = shuffle_df['Frequency']*100/shuffle_df.groupby(['Gene', 'Rep'])['Frequency'].transform('sum')

    shuffle_df['Gene'] = pd.Categorical(shuffle_df['Gene'], categories=genes, ordered=True)
    shuffle_df['Rep'] = pd.Categorical(shuffle_df['Rep'], categories=reps, ordered=True)
    shuffle_df['Element'] = pd.Categorical(shuffle_df['Element'], categories=element_order, ordered=True)
    
    shuffle_df = shuffle_df.sort_values(['Gene', 'Rep', 'Element', 'DSB Position'])
    
    print('Final dataframe built...')

    outDir = os.path.dirname(outFile)
    if not os.path.exists(outDir):
        os.makedirs(outDir)

    final_df.to_csv(outFile, index=False)
    shuffle_df.to_csv(outShuffleFile, index=False)
    print('Process completed.')

if __name__ == '__main__':
    main()