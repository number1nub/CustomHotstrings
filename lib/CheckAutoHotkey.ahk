CheckAutoHotkey() {
	RegRead, ahkPath, HKLM, Software\AutoHotkey, InstallDir
	if (ErrorLevel || !FileExist(ahkPath)) {
		prompt := "You don't appear to have AutoHotkey installed on your computer!`n`nAutoHotkey is required for this application to run & manage dynamic hotstrings.`n`nWhat would you like to do?"
		btns := ["Launch Portable Mode", "Download && Install AutoHotkey", "Cancel"]
		URLDownloadToFile, http://ahkscript.org/download/ahk-u32.zip, % (zip:=A_Temp "\ahk.zip")
		if (ErrorLevel || !FileExist(zip)) {
			m("Failed to download AutoHotkey portable executable...", "!")
			ExitApp
		}
	}
}