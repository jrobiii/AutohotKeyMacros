; Requries this file:
;#Include MI.Image.ahk

; Note: 32-bit alpha-blended icons are supported only on Windows Vista.
; Article on menu icons in Vista:
; http://shellrevealed.com/blogs/shellblog/archive/2007/02/06/Vista-Style-Menus_2C00_-Part-1-_2D00_-Adding-icons-to-standard-menus.aspx
GetBitmapFromIcon32Bit(h_icon, width=0, height=0)
{
    ; hbmColor is used to measure the icon if no width or height are specified.
    ; hbmMask is used to generate alpha data if none is present.
    GetIconBitmaps(h_icon, hbmColor, hbmMask)

    if (width or height) {
        if ! width
            width := height
        if ! height
            height := width
    } else { ; no width or height specified
        if ! hbmColor
            return 0
        GetBitmapSize(hbmColor, width, height)
    }

    ; Create a device context compatible with the screen.        
    if (hdcDest := DllCall("CreateCompatibleDC", "UInt", 0))
    {
        ; Create a 32-bit bitmap to draw the icon onto.
        if (bm := CreateDIBSection(width, height, 32, hdcDest, pBits))
        {
            ; Select the new bitmap into the device context.
            if (bmOld := DllCall("SelectObject", "UInt", hdcDest, "UInt", bm))
            {
                ; RECT rcDest
                VarSetCapacity(rcDest, 16, 0)
                NumPut(width,  rcDest,  8)
                NumPut(height, rcDest, 12)
                
                ret := DllCall("DrawIconEx"
                    , "UInt", hdcDest ; hdc (destination device context)
                    , "Int" , 0         ; xLeft
                    , "Int" , 0         ; yTop
                    , "UInt", h_icon
                    , "UInt", width
                    , "UInt", height
                    , "UInt", 0         ; istepIfAniCur
                    , "UInt", 0         ; hbrFlickerFreeDraw = NULL (draw directly into buffer)
                    , "UInt", 3)        ; diFlags = DI_NORMAL

                ; Reselect previous object (as per MSDN recommendation.)
                DllCall("SelectObject", "UInt", hdcDest, "Uint", bmOld)
            }
        
            ; Icons with no alpha data end up looking like a white square.
            ; Check for alpha data.
            has_alpha_data := false
            Loop, % height*width
                if (NumGet(pBits+0, (A_Index-1)*4) & 0xFF000000)
                {
                    has_alpha_data := true
                    break
                }
            ; Use mask to generate alpha data.
            if (!has_alpha_data)
            {
                ; Ensure the mask is the right size.
                hbmMask := CopyImage(hbmMask, 0, width, height, 4|8)
                
                if (GetDIBits(hbmMask, 32, mask_bits))
                {   ; Use icon mask to generate alpha data.
                    Loop, % height*width
                        if (NumGet(mask_bits, (A_Index-1)*4))
                            NumPut(0, pBits+(A_Index-1)*4)
                        else
                            NumPut(NumGet(pBits+(A_Index-1)*4) | 0xFF000000, pBits+(A_Index-1)*4)
                }
                else
                {   ; Make the bitmap entirely opaque.
                    Loop, % height*width
                        NumPut(NumGet(pBits+(A_Index-1)*4) | 0xFF000000, pBits+(A_Index-1)*4)
                }
            }
        }
    
        ; Done using the device context.
        DllCall("DeleteDC", "UInt", hdcDest)
    }

    if hbmColor
        DllCall("DestroyObject", "uint", hbmColor)
    if hbmMask
        DllCall("DestroyObject", "uint", hbmMask)
    return bm
}
