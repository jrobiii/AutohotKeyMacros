; Stuff to do when Windows Explorer is open
;
#IfWinActive ahk_class ExploreWClass
    !n::Send !fwf ; create new folder
    !t::Send !fwt ; create new text file
    !c::OpenCmdInCurrent() ; open 'cmd' in the current directory
    return
#IfWinActive

#IfWinActive ahk_class CabinetWClass
    !n::Send !fwf ; create new folder
    !t::Send !fwt ; create new text file
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



