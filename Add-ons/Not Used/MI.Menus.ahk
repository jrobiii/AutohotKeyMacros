; Assigns a bitmap to a menu item.
;   h_menu:     A menu handle. Use GetMenuHandle() to get the handle of a named menu.
;   item_pos:   One-based position of the menu item.
;   h_bitmap:   The bitmap to assign. (Icons must be first converted to bitmaps.)
;               HBMMENU constants (see below) can be used in place of a bitmap handle.
SetMenuItemBitmap(h_menu, item_pos, h_bitmap)
{
    VarSetCapacity(mii, 48, 0)  ; MENUITEMINFO mii
    NumPut(48       , mii,  0)  ; mii.cbSize    := sizeof(MENUITEMINFO)
    NumPut(0x80     , mii,  4)  ; mii.fMask     := MIIM_BITMAP
    NumPut(h_bitmap , mii, 44)  ; mii.hbmpItem  := h_bitmap
    return DllCall("SetMenuItemInfo", "UInt", h_menu, "UInt", item_pos-1, "UInt", 1, "UInt", &mii)
}
/*
#define HBMMENU_SYSTEM              ((HBITMAP)  1)
#define HBMMENU_MBAR_RESTORE        ((HBITMAP)  2)
#define HBMMENU_MBAR_MINIMIZE       ((HBITMAP)  3)
#define HBMMENU_MBAR_CLOSE          ((HBITMAP)  5)
#define HBMMENU_MBAR_CLOSE_D        ((HBITMAP)  6)
#define HBMMENU_MBAR_MINIMIZE_D     ((HBITMAP)  7)
#define HBMMENU_POPUP_CLOSE         ((HBITMAP)  8)
#define HBMMENU_POPUP_RESTORE       ((HBITMAP)  9)
#define HBMMENU_POPUP_MAXIMIZE      ((HBITMAP) 10)
#define HBMMENU_POPUP_MINIMIZE      ((HBITMAP) 11)
*/


; Valid (and safe to use) styles:
;   MNS_AUTODISMISS  0x10000000
;   MNS_CHECKORBMP   0x04000000  The same space is reserved for the check mark and the bitmap.
;   MNS_NOCHECK      0x80000000  No space is reserved to the left of an item for a check mark.
SetMenuStyle(h_menu, style)
{
    VarSetCapacity(mi, 28, 0)
    NumPut(28, mi, 0) ; cbSize
    NumPut(0x10, mi, 4) ; fMask=MIM_STYLE
    NumPut(style, mi, 8)
    DllCall("SetMenuInfo", "uint", h_menu, "uint", &mi)
}

; Adapted from Shimanov's Menu_AssignBitmap() : http://www.autohotkey.com/forum/topic7526.html
GetMenuHandle(menu_name)
{
    static   h_menuDummy
    If h_menuDummy=
    {
        Menu, menuDummy, Add
        Menu, menuDummy, DeleteAll

        Gui, 99:Menu, menuDummy
        Gui, 99:Show, Hide, guiDummy

        old_DetectHiddenWindows := A_DetectHiddenWindows
        DetectHiddenWindows, on

        Process, Exist
        h_menuDummy := DllCall( "GetMenu", "uint", WinExist( "guiDummy ahk_class AutoHotkeyGUI ahk_pid " ErrorLevel ) )
        If ErrorLevel or h_menuDummy=0
            return 0

        DetectHiddenWindows, %old_DetectHiddenWindows%

        Gui, 99:Menu
        Gui, 99:Destroy
    }

    Menu, menuDummy, Add, :%menu_name%
    h_menu := DllCall( "GetSubMenu", "uint", h_menuDummy, "int", 0 )
    DllCall( "RemoveMenu", "uint", h_menuDummy, "uint", 0, "uint", 0x400 )
    Menu, menuDummy, Delete, :%menu_name%
    
    return h_menu
}
