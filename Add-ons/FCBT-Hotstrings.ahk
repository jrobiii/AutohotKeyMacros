;;; Current Date 
:*:}d::
    NowDate()  
    Return
    
;;; Current Time
:*:}t::
    NowTime()
    Return

;;; Current Date 
:*:]d::
  FileDateFormat()
  Return
  
;;; Current Time
:*:]t::
  FileTimeFormat()
  Return

;;; Current full date and time
:*:]f::
  NowDate()
  SendInput {Space}
  NowTime()
  Return
