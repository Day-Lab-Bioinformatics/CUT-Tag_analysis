import sys
import pandas as pd

def calc_distance(row):
    if (row[10] < row[1]) and (row[11] <= row[1]):
        dist = row[11] - row[1] - 1
    elif (row[11] > row[2]) and (row[10] >= row[2]):
        dist = row[10] - row[2] + 1
    else:
        dist = 0
    if row[5] == '-':
        dist = -1*dist
    return dist

def process_file(inFile, outFile):
    df = pd.read_csv(inFile, header=None, delimiter='\t')
    df['distance'] = df.apply(calc_distance, axis=1)
    df.to_csv(outFile, index=False, header=False, sep='\t')

if __name__=='__main__':
    process_file(sys.argv[1], sys.argv[2])