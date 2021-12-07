# -*- coding: utf-8 -*-
"""
Created on Mon Dec  6 13:34:49 2021
@author: gmahenr
"""

import tkinter as tk
from datetime import datetime, timedelta
import SSQueryStrings as q

class buildGui:
    
    def __init__(self, parent):
        
        self.parent = parent
        self.frame = tk.Frame(parent)
        self.frame.grid()
        
        # Configure the rows for the interface
        self.frame.rowconfigure([0,9], minsize=20)
        self.frame.columnconfigure([0,6], minsize=30)
        
        # BOOLEAN VARIABLES -------------------------------------------------     
        # Base Info Booleans
        self.selBOLBool = tk.BooleanVar()
        self.selBOLAgeBool = tk.BooleanVar()
        self.selRAROBool = tk.BooleanVar()
        self.selReceivableBool = tk.BooleanVar()
        self.selWeightBool = tk.BooleanVar()
        self.selDeliveryDateBool = tk.BooleanVar()
        self.selCompanyNumberBool = tk.BooleanVar()
        self.selRAStaChargeBool = tk.BooleanVar()
        self.selPiecesCountBool = tk.BooleanVar()
        # Shipper Info Booleans
        self.selShipNameBool = tk.BooleanVar()
        self.selShipAddrBool = tk.BooleanVar()
        self.selShipCityBool = tk.BooleanVar()
        self.selShipStateBool = tk.BooleanVar()
        self.selShipZipBool = tk.BooleanVar()
        self.selShipCountryBool = tk.BooleanVar() 
        # Consignee Info Booleans
        self.selConsNameBool = tk.BooleanVar()
        self.selConsAddrBool = tk.BooleanVar()
        self.selConsCityBool = tk.BooleanVar()
        self.selConsStateBool = tk.BooleanVar()
        self.selConsZipBool = tk.BooleanVar()
        self.selConsCountryBool = tk.BooleanVar()       
        # Invoice Data Booleans
        self.selAccessorialsBool = tk.BooleanVar()
        self.selBOLNumbersBool = tk.BooleanVar()
        self.selPONumbersBool = tk.BooleanVar()
        # END BOOLEAN VARIABLES ---------------------------------------------
        
        # LABELS ------------------------------------------------------------
        # Headline Label
        self.headline = tk.Label(self.frame, text='Select Parameters')
        self.baseBillsLabel = tk.Label(self.frame, text='Base')
        self.shipNameLabel = tk.Label(self.frame, text='Shipper')
        self.consNameLabel = tk.Label(self.frame, text='Consignee')
        self.invoiceDataLabel = tk.Label(self.frame, text='Invoice Data')
        self.requiredInfoLabel = tk.Label(self.frame, text='Required Info')
        self.acctLabel = tk.Label(self.frame, text='Account:')
        self.optionalInfoLabel = tk.Label(self.frame, text='Optional Info')
        self.dateRangeLabel = tk.Label(self.frame, text='Date Range:')
        self.companyNumberLabel = tk.Label(self.frame, text='Company Number:')
        self.chargeStationLabel = tk.Label(self.frame, text='Charge Station:')
        # END LABELS --------------------------------------------------------
        
        # CHECKBOXES --------------------------------------------------------
        # Base Elements
        self.selBOLCheck = tk.Checkbutton(self.frame, text='BOL Date', variable = self.selBOLBool)
        self.selBOLAgeCheck = tk.Checkbutton(self.frame, text='BOL Age', variable = self.selBOLAgeBool)
        self.selRAROCheck = tk.Checkbutton(self.frame, text='Open Amount', variable = self.selRAROBool)
        self.selReceivableCheck = tk.Checkbutton(self.frame, text='Total Charge', variable = self.selReceivableBool)
        self.selPiecesCountCheck = tk.Checkbutton(self.frame, text='Pieces', variable = self.selPiecesCountBool)
        self.selWeightCheck = tk.Checkbutton(self.frame, text='Weight', variable = self.selWeightBool)
        self.selDeliveryDateCheck = tk.Checkbutton(self.frame, text='Delivery Date', variable = self.selDeliveryDateBool)
        self.selRAStaChargeCheck = tk.Checkbutton(self.frame, text='Charge Station', variable = self.selRAStaChargeBool)
        self.selCompanyNumberCheck = tk.Checkbutton(self.frame, text='Company Number', variable = self.selCompanyNumberBool)
        # Shipper Elements
        self.selShipNameCheck = tk.Checkbutton(self.frame, text='Name', variable = self.selShipNameBool)
        self.selShipAddrCheck = tk.Checkbutton(self.frame, text='Address', variable = self.selShipAddrBool)
        self.selShipCityCheck = tk.Checkbutton(self.frame, text='City', variable = self.selShipCityBool)
        self.selShipStateCheck = tk.Checkbutton(self.frame, text='State', variable = self.selShipStateBool)
        self.selShipZipCheck = tk.Checkbutton(self.frame, text='Zipcode', variable = self.selShipZipBool)
        self.selShipCountryCheck = tk.Checkbutton(self.frame, text='Country', variable = self.selShipCountryBool)      
        # Consignee Elements
        self.selConsNameCheck = tk.Checkbutton(self.frame, text='Name', variable = self.selConsNameBool)
        self.selConsAddrCheck = tk.Checkbutton(self.frame, text='Address', variable = self.selConsAddrBool)
        self.selConsCityCheck = tk.Checkbutton(self.frame, text='City', variable = self.selConsCityBool)
        self.selConsStateCheck = tk.Checkbutton(self.frame, text='State', variable = self.selConsStateBool)
        self.selConsZipCheck = tk.Checkbutton(self.frame, text='Zipcode', variable = self.selConsZipBool)
        self.selConsCountryCheck = tk.Checkbutton(self.frame, text='Country', variable = self.selConsCountryBool)  
        # Invoice Data Elements
        self.selAccessorialCheck = tk.Checkbutton(self.frame, text='Accessorials', variable = self.selAccessorialsBool)
        self.selBOLNumbersBoolCheck = tk.Checkbutton(self.frame, text='BOL Number(s)', variable = self.selBOLNumbersBool)
        self.selPONumbersBoolCheck = tk.Checkbutton(self.frame, text='PO Number(s)', variable = self.selPONumbersBool)
        # END CHECKBOXES ----------------------------------------------------
                
        # BUTTONS AND MISC --------------------------------------------------
        # Account Number Entry Box
        self.accountNumberInput = tk.Entry(self.frame)
        # Date Range Entry Boxes
        self.dateRangeInput1 = tk.Entry(self.frame)
        self.dateRangeInput2 = tk.Entry(self.frame)
        # Charge Station Entry Box
        self.chargeStationInput = tk.Entry(self.frame)
        # Company Number Input Box
        self.companyNumberInput = tk.Entry(self.frame)
        # Search Parameters
        ## Open Balance Only !!!!!!!!!!!!
        # Big Text Box
        self.txtBox = tk.Text(self.frame, height=35)
        # Copy to Clipboard Button
        self.copyToClipBoardButton = tk.Button(self.frame, text='Copy to Clipboard', command=self.copyToClipboard)
        # Save Button
        self.saveAsButton = tk.Button(self.frame, text='Save', command=self.saveToFile)
        # Send to Excel Button
        self.sendToExcelButton = tk.Button(self.frame, text='Send to Excel')
        # Submit/Generate Button
        self.submitButton = tk.Button(self.frame, text="Generate", command=self.get_values)
        # END BUTTONS AND MISC ----------------------------------------------
        
        # GRID SETTINGS -----------------------------------------------------        
        # Headline
        self.headline.grid(row=0, columnspan=6)
        # Base Info Positions
        self.baseBillsLabel.grid(row=1, column=0, columnspan=2)
        self.selBOLCheck.grid(sticky='W', row=2, column=0)
        self.selPiecesCountCheck.grid(sticky='W', row=3, column=0 )
        self.selBOLAgeCheck.grid(sticky='W', row=4, column=0)
        self.selRAROCheck.grid(sticky='W', row=5, column=0)
        self.selReceivableCheck.grid(sticky='W', row=6, column=0)
        self.selWeightCheck.grid(sticky='W', row=2, column=1 )
        self.selDeliveryDateCheck.grid(sticky='W', row=3, column=1)
        self.selCompanyNumberCheck.grid(sticky='W', row=4, column=1)
        self.selRAStaChargeCheck.grid(sticky='W', row=5, column=1)        
        # Shipper Info Potisions
        self.shipNameLabel.grid(row=1, column=2)
        self.selShipNameCheck.grid(sticky='W', row=2, column=2)
        self.selShipAddrCheck.grid(sticky='W', row=3, column=2)
        self.selShipCityCheck.grid(sticky='W', row=4, column=2)
        self.selShipStateCheck.grid(sticky='W', row=5, column=2)
        self.selShipZipCheck.grid(sticky='W', row=6, column=2)
        self.selShipCountryCheck.grid(sticky='W', row=7, column=2)  
        # Consignee Info Positions
        self.consNameLabel.grid(row=1, column=3)
        self.selConsNameCheck.grid(sticky='W', row=2, column=3)
        self.selConsAddrCheck.grid(sticky='W', row=3, column=3)
        self.selConsCityCheck.grid(sticky='W', row=4, column=3)
        self.selConsStateCheck.grid(sticky='W', row=5, column=3)
        self.selConsZipCheck.grid(sticky='W', row=6, column=3)
        self.selConsCountryCheck.grid(sticky='W', row=7, column=3)  
        # Invoice Data Positions
        self.invoiceDataLabel.grid(row=1, column=4)
        self.selAccessorialCheck.grid(sticky='W', row=2, column=4)
        self.selBOLNumbersBoolCheck.grid(sticky='W', row=3, column=4)
        self.selPONumbersBoolCheck.grid(sticky='W', row=4, column=4)
        # Required User Input Positions
        self.requiredInfoLabel.grid(row=0, column=5)
        self.acctLabel.grid(row=1, column=5)
        self.accountNumberInput.grid(row=2, column=5)
        # Optional User Input Positions
        self.optionalInfoLabel.grid(row=0, column=6)
        self.dateRangeLabel.grid(row=1,column=6)
        self.dateRangeInput1.grid(row=2,column=6)
        self.dateRangeInput2.grid(row=3,column=6)
        self.chargeStationLabel.grid(row=4,column=6)
        self.chargeStationInput.grid(row=5, column=6)
        self.companyNumberLabel.grid(row=6, column=6)
        self.companyNumberInput.grid(row=7, column=6)
        # Submit Button
        self.submitButton.grid(row=7,column=5)
        # BigText Box
        self.txtBox.grid(row=9, columnspan=7)
        # Bottom Buttons
        self.copyToClipBoardButton.grid(row=10, column=4)
        self.saveAsButton.grid(row=10, column=5, ipadx=30)
        self.sendToExcelButton.grid(row=10, column=6, ipadx=25)
        # END GRID SETTINGS -------------------------------------------------
        
        
    def saveToFile(self):
        
        # Get the textbox and assign to string
        text = self.txtBox.get('1.0', tk.END)
        
        # Get Current Date
        date = datetime.now()
        date = datetime.strftime(date, '%m-%d-%Y')
        
        # Filename generator
        filename = 'query_'+self.accountNumberInput.get()+'_'+date+'.sql'
        # Write the lines to a file: query_ACCOUNT_DATE.sql
        with open(filename, 'w') as file:
            file.writelines(text)
            
        # Notify user
        self.txtBox.delete('1.0', tk.END)
        self.txtBox.insert(tk.END,filename + ' has been saved to the current directory.')

        
    def copyToClipboard(self):
        
        # Get the textbox and assign to string
        text = self.txtBox.get('1.0', tk.END)
        
        # Clear the current clipboard
        self.frame.clipboard_clear()
        
        # Add to clipboard
        self.frame.clipboard_append(text)
        
    def buildQuery(self, boolList, accountStr, chargeStaStr, companyNumberStr, dateRangeStr, raDateStr):
        
        # Start the query string
        queryString = 'SELECT\n\tB.PRONUMBER\n'
    
        # Using the boolList, add those that are true to the query.
        for x in range(0, len(boolList)):
            if boolList[x] == True:
                queryString += q.queryList[x]
        queryString += q.strQueryBase
        
        # If any info is needed from tables, add that table.
        if any([boolList[9], boolList[10], boolList[11], boolList[12], boolList[13], boolList[14]]):
            queryString += q.queryBaseList[0]
        if any([boolList[15], boolList[16], boolList[17], boolList[18], boolList[19], boolList[20]]):
            queryString += q.queryBaseList[1]
        if any([boolList[21], boolList[22], boolList[23]]):
            queryString += q.queryBaseList[2]
        
        # Add account string and RA_DATE as necessary information
        queryString += '\nWHERE B.CAN_RA_PAYING_CUST = \'' + accountStr.strip() + '\'\n'
        queryString += '\tAND B.RA_DATE = \'' + raDateStr + '\'\n'
        
        # Add optionals. If empty, does nothing.
        queryString += chargeStaStr
        queryString += companyNumberStr
        queryString += dateRangeStr
        
        return queryString
        
    def get_values(self):
    
        # Clear the Text Box
        self.txtBox.delete('1.0', tk.END)
        
        # Create the list of booleans to check
        boolList = [
                    self.selBOLBool.get(),
                    self.selBOLAgeBool.get(),
                    self.selRAROBool.get(),
                    self.selReceivableBool.get(),
                    self.selWeightBool.get(),
                    self.selCompanyNumberBool.get(),
                    self.selRAStaChargeBool.get(),
                    self.selPiecesCountBool.get(),
                    self.selDeliveryDateBool.get(),
                    self.selShipNameBool.get(),
                    self.selShipAddrBool.get(),
                    self.selShipCityBool.get(),
                    self.selShipStateBool.get(),
                    self.selShipZipBool.get(),
                    self.selShipCountryBool.get(),
                    self.selConsNameBool.get(),
                    self.selConsAddrBool.get(),
                    self.selConsCityBool.get(), 
                    self.selConsStateBool.get(),
                    self.selConsZipBool.get(),
                    self.selConsCountryBool.get(),
                    self.selAccessorialsBool.get(),
                    self.selBOLNumbersBool.get(),
                    self.selPONumbersBool.get()
                    ]

        # Check the account number length. 
        if len(self.accountNumberInput.get()) != 6:
            self.txtBox.delete('1.0', tk.END)
            self.txtBox.insert(tk.END,'Please enter a valid account number.')
            return
        else:
            accountStr = self.accountNumberInput.get()
            
        # Get date ranges, apply applicable string to the query.
        if self.dateRangeInput1.get() != '' and self.dateRangeInput2.get() != '':
            dateRangeStr = '\tAND B.BOL_AGE_DATE BETWEEN \'' + self.dateRangeInput1.get().strip() + '\' AND \'' + self.dateRangeInput2.get() + '\'\n'
        elif self.dateRangeInput1.get() != '' and self.dateRangeInput2.get() == '':
            dateRangeStr = '\tAND B.BOL_AGE_DATE > \'' + self.dateRangeInput1.get().strip() + '\'\n'
        else:
            dateRangeStr = ''
            
        # Check if a charge station is provided
        if len(self.chargeStationInput.get()) != 3 and self.chargeStationInput.get() != '':
            self.txtBox.delete('1.0', tk.END)
            self.txtBox.insert(tk.END,'Please enter a valid charge station.')
        elif self.chargeStationInput.get() != '':
            chargeStaStr = '\tAND B.STA_RA_CHARGE = \'' + self.chargeStationInput.get().strip() + '\'\n'
        else:
            chargeStaStr = ''
            
        # Check if company number is provided
        if len(self.companyNumberInput.get()) != 2 and self.companyNumberInput.get() != '':
            self.txtBox.delete('1.0', tk.END)
            self.txtBox.insert(tk.END,'Please enter a valid company number.')
        elif self.companyNumberInput.get() != '':
            companyNumberStr = '\tAND B.COMPANY_NUMBER = \'' + self.companyNumberInput.get().strip() + '\'\n'
        else:
            companyNumberStr = ''
        
        # Get B.RA_DATE = CURRENT_DATE - 1 DAYS
        raDateStr = datetime.now() - timedelta(1)
        raDateStr = datetime.strftime(raDateStr, '%m/%d/%Y')
        
        # Send the info off the the query builder
        self.txtBox.insert(tk.END, self.buildQuery(boolList, accountStr, chargeStaStr, companyNumberStr, dateRangeStr, raDateStr))       
        
def main():
    root = tk.Tk()
    buildGui(root)
    root.mainloop()
    
if __name__ == '__main__':
    main()