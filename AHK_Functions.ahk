WinSysExec(sCommand){

    ; Powershell technique for calling 64bit Windows System EXEs from either a 32bit or 64bit app
    ;if (test-path "$($env:windir)\sysnative\qwinsta.exe"){
    ;    $QwinstaExe = "$($env:windir)\sysnative\qwinsta.exe"
    ;    $RwinstaExe = "$($env:windir)\sysnative\rwinsta.exe"
    ;} else {
    ;    $QwinstaExe = "qwinsta"
    ;    $RwinstaExe = "rwinsta"
    ;}

    FilePath = %windir%\sysnative\%sCommand%
    ifexist, %FilePath% 
    {
        Run, %FilePath%
    } else {
        Run, %sCommand%
    }
}
ReloadSystemAHK(){
  Send, ^s
  Reload
  Return
}

ShowActiveWinTitle(){
    WinGetActiveTitle, Title
    msgbox, %Title%
    clipboard = %Title%
}

NowDate(){
    FormatTime, CurrentDateTime,, M/d/yyyy ; It will look like 9/1/2005
    SendInput %CurrentDateTime%
    return
}

NowTime(){
    FormatTime, CurrentDateTime,, h:mm tt  ; It will look like 3:53 PM
    SendInput %CurrentDateTime%
    Return
}

FileDateFormat(){
  fDate = ""
  formatTime,fDate,NowDate(), yyyyMMdd
  SendInput %fDate%
  Return      
}

FileTimeFormat(){
  fTime = ""
  formatTime,fTime,NowDate(), HHmmss
  SendInput %fTime%
  Return      
}

; Opens the command shell 'cmd' in the directory browsed in Explorer.
; Note: expecting to be run when the active window is Explorer.
;
OpenCmdInCurrent()
{
    WinGetText, full_path, A  ; This is required to get the full path of the file from the address bar

    ; Split on newline (`n)

    StringSplit, word_array, full_path, `n
    full_path = %word_array1%   ; Take the first element from the array

    ; Just in case - remove all carriage returns (`r)
    StringReplace, full_path, full_path, `r, , all  
    ; The full path 
    StringReplace, full_path, full_path, Address: , , all  

    SetWorkingDir %full_path%
    
    IfInString full_path, \
    {   
        Run, cmd /K cd /D %full_path%
    }
    else
    {
        Run, cmd /K cd /D "C:\"
    }
}

ReverseAKAFlip(string){
    return, Strlen(string) < 2 ? Substr(string,1) : Substr(string,0) ReverseAKAFlip(Substr(string,1,-1))
}

Flip(in) {

	VarSetCapacity(out, n:=StrLen(in))
	Loop %n%
		out .=	SubStr(in, n--, 1)
	return	out

}
