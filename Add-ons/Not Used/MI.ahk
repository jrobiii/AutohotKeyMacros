;
; AutoHotkey Version: 1.0.47.02
; Language:       English
; Platform:       Win9x/NT
; Author:         Lexikos
;
; Script Function:
;	Simplify adding icons to menus.
;

; #Include path\to\MI\directory  should be used before including this file.

; Menu functions:   SetMenuItemBitmap, SetMenuStyle, GetMenuHandle
#Include c:\work\common\AutoHotkey\MI.Menus.ahk

; Image functions:  LoadImage, CopyImage
; Icon functions:   GetIconBitmaps, GetIconSize
; Bitmap functions: GetBitmapSize, GetDIBits, SetDIBits, CreateDIBSection
#Include c:\work\common\AutoHotkey\MI.Image.ahk

; Vista-only:       GetBitmapFromIcon32Bit
#Include c:\work\common\AutoHotkey\MI.Vista.ahk

; Owner-drawing:    SetMenuItemOwnerDrawnIcon, ShowOwnerDrawnMenu
#Include c:\work\common\AutoHotkey\MI.OwnerDraw.ahk


; Associates an icon with a menu item.
; NOTE: On versions of Windows other than Vista, the menu MUST be shown with
;       ShowMenu() for the icons to appear.
;
;   MenuNameOrHandle
;       The name or handle of a menu. When setting icons for multiple items,
;       it is more efficient to use a handle returned by GetMenuHandle("menuname").
;   ItemPos
;       The position of the menu item, where 1 is the first item.
;   FilenameOrHICON
;       The filename or handle of an icon.
;   IconNumber
;       The icon group to use (if omitted, it defaults to 1.)
;       This is not used if FilenameOrHICON specifies an icon handle.
;   IconSize
;       The desired width and height of the icon. If omitted, the system's small icon size is used.
;   h_bitmap
;   h_icon
;       These are set to the bitmap or icon resources which are used.
;       Bitmaps and icons can be deleted as follows:
;           DllCall("DeleteObject", "uint", h_bitmap)
;           DllCall("DestroyIcon", "uint", h_icon)
;       This is only necessary if the menu item displaying these resources
;       is manually removed.
;       Usually only one of h_icon or h_bitmap will be used, and the other will be 0 (NULL).
;
; OPERATING SYSTEM NOTES:
;
; Windows 2000 and above:
;   PrivateExtractIcons() is used to extract the icon.
;
; Older versions of Windows:
;   PrivateExtractIcons() is not available, so ExtractIconEx() is used.
;   As a result, a 16x16 or 32x32 icon will be loaded. If a size is specified,
;   the icon may be stretched to fit. If no size is specified, 16x16 is used.
;
SetMenuItemIcon(MenuNameOrHandle, ItemPos, FilenameOrHICON, IconNumber=1, IconSize=0, ByRef h_bitmap="", ByRef h_icon="")
{
    static SmallIconSize, LargeIconSize
    if (!SmallIconSize) {
        SysGet, SmallIconSize, 49  ; 49, 50  SM_CXSMICON, SM_CYSMICON 
        SysGet, LargeIconSize, 11  ; 11, 12  SM_CXICON, SM_CYICON 
    }

    h_icon = 0
    h_bitmap = 0

    
    ; Get menu handle.
    if MenuNameOrHandle is integer
        h_menu := MenuNameOrHandle
    else
        h_menu := GetMenuHandle(MenuNameOrHandle)
    
    if !h_menu
        return false
    
    
    loaded_icon := false
    
    ; Get icon handle or load icon from file.
    if FilenameOrHICON is not integer
    {
        ; If possible, use PrivateExtractIcons, which supports any size of icon.
        if A_OSVersion in WIN_VISTA,WIN_2003,WIN_XP,WIN_2000
        {
            VarSetCapacity(phiconLarge, 4, 0)
            VarSetCapacity(phiconSmall, 4, 0) ; (reusing variables...)
            
            ; MSDN: "... this function is deprecated ..." (oh well)
            ret := DllCall("PrivateExtractIcons"
                , "str", FilenameorHICON
                , "int", IconNumber-1   ; zero-based index of the first icon to extract
                , "int", IconSize
                , "int", IconSize
                , "str", phiconLarge    ; pointer to an array of icon handles...
                , "str", phiconSmall    ; piconid - won't be used
                , "uint", 1             ; nIcons - number of icons to extract
                , "uint", 0, "uint")    ; flags
            
            if (ret && ret != 0xFFFFFFFF)
            {
                h_icon := NumGet(phiconLarge)
                loaded_icon := true
            }
        }
        else
        {   ; Use ExtractIconEx, which only returns 16x16 or 32x32 icons.
            VarSetCapacity(phiconLarge, 4, 0)
            VarSetCapacity(phiconSmall, 4, 0)
            
            ; Extract the icon from an executable, DLL or icon file.
            if DllCall("shell32.dll\ExtractIconExA"
                , "str", FilenameOrHICON
                , "int", IconNumber-1   ; zero-based index of the first icon to extract
                , "str", phiconLarge    ; pointer to an array of icon handles...
                , "str", phiconSmall
                , "uint", 1)
            {
                ; Use the best-fit size; clean up the other.
                if (IconSize <= SmallIconSize) {
                    DllCall("DestroyIcon", "uint", NumGet(phiconLarge))
                    h_icon := NumGet(phiconSmall)
                } else {
                    DllCall("DestroyIcon", "uint", NumGet(phiconSmall))
                    h_icon := NumGet(phiconLarge)
                }
                ; Remember to clean up this icon if we end up using a bitmap.
                loaded_icon := true
            }
        }
    }
    else
        h_icon := FilenameOrHICON
    
    if !h_icon
        return false
    
    
    if (A_OSVersion = "WIN_VISTA")
    {
        ; Windows Vista supports 32-bit alpha-blended bitmaps in menus.
        ; NOTE: The A_OSVersion check won't work if AHK is running in
        ;       compatibility mode for another version of Windows.
        h_bitmap := GetBitmapFromIcon32Bit(h_icon, IconSize, IconSize)
        
        ; If we loaded an icon, delete it now as it is unnecessary.
        if (loaded_icon) {
            DllCall("DestroyIcon", "uint", h_icon)
            h_icon = 0
        }
        
        return (h_bitmap && SetMenuItemBitmap(h_menu, ItemPos, h_bitmap))
    }

    ; To get nice icons on other versions of Windows, we need to owner-draw.
    ; NOTE: This requires the menu to be opened using ShowOwnerDrawnMenu().
    
    ; If an IconSize was specified, ensure the icon is the correct size.
    if (IconSize)
    {
        ; Note: Specify LR_COPYRETURNORG (4) so the original image is returned if it is the right size.
        ;       Specify LR_COPYDELETEORG (8) to delete the original image (if a copy was created.)
        ;       Specifying zero for width or height is the same as specifying the icon's actual size.
        h_icon := CopyImage(h_icon, 1, IconSize, IconSize, loaded_icon ? 4|8 : 4)
    }
    
    ; Associate the icon with the menu item.
    if SetMenuItemOwnerDrawnIcon(h_menu, ItemPos, h_icon)
        return true
    
    if (loaded_icon) {
        DllCall("DestroyIcon", "uint", h_icon)
        h_icon = 0
    }
    return false
}

ShowMenu(MenuNameOrHandle, x="", y="")
{
    ; Get menu handle.
    if MenuNameOrHandle is integer
        h_menu := MenuNameOrHandle
    else
        h_menu := GetMenuHandle(MenuNameOrHandle)
    
    if !h_menu
        return false
    
    return ShowOwnerDrawnMenu(h_menu, x, y)
}
