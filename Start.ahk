SetTitleMatchMode REGEX

g_Editor := ""

; This will try to get the EDITOR environment variable.  If EDITOR is set to C:\Program Files (x86)\Notepad++\notepad++.exe
; you will be able to use the Edit() function in AHK_Functions.
EnvGet, g_Editor, Editor

#include .\AHK_Functions.ahk
#include .\MyAddons.ahk

; Argh! Cannot use %USERPROFILE% in an #include statement so we have to do this following gyration to load the My scripts
#include %A_AppData%\..\..\Documents
#include MyHotStrings.ahk
#include MyHotkeys.ahk
