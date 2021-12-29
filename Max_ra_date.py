# -*- coding: utf-8 -*-
"""
Created on Mon Dec 13 09:34:23 2021
This script will pull the max RA_DATE by pro and put them into a new sheet
@author: gmahenr
"""
import pandas as pd
# File path as a bytes object
filepath = r'C:\Users\gmahenr\Desktop\TELEDYNE.xlsx'
# Set the file
file = pd.ExcelFile(filepath)
# Create the dataframe
df1 = file.parse(sheet=0)
# Free the file from memory
file.close()
df2 = df1[df1.groupby('PRONUMBER')['RA_DATE'].transform('max') == df1['RA_DATE']]
df2.to_excel(r'C:\Users\gmahenr\Desktop\TELEDYNE_MAX.xlsx')