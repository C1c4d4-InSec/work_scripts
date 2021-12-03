Attribute VB_Name = "Module1"
Option Explicit

' Created August 2021
' Daniel Luce and Matt Henry (mhenry@arcb.com)
' Financial Management Project Analysts
'
' This macro will attempt to go to the specified inbox and look for emails with
' the specified subject and attachment name in the getEmail() sub. Macro will
' exit if it doesn't encounter anything.
'
' Once downloaded, script will scrape the pronumbers and invoice numbers out of the excel
' file and send a query to the DB2P database then add the required info into the
' spreadsheet starting in cell D2.
'
' Once the queries are done, the script takes date codes and turns them into human-readable
' dates as well as convert the currency cells necessary. Once formatted, information is shunted
' off to the msgStringBuilder() in order to create a human-like response for customers. The
' string variable is a global variable so it can be accessed from anywhere.
'
' The sendMsg() sub will pull the sender's address, the subject, and the string message then send
' that information out to the customer requesting the information.


Public strMsg As String

Sub getEmail()

    'Declare necessary variables
    Dim olNamespace As Outlook.Namespace
    Dim olRecipient As Outlook.Recipient
    Dim olInbox As Outlook.MAPIFolder
    
    Dim Folder As Object
    Dim Email As Outlook.MailItem
    
    Dim intCount As Integer
    
    'Declare Strings
    Dim strInbox As String
    Dim strSubject As String
    Dim strAttach As String
    Dim strPath As String
    Dim strFile As String
    
    'Instantiate Variables. strInbox, strSubject, and strAttach shouldn't have to be changed,
    ' but strPath should be customized to whoever is using the script.
    strInbox = "financialservicesrpa@arcb.com"
    strSubject = "Truckload AP Automated Payment Status Request"
    
    'Build the path
    strPath = "C:\Users\GMAHENR\Desktop\Documents\Excel\"
    strAttach = "Truckload Automated Payment Status Form.xls"
    strFile = strPath + strAttach
    
    Set olNamespace = Outlook.GetNamespace("MAPI")
    olNamespace.Logon
    
    Set olRecipient = olNamespace.CreateRecipient(strInbox)
    Set olInbox = olNamespace.GetSharedDefaultFolder(olRecipient, olFolderInbox)
    
    ' Iterate through each email in the inbox.
    For Each Email In olInbox.Items
        
        ' Check the subject of each email, check for attachments.
        If Email.Subject = strSubject Then
               
            If Email.Attachments.Count > 0 Then

                ' User could have more than one attachment since we are limiting to 25 Pros per file
                For intCount = Email.Attachments.Count To 1 Step -1
                
                    If Email.Attachments.Item(intCount).Filename = strAttach Then
   
                        Debug.Print ("--------------------")
                    
                        ' Save the file to local disk
                        Email.Attachments.Item(intCount).SaveAsFile (strFile)
                        
                        ' Open the file as ReadOnly.
                        openAttachment strFile
                        
                        ' Read data, query is called from here as well
                        extractProAndInv
                        
                        ' Make the data prettier
                        formatWorksheet
                        
                        ' Build string to send to customer
                        msgStringBuilder
                        
                        ' Save data returned from query and added to the excel file.
                        saveFile
                        
                        ' Close the file
                        closeFile
                        
                        ' Send the built string
                        sendMsg Email.SenderEmailAddress, strSubject
                        
                        ' Delete the file that was downloaded
                        removeFile strFile
                        
                    End If
                Next intCount
            End If
        End If
' Continuation point
NextEmail:
    Next Email
    
    ' Clear objects
    Set olNamespace = Nothing
    Set olRecipient = Nothing
    Set olInbox = Nothing
    Set Folder = Nothing
    Set Email = Nothing
    
End Sub

Sub openAttachment(strFile As String)

    ' Open downloaded excel file.
    Workbooks.Open Filename:=strFile

End Sub

