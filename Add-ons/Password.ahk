; From http://www.autohotkey.com/forum/topic6804.html
RC4txt2hex(Data,Pass)
{
   Format = %A_FormatInteger%
   SetFormat Integer, Hex
   Loop 256
   {
      a := A_Index - 1
      StringMid C, Pass, Mod(a,StrLen(Pass))+1, 1
      Key%a% := Asc(C)
      sBox%a% = %a%
   }
   b = 0
   Loop 256
   {
      a := A_Index - 1
      b := b + sBox%a% + Key%a%  & 255
      T := sBox%a%
      sBox%a% := sBox%b%
      sBox%b% = %T%
   }
   i = 0
   j = 0
   Loop Parse, Data
   {
      i := i + 1  & 255
      j := sBox%i% + j  & 255
      k := sBox%i% + sBox%j%  & 255
      C := (Asc(A_LoopField) ^ sBox%k%)+ 0x100
      IfEqual C,0, SetEnv C, % sBox%k% + 0x100
      StringRight C, C, 2
      Result := Result C
   }
   SetFormat Integer, %Format%
   Return Result
}

; From http://www.autohotkey.com/forum/topic6804.html
RC4hex2txt(Data,Pass)
{
   ATrim = %A_AutoTrim%
   AutoTrim Off
   Loop 256
   {
      a := A_Index - 1
      StringMid C, Pass, Mod(a,StrLen(Pass))+1, 1
      Key%a% := Asc(C)
      sBox%a% = %a%
   }
   b = 0
   Loop 256
   {
      a := A_Index - 1
      b := b + sBox%a% + Key%a%  & 255
      T := sBox%a%
      sBox%a% := sBox%b%
      sBox%b% = %T%
   }
   i = 0
   j = 0
   Loop Parse, Data
   {
      If (A_Index & 1)
         C = 0x%A_LoopField%
      Else {
         i := i + 1  & 255
         j := sBox%i% + j  & 255
         k := sBox%i% + sBox%j%  & 255
         C := (C A_LoopField) ^ sBox%k%
         IfEqual C,0, SetEnv C, % sBox%k%
         Result := Result Chr(C)
      }
   }
   AutoTrim %ATrim%
   Return Result
}

GetSalt(){
  Return "This is a value that will invalidate encrypted data if changed12345abcde"
}

WritePass(sPassFile){
    sSalt := GetSalt()
;    sPassFile := GetPassFile()

    If fileexist(sPassFile){
      InputBox, sOldPass, Current Password, Enter your current password,HIDE
      sOldPass := RC4txt2hex(sOldPass, sSalt)

      FileReadLine, sSavedPass, %sPassFile%, 1
;      FileReadLine, sSavedPass, c:\users\jim.roberts\password.txt, 1
      
      If (sOldPass != sSavedPass) {
        MsgBox, 0,, The password is incorrect
        Return
      }
      FileDelete, %sPassFile%
    }
    Loop {
      InputBox, sNewPass1, New Password, Enter your new password,HIDE
      If (sNewPass1 != ""){
        InputBox, sNewPass2, Verify New Password, Re-enter your password,HIDE
  
        If (sNewPass1 == sNewPass2) {
          sNewPass1 := RC4txt2hex(sNewPass1, sSalt)
;          MsgBox, 0,, Password file: %sPassFile% / %sNewPass1%
          FileAppend, %sNewPass1%, %sPassFile%
          
          Return    
        }
      }
    }
}

GetPass(sPassFile){
    FileReadLine, sSavedPass, %sPassFile%, 1
    sPassword := RC4hex2txt(sSavedPass, GetSalt())
    Send %sPassword%
    Return
}

