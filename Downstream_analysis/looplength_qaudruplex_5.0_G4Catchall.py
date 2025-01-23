#!/usr/bin/env python3

##argparse magic
import sys

## Run as python3 looplength_quadruplex.py
## looplength_quadruplex_5.0_G4Catchall.py
## Script created by Jan-Baptist Vandeuren & Adrianna Vandeuren on 01/01/2023
## Latest update: 03/29/2024 by Adrianna Vandeuren

## This needs .txt or .bed files
## wl stands for workline, aka the line you're analyzing
def symbollength(wl):
    ## amount stands for both the position you're looking at and the amount of bases you went through
    amount = 0
    ## If flag is 1, the function knows it should keep running
    flag = 1
    ## Define the amount of bases in the sequence aka workline length
    wllen = len(wl)
    ## Python counts starting from 0, however we need numbers from 1, to prevent the script of returning 1 when nothing meets the requirements, this line is needed.
    if amount >= wllen -1:
        amount = amount - 1
    while (amount < wllen -1) & (flag == 1):
        if wl[amount] == wl[amount +1]:
            amount = amount +1
        else:
            flag = 0
    amount = amount + 1
    return amount

## Here we define te code needed to determine the loop length, as long as there are no 2 Gs in a row it will add to the count. 
def looplength(wl, s):
    amount = 0
    flag = 1
    wllen = len(wl)
    while (amount < wllen -1) & (flag == 1):
        if (wl[amount] == searchsymbol) & (wl[amount + 1] == searchsymbol):
            flag = 0
        else:
            amount = amount +1
    return amount

## Here we define the coded needed to determine the base content of each loop both given as an absolute number as well as a perentage. 
def loopcontentcount(g4r, length):
    result = ""
    if length > 0:
        a = 0
        t = 0
        g = 0
        c = 0
        i = 0
        while(i < length):
            if g4r[i] =='a':
                a+=1
            elif g4r[i] == 't':
                t+=1
            elif g4r[i] == 'g':
                g+=1
            elif g4r[i] == 'c':
                c+=1
            else:
                print("error")
            i+=1
        result = str(a) +'\t'+str(round((a/length)*100, 2))+'\t'+str(t)+'\t'+str(round((t/length)*100, 2))+'\t'+str(g)+'\t'+str(round((g/length)*100, 2))+'\t'+str(c)+'\t'+str(round((c/length)*100, 2))
    else:
        result = "0\t0\t0\t0\t0\t0\t0\t0"
    return result

#start main

## This line asks for a filname for entry
if len(sys.argv) > 1:
    file_name = sys.argv[1]
else:
    file_name = str(input("Filename with extension:"))

## Here you open the file that you inputted
f = open(file_name,'r')
## Here you open a results file
f2 = open(file_name[:-4]+"_looplength.txt",'w')
f3 = open(file_name[:-4]+"_looplength_zeroloop.txt",'w')

textentry =""
line = f.readline()

## This is what determines the header of your results file
textentry += "Chromosme location\t"
textentry += "Start CL\t"
textentry += "End CL\t"
textentry += "Quadruplex length\t"
textentry += "G run 1 length\t"
textentry += "Loop 1 length\t"
textentry += "Loop 1 Count A\t"
textentry += "Loop 1 Count A%\t"
textentry += "Loop 1 Count T\t"
textentry += "Loop 1 Count T%\t"
textentry += "Loop 1 Count G\t"
textentry += "Loop 1 Count G%\t"
textentry += "Loop 1 Count C\t"
textentry += "Loop 1 Count C%\t"
textentry += "G run 2 length\t"
textentry += "Loop 2 length\t"
textentry += "Loop 2 Count A\t"
textentry += "Loop 2 Count A%\t"
textentry += "Loop 2 Count T\t"
textentry += "Loop 2 Count T%\t"
textentry += "Loop 2 Count G\t"
textentry += "Loop 2 Count G%\t"
textentry += "Loop 2 Count C\t"
textentry += "Loop 2 Count C%\t"
textentry += "G run 3 length\t"
textentry += "Loop 3 length\t"
textentry += "Loop 3 Count A\t"
textentry += "Loop 3 Count A%\t"
textentry += "Loop 3 Count T\t"
textentry += "Loop 3 Count T%\t"
textentry += "Loop 3 Count G\t"
textentry += "Loop 3 Count G%\t"
textentry += "Loop 3 Count C\t"
textentry += "Loop 3 Count C%\t"
textentry += "G run 4 length\t"
textentry += "Sequence\n"

