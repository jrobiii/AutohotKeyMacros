#IfWinActive ahk_class ConsoleWindowClass
	^D::SendInput exit{ENTER};
	return
#IfWinActive
