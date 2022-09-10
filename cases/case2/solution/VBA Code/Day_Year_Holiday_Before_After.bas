Attribute VB_Name = "Day_Year_Holiday_Before_After"
Sub Fill_day_year_holiday()
    
    NumRows = Cells(Rows.Count, 6).End(xlUp).Row
    Dim a As Date
    
    For x = 2 To NumRows
           
        Cells(x, 8).Value = Month(Cells(x, 6).Value)
        'Cells(x, 11).Value = Date_to_Holiday_Period(Cells(x, 6).Value)
      
        
        'Cells(x, 2).Value = Year(Cells(x, 6).Value)
        'Cells(x, 2).Value = Date_to_Month(Cells(x, 5).Value)
        'Cells(x, 3).Value = Date_to_Day(Cells(x, 5).Value)
        'Cells(x, 4).Value = Date_to_Season((Cells(x, 5).Value))
    'holiday = Date_to_Holiday(Cells(x, 6).Value)
    ' If holiday <> "" Then
    '      Cells(x, 11).Value = holiday
    '   End If
    Next x
        
        
    'Call saveFile
    
End Sub
Function Date_to_Day(Input_date As Date) As String

    date_number = Weekday(Input_date, vbMonday)
    
    Select Case date_number
        Case 1
            Date_to_Day = "Monday"
        Case 2
            Date_to_Day = "Tuesday"
        Case 3
            Date_to_Day = "Wednesday"
        Case 4
            Date_to_Day = "Thursday"
        Case 5
            Date_to_Day = "Friday"
        Case 6
            Date_to_Day = "Saturday"
        Case 7
            Date_to_Day = "Sunday"
    
    End Select
    
    
End Function
Function Date_to_Month(Input_date As Date) As String

    month_number = Month(Input_date)
    
    Select Case month_number
        Case 1
            Date_to_Month = "January"
        Case 2
            Date_to_Month = "February"
        Case 3
            Date_to_Month = "March"
        Case 4
            Date_to_Month = "April"
        Case 5
            Date_to_Month = "May"
        Case 6
            Date_to_Month = "June"
        Case 7
            Date_to_Month = "July"
        Case 8
            Date_to_Month = "August"
        Case 9
            Date_to_Month = "September"
        Case 10
            Date_to_Month = "October"
        Case 11
            Date_to_Month = "November"
        Case 12
            Date_to_Month = "December"
    
    End Select
    
    
End Function

Function Date_to_Season(Input_date As Date) As String

    day_number = Day(Input_date)
    month_number = Month(Input_date)
    year_number = Year(Input_date)
    
    If month_number < 3 Or (month_number = 3 And day_number < 20) Or (month_number = 12 And day_number >= 21) Then
        Date_to_Season = "Winter"
        
    ElseIf month_number < 6 Or (month_number = 6 And day_number < 21) Then
        Date_to_Season = "Spring"
        
    ElseIf month_number < 9 Or (month_number = 9 And day_number < 22) Then
        Date_to_Season = "Summer"
    Else
        Date_to_Season = "Fall"
    
    End If
    
End Function

Function Date_to_Holiday(Input_date As Date) As String

    day_number = Day(Input_date)
    month_number = Month(Input_date)
    year_number = Year(Input_date)
    
    If month_number = 1 And day_number = 1 Then
        Date_to_Holiday = "New Year"
        
    ElseIf month_number = 3 And day_number = 3 Then
        Date_to_Holiday = "Liberation day"
        
    ElseIf month_number = 5 And day_number = 6 Then
        Date_to_Holiday = "George's day"
        
    ElseIf month_number = 5 And day_number = 24 Then
        Date_to_Holiday = "Day of Slavonic alphabet"
        
    ElseIf month_number = 6 And day_number = 1 Then
        Date_to_Holiday = "Labour Day"
    
    ElseIf month_number = 9 And day_number = 6 Then
        Date_to_Holiday = "Unification day"
    
    ElseIf month_number = 9 And day_number = 22 Then
        Date_to_Holiday = "Independance day"
        
    ElseIf month_number = 12 And (day_number = 22 Or day_number = 23 Or day_number = 24) Then
        Date_to_Holiday = "Christmas"
        
    ElseIf year_number = 2020 And month_number = 4 And (day_number = 17 Or day_number = 18 Or day_number = 19 Or day_number = 20) Then
        Date_to_Holiday = "Easter"
        
    ElseIf year_number = 2021 And month_number = 4 And day_number = 30 Then
        Date_to_Holiday = "Easter"
        
    ElseIf year_number = 2021 And month_number = 5 And (day_number = 2 Or day_number = 3) Then
        Date_to_Holiday = "Easter"
    
    End If
    
