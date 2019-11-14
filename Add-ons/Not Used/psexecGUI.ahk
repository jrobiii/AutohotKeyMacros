;    ____       ______                  ________  ______
;   / __ \_____/ ____/  _____  _____   / ____/ / / /  _/
;  / /_/ / ___/ __/ | |/_/ _ \/ ___/  / / __/ / / // /   
; / ____(__  ) /____>  </  __/ /__   / /_/ / /_/ // /   
;/_/   /____/_____/_/|_|\___/\___/   \____/\____/___/   
;                                                       
; _By_Jon_
;

#4::
Gui, Add, GroupBox, x6 y5 w450 h110, Program Details

Gui, Add, Text, x16 y25 w140 h20, Program to execute
Gui, Add, Edit, x166 y25 w210 h20   vExecutable  ,
Gui, Add, Button, x386 y25 w60 h20 gExecutable, Browse

Gui, Add, Text,  x16 y55 w140 h20,Arguments to Pass
Gui, Add, Edit, x166 y55 w210 h20  vArguments,

Gui, Add, Checkbox,x16 y85 w140 h20 vcb_WorkingDirectory gcb_WorkingDirectory, -w  (Remote Working Dir)
Gui, Add, Edit,x166 y85 w210 h20   vWorkingDirectory,
Gui, Add, Button, x386 y85 w60 h20 vbn_WorkingDirectory gWorkingDirectory,Browse

;-------------------------------------------------------------------------------------

Gui, Add, GroupBox, x6 y120 w450 h90, Remote Workstation(s)

