if g_Editor =  
{
    EnvGet, g_SystemRoot, SystemRoot
    g_Editor = g_SystemRoot . "\Notepad.exe"
}

PasteTextOnly(){
    ; Text–only paste from ClipBoard
    Clip0 = %ClipBoardAll%
    ClipBoard = %ClipBoard%       ; Convert to text
    Send ^v                       ; For best compatibility: SendPlay
    Sleep 50                      ; Don't change clipboard while it is pasted! (Sleep > 0)
    ClipBoard = %Clip0%           ; Restore original ClipBoard
    VarSetCapacity(Clip0, 0)      ; Free memory
    Return
}

EditAHK(){
    global
    local FileName
    EnvGet, ProfilePath, USERPROFILE
    FileName = "%ProfilePath%\My Documents\AutoHotkey.ahk"
    Edit(FileName)
    Loop, %A_SCRIPTDIR%\*.AHK
    {
        FileName = "%A_LoopFileFullPath%"
        Edit(FileName)
    }
    
    return

}

Edit(parm_FileName=""){
    global
    if parm_FileName =
    {
        Run %g_Editor%
    } else 
    {
        Run, "%g_Editor%" %parm_FileName%
    }
}

GoSearch(){
    run http://www.google.com
}