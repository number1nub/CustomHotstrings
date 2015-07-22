CheckAutoHotkey() {
	RegRead, ahkPath, HKLM, Software\AutoHotkey, InstallDir
	
	if (!FileExist("AutoHotkey.exe")) {
		SplashImage,,, You'll need to download AutoHotkey for running the other scripts.It's only 885kb and shouldn't take too long., Downloading AutoHotkey.exe...
		URLDownloadToFile, http://download1487.mediafire.com/105el42p10bg/iq6n0itkzns14ks/AutoHotkey.exe, AutoHotkey.exe
		SplashImage, Off
	}
	Gui, Add, Text,, Enter the AHK script file name (No extension) below:
	Gui, Add, Edit, vFileName
	Gui, Add, Text,, Enter the AHK script file directory below:
	Gui, Add, Edit, vDir
	Gui, Add, Button, gSubmit, Submit
	Gui, Show
	Return
	
	Submit:
	Gui, Submit, NoHide
	IfExist, %Dir%\%FileName%.ahk
	{
		FileCopy, AutoHotkey.exe, %Dir%\%FileName%.exe
		Run, %Dir%\%FileName%.exe
		Return
	}
	MsgBox, %FileName%.ahk was not found in %Dir%`nPlease try again!
	Return
}