Sub extractProAndInv()

    ' Create variables
    Dim ws As Worksheet
    Dim rw As Range
    Dim strPro As String
    Dim strInvce As String
    
    ' Set the opened file as the active worksheet
    Set ws = ActiveSheet
    
    ' Check to make sure we have any pro numbers at all.
    If IsEmpty(Range("A2")) = True Then
        Debug.Print ("No pronumbers. Exiting.")
        Exit Sub
    End If
    
    ' Iterate through the rows that contain data
    For Each rw In ws.Range("A2:A" & ws.Rows.Count)
             
        ' Logic to check for invalid pronumbers. Based on containing 426 at beginning, and a length of 9.
        If InStr(ws.Cells(rw.row, 1).Value, "426") <> 1 Or Len(ws.Cells(rw.row, 1).Value) <> 9 Then
            strPro = Cells(rw.row, 1).Value
            Exit Sub
        End If
            
        ' Logic to check fo an invoice number. If invalid or non-existant, go to next row.
        If ws.Cells(rw.row, 2).Value = "" Or IsNumeric(ws.Cells(rw.row, 2).Value) = False Then
            strPro = Cells(rw.row, 1).Value
            ws.Cells(rw.row, 2).Value = "No Invoice #"
            GoTo ContinueRows
        
        ' Catch all pronumbers that made it through, add them to the string and send it on to the query.
        Else
            strPro = Cells(rw.row, 1).Value ' Pronumber cell
            strInvce = Cells(rw.row, 2).Value ' Invoice number cell
            getQuery strPro, strInvce, rw.row
            
        End If
        
        ' Loop kill switch
        If ws.Cells(rw.row + 1, 1).Value = "" Then
            Exit For
        End If
        
' GoTo point for Sub.
ContinueRows:
    Next rw

End Sub
Sub formatWorksheet()

    ' Create items
    Dim ws As Worksheet
    Dim rw As Range
    
    ' Set this sheet as active
    Set ws = ActiveSheet
    
    ' Loop through excel file and format currency and dates.
    For Each rw In ws.Range("A2:A" & ws.Rows.Count)
        ws.Range("I" & rw.row).NumberFormat = "mm/dd/yyyy"
        ws.Range("L" & rw.row).NumberFormat = "mm/dd/yyyy"
        ws.Range("M" & rw.row).NumberFormat = "$#,##0.00"
        
        ' Loop kill switch
        If ws.Cells(rw.row + 1, 1).Value = "" Then
            Exit For
        End If
    Next rw

End Sub

Sub msgStringBuilder()

    Dim ws As Worksheet
    Dim rw As Range

    Set ws = ActiveSheet
    
    ' Ensure string is empty
    strMsg = ""
    
    ' Loop through excel file and gather information, add it to the reply string.
    For Each rw In ws.Range("A2:A" & ws.Rows.Count)
    
        If IsEmpty(Range("A2")) = True Then
            Debug.Print ("No Pronumbers. Exiting")
            strMsg = "No Pronumbers provided."
            Exit Sub
        End If
        ' Check for present and valid pronumbers. Exit if wrong.
        If InStr(ws.Cells(rw.row, 1).Value, "426") <> 1 Or Len(ws.Cells(rw.row, 1).Value) <> 9 Then
            strMsg = "Invalid Pronumber."
            Exit For
        End If
        
        ' Logic to handle if there are no invoice numbers (first If) and to check if there is a payment status (ElseIf 1)
        ' Otherwise, collect the required information from excel into the string.
        If ws.Cells(rw.row, 2).Value = "" Or IsNumeric(ws.Cells(rw.row, 2).Value) = False Then
            strMsg = strMsg + vbNewLine & "Pronumber: " & Cells(rw.row, 1).Value & " Invoice Number: " & vbNewLine & vbTab & "No Invoice number provided. Please provide an invoice number."
            GoTo ContinueBuilding
            
        ElseIf Cells(rw.row, 4).Value <> "C" Or IsEmpty(Cells(rw.row, 4).Value) = True Then
            strMsg = strMsg & "Status: Invoice is currently being processed. No payment information available yet."
            GoTo ContinueBuilding
            
        ElseIf Cells(rw.row, 10).Value = "P" Then
            strMsg = strMsg & vbNewLine & "Pronumber: " & Cells(rw.row, 1).Value & ", Invoice Number: " & Cells(rw.row, 2).Value
            strMsg = strMsg & vbNewLine & vbTab & "Check: Date- " & Cells(rw.row, 12).Value & ", Number- " & Cells(rw.row, 11).Value & ", Amount- " & Cells(rw.row, 13).Value
        Else
            Debug.Print ("Error occurred in msgStringBuilder.")
        End If
        
        ' Loop kill switch
        If ws.Cells(rw.row + 1, 1).Value = "" Then
            Exit For
        End If
' GoTo point for Sub.
ContinueBuilding:
    Next rw
    
    ' Add automated message line to our string
    strMsg = strMsg + vbNewLine & vbNewLine & "This is an automated response."
    
    Debug.Print (strMsg)

End Sub

Sub saveFile()

    'Save the active workbook
    ActiveWorkbook.Save
    
End Sub

Sub closeFile()
    
    ' Close the workbook that is finished.
    ActiveWorkbook.Close
    
End Sub

