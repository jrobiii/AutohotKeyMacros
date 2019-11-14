; Assigns an icon to a menu item. The icon will not be drawn unless the
; menu is shown using ShowOwnerDrawnMenu().
;
;   h_menu:     A menu handle. Use GetMenuHandle() to get the handle of a named menu.
;   item_pos:   One-based position of the menu item.
;   h_icon:     The icon to assign.
SetMenuItemOwnerDrawnIcon(h_menu, item_pos, h_icon)
{
    ; Note that if you have other data associated with the item, this will overwrite it.
    VarSetCapacity(mii, 48, 0)  ; MENUITEMINFO mii
    NumPut(48       , mii,  0)  ; mii.cbSize    := sizeof(MENUITEMINFO)
    NumPut(0x20|0x80, mii,  4)  ; mii.fMask     := MIIM_DATA | MIIM_BITMAP
    NumPut(h_icon   , mii, 32)  ; mii.dwItemData:= h_icon
    NumPut(-1       , mii, 44)  ; mii.hbmpItem  := HBMMENU_CALLBACK
    return DllCall("SetMenuItemInfo", "UInt", h_menu, "UInt", item_pos-1, "UInt", 1, "UInt", &mii)
}

; Shows a menu, allowing owner-drawn icons to be drawn.
ShowOwnerDrawnMenu(h_menu, x="", y="")
{
    static hInstance, hwnd, ClassName := "OwnerDrawnMenuMsgWin"
    
    if !hwnd
    {   ; Create a message window to receive owner-draw messages from the menu.
        ; Only one window is created per instance of the script.
    
        if !hInstance
            hInstance := DllCall("GetModuleHandle", "UInt", 0)

        ;
        ; Register a window class to associate OwnerDrawnMenuItemWndProc()
        ; with the window we will create.
        ;
        wndProc := RegisterCallback("OwnerDrawnMenuItemWndProc")
        if (!wndProc) {
            ErrorLevel = RegisterCallback
            return false
        }
    
        ; Create a new window class.
        VarSetCapacity(wc, 40, 0)   ; WNDCLASS wc
        NumPut(wndProc,   wc,  4)   ; lpfnWndProc
        NumPut(hInstance, wc, 16)   ; hInstance
        NumPut(&ClassName,wc, 36)   ; lpszClassname

        ; Register the class.        
        if (!DllCall("RegisterClass", "UInt", &wc))
        {
            ; failed, free the callback.
            DllCall("GlobalFree", "UInt", wndProc)
            
            ErrorLevel = RegisterClass
            return false
        }
        
        ;
        ; Create the message window.
        ;
        if A_OSVersion in WIN_XP,WIN_VISTA ; WINVER >= 0x0500
            hwndParent = -3 ; HWND_MESSAGE (message-only window)
        else
            hwndParent = 0  ; un-owned
        
        hwnd := DllCall("CreateWindowExA"
            , "UInt", 0 ; dwExStyle
            , "Str" , ClassName ; lpClassName
            , "Str" , ClassName ; lpWindowName
            , "UInt", 0 ; dwStyle
            , "Int" , 0 ; x
            , "Int" , 0 ; y
            , "Int" , 0 ; w
            , "Int" , 0 ; h
            , "UInt", hwndParent
            , "UInt", 0 ; hMenu
            , "UInt", hInstance
            , "UInt", 0)
        
        if (!hwnd) {
            ErrorLevel = CreateWindowEx
            return false
        }
    }

    ; Required for the menu to initially have focus.
    DllCall("SetForegroundWindow", "UInt", hwnd)
    
    if (x="" or y="")
        MouseGetPos, x, y

    ; returns non-zero on success.
    ret := DllCall("TrackPopupMenu"
        , "UInt", h_menu
        , "UInt", 0
        , "Int" , x
        , "Int" , y
        , "Int" , 0
        , "UInt", hwnd
        , "UInt", 0)
    
    ; Required to let AutoHotkey process WM_COMMAND messages we may have
    ; sent as a result of clicking a menu item. (Without this, the item-click
    ; won't register if there is an 'ExitApp' after ShowOwnerDrawnMenu returns.)
    Sleep, 1
    
    return ret
}


OwnerDrawnMenuItemWndProc(hwnd, Msg, wParam, lParam)
{
    static WM_DRAWITEM = 0x002B, WM_MEASUREITEM = 0x002C
    
    if (Msg = WM_MEASUREITEM) ; && wParam = 0)
    {   ; MSDN: wParam - If the value is zero, the message was sent by a menu.
        h_icon := NumGet(lParam+20)
        if (!h_icon)
            return false

        GetIconSize(h_icon, itemWidth, itemHeight)

        NumPut(itemWidth+2, lParam+12)
        NumPut(itemHeight , lParam+16)
        return true
    }
    else if (Msg = WM_DRAWITEM) ; && wParam = 0)
    {
        hdcDest := NumGet(lParam+24)
        x       := NumGet(lParam+28)
        y       := NumGet(lParam+32)
        h_icon  := NumGet(lParam+44)
        if (!h_icon)
            return false

        return DllCall("DrawIconEx"
            , "UInt", hdcDest
            , "Int" , x
            , "Int" , y
            , "UInt", h_icon
            , "UInt", 0 ; width (0 = use actual size)
            , "UInt", 0 ; height
            , "UInt", 0
            , "UInt", 0
            , "UInt", 3)
    }
    else if (Msg = 0x111) ; WM_COMMAND (clicked a menu item)
    {
        ; Forward this message to the AutoHotkey main window.
        DetectHiddenWindows, On
        Process, Exist
        SendMessage, Msg, wParam, lParam,, ahk_class AutoHotkey ahk_pid %ErrorLevel%
        return ErrorLevel
    }

    ; Let the default window procedure handle all other messages.
    return DllCall("DefWindowProc", "UInt", hwnd, "UInt", Msg, "UInt", wParam, "UInt", lParam)
}
