# -*- coding: utf-8 -*-
"""
Created on Mon Nov 29 13:25:46 2021
@author: gmahenr
Very specific use cases. 
Column 1 is pronumbers.
Column 2 is a concatonated list of items and prices.
Column 2 format is BILLCODE; PRICE, repeat.
>> i.e., DISC; -237.27, FSC; 53.60, MCADJ; 130.92, TIPU...
"""

import pandas as pd
import tkinter as tk
from tkinter import filedialog as fd
import sys

# Open up file dialog to ask for file to split.
try:
    root = tk.Tk()
    root.withdraw()
    file_path = fd.askopenfilename()
    root.update()
except Exception as err:
    sys.exit('[-] Something went wrong:', err)
    
# Take opened file and import as dataframe in Pandas.
try:
    file = pd.ExcelFile(file_path)
except Exception as err:
    sys.exit('[-] Something went wrong:', err)
    
# Open the first sheet in the file.
df = file.parse(sheet_name=0)

# CLose the file, free up memory.
file.close()

# Grab the column names in the file.
column_list = list(df)

# Commence splitting apart the billcodes and costs.
df[column_list[1]] = df[column_list[1]].str.split(',')

# Fill in NaNs with 0s
df.fillna(0, inplace=True)

# Make the DF a list; easier to work with for me.
zip1 = zip(df[column_list[0]], df[column_list[1]])
list2 = list(zip1)

# Get rid of excess spaces.
for item in list2:
    if item[1] == 0:
        continue
    else:
        for i in range(0, len(item[1])):
             item[1][i] = item[1][i].split(';')
             item[1][i][1] = item[1][i][1].strip()

# Get a list of unique bill codes.
codeList = ''
     
for key, item in list2:
    if item == 0:
        continue
    else:
        for x in item:
            for i in range(0,1):
                codeList += x[i].strip() + ','

# Full clean split list of bill codes.            
codeList = codeList.split(',')

# Make a list for the unique bill codes.
uniqueCodes = []

# Fill the blank list with the unique codes, sort them,
# and remove the empty columns as necessary.
for i in range (0, len(codeList)):
    if codeList[i] not in uniqueCodes:
        uniqueCodes.append(codeList[i])        
   
uniqueCodes.sort()
uniqueCodes.remove('')

# Create list of pros.
proList = []
for item in df[column_list[0]]:
    proList.append(item)

# Create new data frame with columns of the unique bill codes.
df2 = pd.DataFrame([],
                   index=[proList],
                   columns=[uniqueCodes])

# Import costs from first DF, add to columns corresponding to pronumber.
for item in list2:
    if item[1] == 0:
        continue
    else:
        for x in item[1]:
            #print(item[0])
            df2.loc[[item[0]], x[0].strip()] = x[1]

# Add 0 to all empty cells.        
df2.fillna(0, inplace=True)

# Extract original filename then save the new DF as an excel file.
filesave = file_path.split('/')
filesave = filesave[-1].split('.')
filesave = filesave[0]
filesave += '_split.xlsx'

try:
    df2.to_excel('../Desktop/' + filesave)
except Exception as err:
    sys.exit('[-] Something went wrong:', err)