Sub getQuery(strPro As String, strInvce As String, row As Integer)

    ' Create necessary items
    Dim wb As Workbook
    Dim ws As Worksheet
    Dim oRs As ADODB.recordSet
    Dim SQL As String
    
    Set wb = Application.ActiveWorkbook
    Set ws = wb.ActiveSheet

    ' Construct query string
    SQL = "SELECT TRIM(SNV.STATUS) AS INVOICE_STATUS " & vbCrLf
    SQL = SQL & ",INV.PO_NUMBER " & vbCrLf
    SQL = SQL & ",VND.VENDOR_NUMBER " & vbCrLf
    SQL = SQL & ",VND.ATTENTION " & vbCrLf
    SQL = SQL & ",INV.INVOICE_NUMBER " & vbCrLf
    SQL = SQL & ",INV.DUE_DATE" & vbCrLf
    SQL = SQL & ",INV.PAID_STATUS " & vbCrLf
    SQL = SQL & ",INV.CHECK_NUMBER " & vbCrLf
    SQL = SQL & ",CHK.CHECK_DATE " & vbCrLf
    SQL = SQL & ",CHK.CHECK_AMOUNT " & vbCrLf
    SQL = SQL & "FROM AB.APAB_SCANNED_INV AS SNV " & vbCrLf
    SQL = SQL & "LEFT JOIN AB.APAB_INVOICES AS INV " & vbCrLf
    SQL = SQL & "ON  INV.PO_NUMBER = SNV.PO_NUMBER " & vbCrLf
    SQL = SQL & "AND INV.COMPANY_NUMBER = SNV.COMPANY_NUMBER " & vbCrLf
    SQL = SQL & "AND SNV.VENDOR_NUMBER = INV.VENDOR_NUMBER " & vbCrLf
    SQL = SQL & "LEFT JOIN AB.APAB_VENDOR_MASTER AS VND " & vbCrLf
    SQL = SQL & "ON  INV.COMPANY_NUMBER = VND.COMPANY_NUMBER " & vbCrLf
    SQL = SQL & "AND INV.VENDOR_NUMBER = VND.VENDOR_NUMBER " & vbCrLf
    SQL = SQL & "AND INV.LOCATION = VND.LOCATION" & vbCrLf
    SQL = SQL & "LEFT JOIN AB.APAB_CHECKS AS CHK " & vbCrLf
    SQL = SQL & "ON  INV.CHECK_NUMBER = CHK.CHECK_NUMBER " & vbCrLf
    SQL = SQL & "AND INV.COMPANY_NUMBER = CHK.COMPANY_NUMBER" & vbCrLf
    SQL = SQL & "WHERE SNV.PO_NUMBER = '" & strPro & "' " & vbCrLf
    SQL = SQL & "AND INV.INVOICE_NUMBER = '" & strInvce & "' " & vbCrLf
    SQL = SQL & "AND SNV.COMPANY_NUMBER = '38' " & vbCrLf
    SQL = SQL & "AND VND.INTERLINE_FLAG = 'Y' " & vbCrLf
    SQL = SQL & "AND SNV.UPDATE_TIMESTAMP = (SELECT MAX(UPDATE_TIMESTAMP) " & vbCrLf
    SQL = SQL & "From AB.APAB_SCANNED_INV " & vbCrLf
    SQL = SQL & "WHERE PO_NUMBER = SNV.PO_NUMBER " & vbCrLf
    SQL = SQL & "AND VENDOR_NUMBER = SNV.VENDOR_NUMBER " & vbCrLf
    SQL = SQL & "AND COMPANY_NUMBER = SNV.COMPANY_NUMBER)" & vbCrLf
    
    'Debug.Print ("String formed")
    
    ' Execute the query
    On Error Resume Next
    Set oRs = ExecuteDB2SQL(SQL)
    
    If Err.Number <> 0 Then
        MsgBox (Err.Description)
    ElseIf oRs.EOF Then
        MsgBox ("No Results Found...")
    Else
        ws.Range("D" & row).CopyFromRecordSet oRs
        
        Set oRs = Nothing
    End If

End Sub

Sub sendMsg(strSender As String, strSubject As String)
    
    ' Create the outlook mail objects
    Dim olOutApp As Object
    Dim olOutMail As Object
    
    ' Set the outlook mail objects
    Set olOutApp = CreateObject("Outlook.Application")
    Set olOutMail = olOutApp.CreateItem(0)
    
    ' Compose and send email
    On Error Resume Next
    With olOutMail
        .To = strSender
        .CC = ""
        .BCC = ""
        .Subject = "Re: " & strSubject
        .Body = strMsg
        .Send
    End With
    
    ' clear objects
    Set olOutMail = Nothing
    Set olOutApp = Nothing
    
End Sub

Sub removeFile(strFile As String)

    'Debug.Print ("Removing: " & strFile)
    ' Set and delete the downloaded file
    SetAttr strFile, vbNormal
    Kill strFile
    
End Sub
