SendMode Input

#h::AddHotString()  ; Win+H hotkey
#s::ReloadSystemAHK()
#n::Edit("")
#a::EditAHK()
^#v::PasteTextOnly()
#q::run, h:\bin\Q-sql.cmd
#`::WinSysExec("SnippingTool.exe")
;#c::WinSysExec("Calc.exe")
^!#q::msgbox, "Hello world!"
#j::run, C:\Users\jroberts\Downloads
#p::run, H:\Projects
#c::NewCommitment()
#i::ProcessFolderCategories()
