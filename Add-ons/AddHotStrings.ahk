;; Andreas Borutta suggested the following script, which might be useful if you are a heavy user of hotstrings.
;;; By pressing Win+H (or another hotkey of your choice), the currently selected text can be turned into a
;;; hotstring. For example, if you have "by the way" selected in a word processor, pressing Win+H will prompt
;;; you for its abbreviation (e.g. btw) and then add the new hotstring to the script. It will then reload the
;;; script to activate the hotstring.

; Get the text currently selected. The clipboard is used instead of
; "ControlGet Selected" because it works in a greater variety of editors
; (namely word processors).  Save the current clipboard contents to be
; restored later. Although this handles only plain text, it seems better
; than nothing:

AddHotString(){
    g_HotStringsFile = %A_SCRIPTDIR%\MyHotStrings.ahk
;    msgbox %g_HotStringsFile%
    AutoTrim Off  ; Retain any leading and trailing whitespace on the clipboard.
    ClipboardOld = %ClipboardAll%
    Clipboard =  ; Must start off blank for detection to work.
    Send ^c
    ClipWait 1
    if ErrorLevel  ; ClipWait timed out.
        return
    ; Replace CRLF and/or LF with `n for use in a "send-raw" hotstring:
    ; The same is done for any other characters that might otherwise
    ; be a problem in raw mode:
    StringReplace, Hotstring, Clipboard, ``, ````, All  ; Do this replacement first to avoid interfering with the others below.
    StringReplace, Hotstring, Hotstring, `r`n, ``r, All  ; Using `r works better than `n in MS Word, etc.
    StringReplace, Hotstring, Hotstring, `n, ``r, All	
    StringReplace, Hotstring, Hotstring, %A_Tab%, ``t, All
    StringReplace, Hotstring, Hotstring, `;, ```;, All
    Clipboard = %ClipboardOld%  ; Restore previous contents of clipboard.

    ; This will move the InputBox's caret to a more friendly position:
    SetTimer, AddHotString_MoveCaret, 10

    InputBox, Hotstring, New Hotstring, Type your abreviation at the indicated insertion point. You can also edit the replacement text if you wish.`n`nExample entry: :R:btw`::by the way,,,,,,,, :R:`::%Hotstring%
    if ErrorLevel  ; The user pressed Cancel.
        return
    IfInString, Hotstring, :R`:::
    {
        MsgBox You didn't provide an abbreviation. The hotstring has not been added. ;'
        return
    }

    ; Otherwise, add the hotstring and reload the script:
    ; msgbox %A_SCRIPTDIR%
    FileAppend, `n%Hotstring%, %g_HotStringsFile%  ; Put a `n at the beginning in case file lacks a blank line at its end.
    ; FileAppend, %Hotstring%, %g_HotStringsFile%
    Reload
    Sleep 200 ; If successful, the reload will close this instance during the Sleep, so the line below will never be reached.
    MsgBox, 4,, The hotstring just added appears to be improperly formatted.  Would you like to open the script for editing? Note that the bad hotstring is at the bottom of the script.
    IfMsgBox, Yes, Edit
    return

    AddHotString_MoveCaret:
    IfWinNotActive, New Hotstring
        return
    ; Otherwise, move the InputBox's insertion point to where the user will type the abbreviation.
    Send {Home}{Right 3}
    SetTimer, AddHotString_MoveCaret, Off
    return
}

