#SingleInstance, Force
#NoEnv
 
; Uncomment if Gdip.ahk is not in your standard library
#Include, Gdip.ahk
 
; Start gdi+
If !pToken := Gdip_Startup()
{
	MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
	ExitApp
}
OnExit, Exit

; Test code for command line parameters
;~ 0:=3
;~ 1:="Hallo"
;~ 2:="--expire-time=400"
;~ 3:="--icon=c:\xampp\htdocs\oequasta\vendor\drush\drush\drush_logo-black.png"
 
; Parse command line parameters
sMessage=
sIcon=
sExpireTime = 5000
sAppName = notify-send
Loop, %0% 
{
    sCurrentParameter := %A_Index%  ; Fetch the contents of the variable whose name is contained in A_Index.
	If bNextIsIcon 
	{
		sIcon := sCurrentParameter
		continue
	}
	StringLeft, FirstChar, sCurrentParameter, 1
    IfNotEqual, FirstChar, -
		sMessage .= sCurrentParameter . "`n"
    IfInString, sCurrentParameter, --icon=
		sIcon := SubStr(sCurrentParameter, 8)
    IfInString, sCurrentParameter, --app-name=
		sAppName := SubStr(sCurrentParameter, 12)
    IfInString, sCurrentParameter, --expire-time=
		sExpireTime := SubStr(sCurrentParameter, 15) + 1
}

IfEqual, sMessage 
{
	MsgBox, Shows a notification.`n`nUsage:`n  notify-send [OPTION?] <Message>`n`n--icon=ICON`tPath to a JPEG or PNG image`n--app-name=TITLE`tSpecifies the app name for the icon`n--expire-time=T`tSpecifies the timeout in milliseconds (%sExpireTime%)`n`nFind the source code at https://github.com/Fonata/notify-send-for-Windows.
	ExitApp
}

; Construct notification window
pBitmap := Gdip_CreateBitmapFromFile(sIcon)
Width := Gdip_GetImageWidth(pBitmap)
Height := Gdip_GetImageHeight(pBitmap)
hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
Left := 10 + Width
Gui, 1: Add, Picture, x10 y10 w%Width% h%Height% 0xE vMyPicture
Gui, 1: Add, Text, x%Left% y10, %sMessage%
GuiControlGet, hwnd, hwnd, MyPicture
SetImage(hwnd, hBitmap)
Gui, 1: -DPIScale
Gui, 1: Show, AutoSize,  %sAppName%
SetTimer, ExpireGuiTimer, -%sExpireTime%
return

ExpireGuiTimer:
Gui, 1:Destroy

GuiClose:
Exit:
; gdi+ may now be shutdown on exiting the program
Gdip_Shutdown(pToken)
ExitApp
Return
 