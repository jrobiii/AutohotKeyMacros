; List files in Clipboards folder
; Insert filenames (without extension) into Clipboards array
CbCount = 1
ClipboardName =Windows Clipboard
ClipboardsArray%CbCount% := ClipboardName

Loop ..\Clipboards\*.txt   ; This loop retrieves each line from the file, one at a time.
{
    CbCount += 1  ; Keep track of how many items are in the array.
    StringLeft, ClipboardName, A_LoopFileName, StrLen(A_LoopFileName) -4
    ClipboardsArray%CbCount% := ClipboardName  ; Store this line in the next array element.
}

; Loop %CbCount%
; {
; Read array
    ; The following line uses the := operator to retrieve an array element:
    ; element := ClipboardsArray%A_Index%  ; A_Index is a built-in variable.
    ; Alternatively, you could use the "% " prefix to make MsgBox or some other command expression-capable:
    ; MsgBox % "Element number " . A_Index . " is " . element
; }

Gui, Add, ListView, x16 y10 r%CbCount% w120 , Clipboard
Gui, Add, Button, x166 y10 w30 h30 , Okay
Loop %CbCount%{
    LV_Add("", ClipboardsArray%A_Index%)
}
LV_Modify(1, "Select")
ControlFocus, Button1
Gui, Show, x131 y91 h326 w399, New GUI Window
