; Stuff to do when Windows CMD is open

; Powershell (console) is also in AHK_CLASS ConsoleWindowClass
#IfWinActive ahk_class ConsoleWindowClass
	+Insert::SendInput {Raw}%clipboard% ;
	^v::SendInput {Raw}%clipboard% ;
    !F4::SendInput exit{ENTER}
    ^d::SendInput exit{ENTER}
	return
#IfWinActive