End Function

Function Date_to_Holiday_Period(Input_date As Date) As String

    Dim date_x As Date
    
    Dim Holidays_2020(14) As Date
    
    Holidays_2020(1) = DateValue("1/1/2020")   'New Year"
    Holidays_2020(2) = DateValue("3/3/2020")   'Liberation day"
    Holidays_2020(3) = DateValue("5/6/2020")   'Georgy's day"
    Holidays_2020(4) = DateValue("4/17/2021")  'Easter"
    Holidays_2020(4) = DateValue("4/18/2021")  'Easter"
    Holidays_2020(5) = DateValue("4/19/2021")  'Easter"
    Holidays_2020(6) = DateValue("4/20/2021")  'Easter"
    Holidays_2020(7) = DateValue("5/24/2020")  'Day of Slavonic alphabet"
    Holidays_2020(8) = DateValue("6/1/2020")   'Labor day"
    Holidays_2020(9) = DateValue("9/6/2020")   'Unification day"
    Holidays_2020(10) = DateValue("9/22/2020")  'Independance day
    Holidays_2020(11) = DateValue("12/22/2020") 'Christ
    Holidays_2020(12) = DateValue("12/23/2020") 'Christ
    Holidays_2020(13) = DateValue("12/24/2020") 'Christ
    
    Dim Holidays_2021(13) As Date
    
    Holidays_2021(1) = DateValue("1/1/2021")  'New Year
    Holidays_2021(2) = DateValue("3/3/2021")   'Liberation day"
    Holidays_2021(3) = DateValue("5/6/2021")   'Georgy's day"
    Holidays_2021(4) = DateValue("4/30/2021")  'Day of Slavonic alphabet"
    Holidays_2021(5) = DateValue("5/2/2021")  'Easter"
    Holidays_2021(6) = DateValue("5/3/2021")  'Easter"
    Holidays_2021(7) = DateValue("5/24/2021")  'Easter"
    Holidays_2021(8) = DateValue("6/1/2021")   'Labor day"
    Holidays_2021(9) = DateValue("9/6/2021")  'Unification day"
    Holidays_2021(10) = DateValue("9/22/2021") 'Independance day"
    Holidays_2021(11) = DateValue("12/22/2021") 'Christ
    Holidays_2021(12) = DateValue("12/23/2021") 'Christ
    Holidays_2021(13) = DateValue("12/24/2021") 'Christ
    
 
    If Year(Input_date) = 2020 Then
    
        For i = 1 To 13
            date_x = Holidays_2020(i)
            If DateDiff("d", date_x, Input_date) >= 0 And DateDiff("d", date_x, Input_date) < 5 Then
        
                Date_to_Holiday_Period = "After"
                Exit For
            
            ElseIf DateDiff("d", Input_date, date_x) > 0 And DateDiff("d", Input_date, date_x) < 5 Then
               
                Date_to_Holiday_Period = "Before"
                Exit For
         
            End If
        Next i
        
    ElseIf Year(Input_date) = 2021 Then
    
        For i = 1 To 13
            date_x = Holidays_2021(i)
                
            If DateDiff("d", date_x, Input_date) >= 0 And DateDiff("d", date_x, Input_date) < 5 Then
        
                Date_to_Holiday_Period = "After"
                Exit For
                
            ElseIf DateDiff("d", Input_date, date_x) > 0 And DateDiff("d", Input_date, date_x) < 5 Then
                
                Date_to_Holiday_Period = "Before"
                Exit For
            
            End If
            
        Next i
           
    End If
    
End Function


Sub saveFile()

   
    save_name = "C:\Users\atanas.troyanov\Desktop\manual_offer_edited.xlsx"
    
    ActiveWorkbook.SaveAs Filename:=save_name, FileFormat:=51
    
    If save_name <> False Then
        MsgBox "Save as " & save_name
    End If
End Sub
Sub Fill_Blanks()
    
    NumRows = Cells(Rows.Count, 6).End(xlUp).Row

    For x = 2 To NumRows
        
        If Cells(x, 1).Value = "" Then
           
            If (Cells(x, 4).Value = "Saturday" Or Cells(x, 4).Value = "Sunday") Then
                Cells(x, 1).Value = "Weekend"
            Else
                Cells(x, 1).Value = "Workday"
            End If
        
        End If
        
    Next x
        
    
End Sub