f2.write(textentry)
f3.write(textentry)

## Here you determine that the symbol you want to search for is g, meaning you want to look for instances with multiple g's in a row
searchsymbol = 'g'

while(line!=""):
    textentry =""
    workline = line.strip().split('\t')

    textentry = textentry + workline[0]+'\t' #Chromosome Location
    textentry = textentry + workline[1]+'\t' #Start
    textentry = textentry + workline[2]+'\t' #Stop
    textentry = textentry + workline[3]+'\t' #G4 length

    #start funky magic
    sign = workline[4]
    ## You want to harmonize all the lines and thus change everything to lower case for analysis
    g4 = workline[5].lower()

    ## Sometimes G4Catchall finds patterns corresponding to G4s in opposite strands so those will contain multiple c's in a row instead of g's.
    if sign == '-':
        ## We want to reverse the order of the strand to match what the G-rich strand would be
        g4 = g4[::-1]
        ## We want to change the sequence to its complement 
        g4 = g4.replace('g', 'z')
        g4 = g4.replace('c', 'g')
        g4 = g4.replace('a', 'l')
        g4 = g4.replace('t', 'a')
        g4 = g4.replace('z', 'c')
        g4 = g4.replace('l', 't')

    grun1 = symbollength(g4)
    textentry = textentry + str(grun1)+'\t' #G run 1
    g4 = g4[grun1:]

    loop1 = looplength(g4, searchsymbol)
    textentry = textentry + str(loop1)+'\t' #loop 1
    loopcc1 = loopcontentcount(g4, loop1)
    textentry = textentry + loopcc1 +'\t'
    g4 = g4[loop1:]

    grun2 = symbollength(g4)
    textentry = textentry + str(grun2)+'\t' #G run 2
    g4 = g4[grun2:]

    loop2 = looplength(g4, searchsymbol)
    textentry = textentry + str(loop2)+'\t' #loop 2
    loopcc2 = loopcontentcount(g4, loop2)
    textentry = textentry + loopcc2 +'\t'
    g4 = g4[loop2:]

    grun3 = symbollength(g4)
    textentry = textentry + str(grun3)+'\t' #G run 3
    g4 = g4[grun3:]

    loop3 = looplength(g4, searchsymbol)
    textentry = textentry + str(loop3)+'\t' #loop 3
    loopcc3 = loopcontentcount(g4, loop3)
    textentry = textentry + loopcc3 +'\t'

    g4 = g4[loop3:]

    grun4 = symbollength(g4)
    ## We have obesrved that sometimes there are only 3 Gruns instead of 4, meaning that one loop is inexistant. To account for that we added this line of code
    if grun4 == 0:
        textentry = textentry + "OneZeroLoop\t"
    else:
        textentry = textentry + str(grun4)+'\t' #G run 4
    #end

    sequence = workline[6]
    if sign == '-':
        inverse = sequence[::-1]
        textentry = textentry + inverse +'\n' #sequence
    else:
        textentry = textentry + sequence +'\n' #sequence


    ## We output the "normal" G4s to one file and the zero-loop G4s to a separate file to streamline analysis. 
    if grun4 != 0:
        f2.write(textentry)
    else:
        f3.write(textentry)

    line=f.readline()

f.close()
f2.close()
f3.close()
