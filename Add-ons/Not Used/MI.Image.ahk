;
; GENERIC IMAGE FUNCTIONS
;

; LoadImage - Loads a bitmap or icon from file.
; Valid types:
;   IMAGE_BITMAP = 0
;   IMAGE_ICON   = 1
;   IMAGE_CURSOR = 2
; flags:
;   LR_LOADFROMFILE = 0x10
;   See MSDN for more.
LoadImage(filename, type=0, width=0, height=0, flags=0x10)
{
    return DllCall("LoadImage"
        , "UInt", 0      ; hinst (for loading resources from a dll or exe)
        , "Str" , filename
        , "UInt", type
        , "Int" , width  ; desired width (0 = actual size)
        , "Int" , height ; desired height
        , "UInt", flags)
}

; Copies and resizes a bitmap or icon.
; Valid types:
;   0 = IMAGE_BITMAP
;   1 = IMAGE_ICON
;   2 = IMAGE_CURSOR
CopyImage(h_image, type=0, new_width=0, new_height=0, flags=0)
{
    return DllCall("CopyImage"
        , "UInt", h_image
        , "UInt", type
        , "Int" , new_width
        , "Int" , new_height
        , "UInt", flags)
}


;
; ICON FUNCTIONS
;

; Gets the bitmask and color bitmaps from an icon.
; IMPORTANT:
; "GetIconInfo creates bitmaps for the hbmMask and hbmColor members of ICONINFO.
;  The calling application must manage these bitmaps and delete them when they
;  are no longer necessary. "
; e.g.
;   DllCall("DeleteObject", "uint", hbmMask)
GetIconBitmaps(h_icon, ByRef hbmColor, ByRef hbmMask)
{
    VarSetCapacity(ii, 20, 0)
    
    if (DllCall("GetIconInfo", "UInt", h_icon, "UInt", &ii))
    {
        hbmColor := NumGet(ii, 16)
        hbmMask  := NumGet(ii, 12)
        return true
    }
    return false
}

; If anyone knows a way to measure an icon without generating the temporary
; bitmaps, please let me know.
; (If you already have an icon's bitmap, use GetBitmapSize instead of this.)
GetIconSize(h_icon, ByRef width, ByRef height)
{
    VarSetCapacity(ii, 20, 0)
    
    if (DllCall("GetIconInfo", "UInt", h_icon, "UInt", &ii))
    {
        hbmColor := NumGet(ii, 16)
        hbmMask  := NumGet(ii, 12)
        
        ret := GetBitmapSize(hbmColor, width, height)
        
        DllCall("DeleteObject", "UInt", hbmColor)
        DllCall("DeleteObject", "UInt", hbmMask)
        
        return ret
    }
    return false
}


;
; BITMAP FUNCTIONS
;

; Gets the width and height of a bitmap.
GetBitmapSize(h_bitmap, ByRef width, ByRef height, ByRef bpp="")
{
    VarSetCapacity(bm, 24, 0) ; BITMAP
    if (!DllCall("GetObject", "UInt", h_bitmap, "Int", 24, "UInt", &bm))
        return false
    width  := NumGet(bm, 4, "int")
    height := NumGet(bm, 8, "int")
    bpp    := NumGet(bm,18, "ushort")
    return true
}

; Copies the bits of the specified DDB (device-dependant bitmap) into a buffer
; as a DIB (device-independant bitmap) using the specified format.
GetDIBits(hbmp, bpp, ByRef bits, hDC=0) {
    return MI_INTERNAL_GetOrSetDIBits(hbmp, bpp, bits, hDC, true)
}

; Sets the pixels in a DDB (hbmp) using the specified color data (bits).
SetDIBits(hbmp, bpp, ByRef bits, hDC=0) {
    return MI_INTERNAL_GetOrSetDIBits(hbmp, bpp, bits, hDC, false)
}

MI_INTERNAL_GetOrSetDIBits(hbmp, bpp, ByRef bits, hDC, func_get=true)
{
    hdcUsed := hDC ? hDC : DllCall("GetDC", "UInt", 0)
    if (!hdcUsed) ; rare if possible
        return 0

    GetBitmapSize(hbmp, w, h)
    
    VarSetCapacity(bi, 40, 0) ; BITMAPINFO(HEADER)
    NumPut(40,  bi,  0)             ; biSize
    NumPut(1,   bi, 12, "UShort")   ; biPlanes
    NumPut(0,   bi, 16)             ; biCompression = BI_RGB (none)
    NumPut(w,   bi,  4)             ; biWidth
    NumPut(h,   bi,  8)             ; biHeight
    NumPut(bpp, bi, 14, "UShort")   ; biBitCount

    if (func_get)
    {   ; Set buffer size to fit the bitmap.
        VarSetCapacity(bits, w*h*Ceil(bpp/8), 0)
    }
    
    ret := DllCall(func_get ? "GetDIBits" : "SetDIBits"
        , "UInt", hdcUsed   ; hdc
        , "UInt", hbmp  ; hbmp
        , "UInt", 0     ; uStartScan
        , "UInt", h     ; cScanLines
        , "UInt", &bits ; lpvBits (buffer to receive the bitmap data)
        , "UInt", &bi   ; lpbi (specifies the format of lpvBits)
        , "UInt", 0)    ; uUsage = DIB_RGB_COLORS (not indexed)
    
    if (hdcUsed != hDC)
        DllCall("ReleaseDC", "UInt", 0, "UInt", hdcUsed)
    
    return ret
}

; Primarily used to create a 32-bit DIB (device-independant bitmap)
; on Vista to enable alpha blending, but exists on Windows 95 and up.
; (I imagine it has other uses, but not in regards to menu items.)
CreateDIBSection(w, h, bpp, hDC=0, ByRef ppvBits=0)
{
    hdcUsed := hDC ? hDC : DllCall("GetDC", "UInt", 0)
    if (hdcUsed)
    {
        VarSetCapacity(bi, 40, 0) ; BITMAPINFO(HEADER)
        NumPut(40, bi,  0)              ; biSize
        NumPut(1,  bi, 12, "UShort")    ; biPlanes
        NumPut(0,  bi, 16)              ; biCompression = BI_RGB (none)
        NumPut(w,  bi,  4)              ; biWidth
        NumPut(h,  bi,  8)              ; biHeight
        NumPut(bpp,bi, 14, "UShort")    ; biBitCount
        
        hbmp := DllCall("CreateDIBSection"
            , "UInt" , hDC
            , "UInt" , &bi   ; defines format, attributes, etc.
            , "UInt" , 0     ; iUsage = DIB_RGB_COLORS
            , "UInt*", ppvBits ; gets a pointer to the bitmap data
            , "UInt" , 0
            , "UInt" , 0)

        if (hdcUsed != hDC)
            DllCall("ReleaseDC", "UInt", 0, "UInt", hDC)

        return hbmp
    }
    return 0
}
