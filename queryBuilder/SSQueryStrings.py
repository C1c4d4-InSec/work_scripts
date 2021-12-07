# -*- coding: utf-8 -*-
"""
Created on Mon Dec  6 13:20:05 2021
@author: gmahenr
This is the master query string list for the query
generator app.
"""

#ABDW.RA_BASE_BILL_PROS B
selBOLStr = '\t,B.BOL_AGE_DATE AS BOL_DATE\n'
selBOLAgeStr = '\t,B.BOL_AGE AS BOL_AGE\n'
selRAROStr = '\t,B.RA_RECEIVABLE_OUT AS OPEN_AMT\n'
selReceivableStr = '\t,B.RA_RECEIVABLE AS TOTAL_CHARGE\n'
selWeightStr = '\t,B.WEIGHT AS WEIGHT\n'
selCompanyNumberStr = '\t,B.COMPANY_NUMBER AS COMPANY_NUM\n'
selDeliveryReportedStr = '\t,B.DELIVERY_REPORTED AS DELIVERY_DATE\n'
selRAStaChargeStr = '\t,B.STA_RA_CHARGE AS CHARGE_STATION\n'
selPiecesCountStr = '\t,B.PIECES AS PIECES_COUNT\n'

# ABDW.RA_BASE_NAME S
selShipNameStr = '\t,S.NAME AS SHIP_NAME\n'
selShipAddrStr = '\t,S.ADDRESS_LINE2 AS SHIP_ADDR\n'
selShipCityStr = '\t,S.CITY AS SHIP_CITY\n'
selShipStateStr = '\t,S.STATE AS SHIP_STATE\n'
selShipZipStr = '\t,S.ZIPCODE AS SHIP_ZIP\n'
selShipCountryStr = '\t,S.COUNTRY AS Ship_COUNTRY\n'

# ABDW.RA_BASE_NAME C
selConsNameStr = '\t,C.NAME AS CONS_NAME\n'
selConsAddrStr = '\t,C.ADDRESS_LINE2 AS CONS_ADDR\n'
selConsCityStr = '\t,C.CITY AS CONS_CITY\n'
selConsStateStr = '\t,C.STATE AS CONS_STATE\n'
selConsZipStr = '\t,C.ZIPCODE AS CONS_ZIP\n'
selConsCountryStr = '\t,C.COUNTRY AS CONS_COUNTRY\n'

# ABDW.RA_BASE_INVOICE_DATA I
selAccessorialsStr = '\t,I.ACCESSORIALS AS ACCESSORIALS\n'
selBOLNumbersStr = '\t,I.REFNO_BOL AS BOL_NUMA\n'
selPONumbersStr = '\t,I.REFNO_PO_NUMBERS AS PO_NUMS\n'

strQueryBase = '\nFROM ABDW.RA_BASE_BILL_PROS B\n'

strShipperBase = """
JOIN ABDW.RA_BASE_NAME S
\tON B.PRONUMBER = S.PRONUMBER
\tAND B.RA_DATE = S.RA_DATE
\tAND B.PRONUMBER = S.PRONUMBER
\tAND S.TYPE='S'
"""
    
strConsBase = """
JOIN ABDW.RA_BASE_NAME C
\tON B.PRONUMBER = C.PRONUMBER
\tAND B.RA_DATE = C.RA_DATE
\tAND B.PRONUMBER = C.PRONUMBER
\tAND C.TYPE='C'
"""

strInvoiceDataBase = """
JOIN ABDW.RA_BASE_INVOICE_DATA I
\tON B.PRONUMBER = I.PRONUMBER
\tAND B.RA_DATE = I.RA_DATE
"""

queryList = [
             selBOLStr,
             selBOLAgeStr,
             selRAROStr,
             selReceivableStr,
             selWeightStr,
             selCompanyNumberStr,
             selRAStaChargeStr,
             selPiecesCountStr,
             selDeliveryReportedStr,
             selShipNameStr,
             selShipAddrStr,
             selShipCityStr,
             selShipStateStr,
             selShipZipStr,
             selShipCountryStr,
             selConsNameStr,
             selConsAddrStr,
             selConsCityStr,
             selConsStateStr,
             selConsZipStr, 
             selConsCountryStr,
             selAccessorialsStr,
             selBOLNumbersStr,
             selPONumbersStr
             ]

queryBaseList = [strShipperBase, strConsBase, strInvoiceDataBase]