Gui, Add, Text, x16 y140 w140 h30, Enter Computer(s)`n[\\computer[`,computer[`,..]
Gui, Add, Edit,x166 y140 w280 h20  vCompList, \\
Gui, Add, Radio,x150 y143 w15 h15 group checked vrb_CompList grb_CompList,

Gui, Add, Radio,x150 y183 w15 h15 grb_CompFile vrb_CompFile,
Gui, Add, Text, x16 y180 w100 h20, Or import From File
Gui, Add, Edit,x166 y180 w210 h20  vCompFile,
Gui, Add, Button,x386 y180 w60 h20 vbn_CompFile gCompFile ,Browse


;-------------------------------------------------------------------------------------

Gui, Add, GroupBox, x6 y220 w230 h170, Run as

Gui, Add, Checkbox,x16 y240 w90 h20 vcb_UserName gcb_UserName , -u  Username
Gui, Add, Edit,x116 y240 w110 h20  vUserName    ,  %USERDOMAIN%\%a_username%         

Gui, Add, Checkbox, x16 y270 w90 h20 vcb_Password gcb_Password, -p  Password
Gui, Add, Edit,x116 y270 w110 h20 Password vPassword,

Gui, Add, Checkbox,x16 y300 w210 h20 vcb_limited , -l  Run as limited user

Gui, Add, Radio,x16 y330 w210 h20 vcb_profile gcb_profile, -e  Load specified accounts profile
Gui, Add, Radio,x16 y360 w160 h20 vcb_System gcb_System, -s  Run in system account

;-------------------------------------------------------------------------------------

Gui, Add, GroupBox, x246 y220 w210 h110, Copy to Remote PC

Gui, Add, Checkbox, x256 y240 w170 h20 vcb_copy gcb_copy, -c  Copy and execute
Gui, Add, Radio, x256 y270 w170 h20 vcb_exists gcb_Exists  group, -f  Even if already exists
Gui, Add, Radio, x256 y300 w170 h20 vcb_newer gcb_newer  , -v  Only If newer version

;-------------------------------------------------------------------------------------

Gui, Add, GroupBox, x246 y340 w210 h150, Other Options

Gui, Add, Checkbox, x256 y360 w60 h20 vcb_Priority gPriority, Priority
Gui, Add, ListBox, x326 y360 w110 h40 vPriority , -low|-belownormal|-abovenormal|-high|-realtime

Gui, Add, Checkbox,x256 y400 w190 h20 vcb_wait , -d  Don't wait for app to terminate
Gui, Add, Checkbox,x256 y430 w170 h20  vcb_interact , -i  Interact with Desktop

Gui, Add, Checkbox,x256 y460 w160 h20 vcb_Timeout gcb_Timeout, -n  Connection timeout (secs)
Gui, Add, Edit,x416 y460 w30 h20   vTimeout,


;-------------------------------------------------------------------------------------

;Gui, Add, Text,x6 y400 w60 h20, Command:
Gui, Add, Edit, x6 y400 w230 h70 vCommand,

;Gui, Add, Button,x6 y475 w50 h20 default  gUpdateCommand, &Update
Gui, Add, Button,x6 y472 w77 h21   gExecute, &Execute
Gui, Add, Button,x153 y472 w41 h20 gCopy, &Copy
Gui, Add, Button,x196 y472 w41 h20 gSave, &Save
;Gui, Add, Checkbox, checked x8 y490 w230 h20 vcb_AutoUpdate gcb_AutoUpdate,Automatically Update Command

;-------------------------------------------------------------------------------------

Gui, Show, h500 w466, PSExec GUI  - Remote Process Execution

GuiControl, Disable, Priority
GuiControl, Disable, WorkingDirectory
GuiControl, Disable, bn_ImportFile
GuiControl, Disable, CompFile
GuiControl, Disable, bn_CompFile
GuiControl, Disable, bn_WorkingDirectory

GuiControl, Disable, UserName
GuiControl, Disable, Password
GuiControl, Disable, cb_Password
GuiControl, Disable, cb_Profile

GuiControl, Disable, cb_exists
GuiControl, Disable, cb_newer

GuiControl, Disable, Timeout

GuiControl, Disable, Password

;winset, alwaysontop, on, PSExec GUI

SetTimer, UpdateCommand, 250

return


GuiClose:
ExitApp

;-------------------------------------------------------------------------------------

cb_Password:

 GuiControlGet, CheckState, , cb_Password
  if CheckState = 1
    GuiControl, Enable, Password
  Else
    GuiControl, Disable, Password

return

cb_AutoUpdate:

 SetTimer, UpdateCommand, off

 GuiControlGet, CheckState, , cb_AutoUpdate
  if CheckState = 1
    SetTimer, UpdateCommand, on
  Else
    SetTimer, UpdateCommand, off

return

Executable:
 SetTimer, UpdateCommand, off
 FileSelectFile, Executable, 3, %a_workingDir%, Select program for remote execution
 if Executable <>
 GuiControl, , Executable, %Executable%
 SetTimer, UpdateCommand, on
 
return

WorkingDirectory:
 SetTimer, UpdateCommand, off
 FileSelectFolder, WorkingDirectory, %a_homedir%, 3, Select working directory for remote execution
 if WorkingDirectory <>
   GuiControl, , WorkingDirectory, %WorkingDirectory%
 SetTimer, UpdateCommand, on
 
return

cb_WorkingDirectory:

 GuiControlGet, CheckState, , cb_WorkingDirectory
  if CheckState = 1
  {
    GuiControl, Enable, WorkingDirectory
    GuiControl, Enable, bn_WorkingDirectory
  }
  Else
  {
    GuiControl, Disable, WorkingDirectory
    GuiControl, Disable, bn_WorkingDirectory
  }
 
return

Priority:
 GuiControlGet, CheckState, , cb_Priority
  if CheckState = 1
    GuiControl, Enable, Priority
  Else
    GuiControl, Disable, Priority
 
return

rb_CompList:
 GuiControl, Enable, CompList
 ;GuiControl, , CompFile,
 GuiControl, Disable, CompFile
 GuiControl, Disable, bn_CompFile
 
return


rb_CompFile:
 GuiControl, Enable, CompFile
 ;GuiControl, , CompList,
 GuiControl, Disable, CompList
 GuiControl, Enable, bn_CompFile
 
return

CompFile:
 SetTimer, UpdateCommand, off
 FileSelectFile, CompFile, %a_workingDir%, 3, Select List of remote computers
 if CompFile <>
   GuiControl, , CompFile, %CompFile%
 SetTimer, UpdateCommand, on
 
return

cb_UserName:
 GuiControlGet, CheckState, , cb_UserName
  if CheckState = 1
  {
    GuiControl, Enable, UserName
    GuiControl, Enable, cb_Password
    GuiControl, Enable, cb_Profile
  }
  Else
  {
    GuiControl, Disable, UserName
    ;GuiControl, , UserName,
    GuiControl, Disable, Password
    ;GuiControl, , Password,
    GuiControl, , cb_Password, 0
    GuiControl, Disable, cb_Password
    GuiControl, , cb_Profile, 0
    GuiControl, Disable, cb_Profile
  }
 
return

cb_copy:
 GuiControlGet, CheckState, , cb_copy
  if CheckState = 1
  {
    GuiControl, Enable, cb_exists
    GuiControl, Enable, cb_newer
  }
  Else
  {
    GuiControl, , cb_exists, 0
    GuiControl, Disable, cb_exists
    GuiControl, , cb_newer, 0
    GuiControl, Disable, cb_newer
  }
 
return

cb_Exists:
 counter4=0
 counter3+=1
 GuiControl, , cb_Newer, 0

 if counter3 = 2
 {
   GuiControl, , cb_Exists, 0
   counter3=0
 }

return

cb_Newer:
 counter3=0
 counter4+=1
 GuiControl, , cb_Exists, 0

 if counter4 = 2
 {
   GuiControl, , cb_Newer, 0
   counter4=0
 }

return

cb_System:
 counter2=0
 counter1+=1
 GuiControl, , cb_profile, 0

 if counter1 = 2
 {
   GuiControl, , cb_System, 0
   counter1=0
 }

return

cb_profile:
 counter1=0
 counter2+=1
 GuiControl, , cb_System, 0

 if counter2 = 2
 {
   GuiControl, , cb_profile, 0
   counter2=0
 }

return

cb_Timeout:
 GuiControlGet, CheckState, , cb_Timeout
  if CheckState = 1
    GuiControl, Enable, Timeout
  Else
    GuiControl, Disable, Timeout
return


Execute:
 gui, submit, nohide
 ifnotexist, c:\bin\psexec.exe
   msgbox, Please download psexec.exe from the following site and save it in `nthe same directory as this progran in order to use this function.`n`nhttp://www.sysinternals.com/Utilities/PsExec.html
 Else
   run, %comspec% /k %Command%
return

Copy:
 gui, submit, nohide
 clipboard=%Command%
return

Save:
 gui, submit, nohide
 FileSelectFile, BatchFile, 24, %a_workingdir%\RemotelyExecute.bat, Save command as batch file, *.bat
 FileAppend, %Command%`nPause, %BatchFile%
return


UpdateCommand:

MouseGetPos, , , , ControlUnderMouse

if ControlUnderMouse = Edit9
{
sleep 5000
goto UpdateCommand
}


 Gui, Submit, nohide

;psexec [\\computer[,computer[,..] | @file ][-u user [-p psswd]][-n s][-l][-s|-e][-i][-c [-f|-v]][-d][-w directory][-<priority>][-a n,n,...] cmd [arguments]

stringreplace, CompList, CompList, %a_space%,,all

if rb_CompList = 1
  Computers = %CompList%
Else
  Computers = @"%CompFile%"

Switches=

if cb_UserName = 1
  Switches=%Switches% -u "%UserName%"
if cb_Password = 1
  Switches=%Switches% -p "%Password%"
if cb_Timeout = 1
  Switches=%Switches% -n %Timeout%
if cb_limited = 1
  Switches=%Switches% -l
if cb_System = 1
  Switches=%Switches% -s
if cb_Profile = 1
  Switches=%Switches% -e
if cb_interact = 1
  Switches=%Switches% -i
if cb_copy = 1
  Switches=%Switches% -c
if cb_exists = 1
  Switches=%Switches% -f
if cb_newer = 1
  Switches=%Switches% -v
if cb_wait = 1
  Switches=%Switches% -d
if cb_WorkingDirectory = 1
  Switches=%Switches% -w "%WorkingDirectory%"
if cb_Priority = 1
   Switches=%Switches% %Priority%
;cpu: -a 2, 4

 GuiControl, , Command, psexec.exe %Computers% %Switches% "%Executable%" %Arguments%
return 
