; Stuff to do when Windows Explorer is open
;
SetTitleMatchMode, RegEx

#IfWinactive ahk_class (CabinetWClass|ExploreWClass)
    ; Much more convenient to <Alt>N then <Shift><Ctrl>N for a new folder
    !n::Send ^+N

    ; Need to revist this as it is not opening in the current directory
    !c::OpenCmdInCurrent() ; open 'cmd' in the current directory
	
	; Copy full file name and path to clipboard
    ^t::
       Send, ^c
       ClipWait
       Sort, clipboard  ; This also converts to text (full path and name of each file).
    return
	
	;Copy only the file name to clipboard
    ^#t::
        ClipString := ""
        ;clipboard =
        Send, ^c

        ClipWait
        loop, parse, clipboard,`n
        {
            reverse := Flip(A_LoopField)
            FoundPos := RegExMatch(reverse, "\\") -1
            FileName := Flip(SubStr(reverse,1,FoundPos))
            ClipString = %ClipString%%FileName%`n
        }

        clipboard := ClipString
    return

#IfWinActive

; New text document
#IfWinactive ahk_class (CabinetWClass|ExploreWClass)
!f:: ;explorer - create new text file and focus/select it
;note: similar to: right-click, New, Text Document
vNameNoExt := "New Text Document"
vDotExt := ""
WinGet, hWnd, ID, A
for oWin in ComObjCreate("Shell.Application").Windows
{
	if (oWin.HWND = hWnd)
	{
		vDir := RTrim(oWin.Document.Folder.Self.Path, "\")
		;if !DirExist(vDir)
		if !InStr(FileExist(vDir), "D")
		{
			oWin := ""
			return
		}

		Loop
		{
			vSfx := (A_Index=1) ? "" : " (" A_Index ")"
			vName := vNameNoExt vSfx vDotExt
			vPath := vDir "\" vName
			if !FileExist(vPath)
				break
		}

		;create a blank text file (ANSI/UTF-8/UTF-16)
		;FileAppend,, % "*" vPath
		FileAppend,, % "*" vPath, UTF-8
		;FileAppend,, % "*" vPath, UTF-16

		;SVSI_FOCUSED := 0x10 ;SVSI_ENSUREVISIBLE := 0x8
		;SVSI_DESELECTOTHERS := 0x4 ;SVSI_EDIT := 0x3
		;SVSI_SELECT := 0x1 ;SVSI_DESELECT := 0x0
		Loop 30
		{
			if !(oWin.Document.Folder.Items.Item(vName).path = "")
			{
				oWin.Document.SelectItem(vPath, 0x1F)
				break
			}
			Sleep, 100
		}
		break
	}
}
oWin := ""
return
#IfWinActive
