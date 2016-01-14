MenuAction() {
	mi := StrReplace(A_ThisMenuItem, "&")
	
	if (mi = "Run hsTxt.ahk") {
		SendMessage, 0x111, 65303,,, hsTxt.ahk - AutoHotkey
		if (ErrorLevel)
			run, %_HS_File%
	}
	else if (mi = "Open Custom Hotstrings Folder") {
		Run, *explore "%A_ScriptDir%"
		ExitApp
	}
	else if (mi = "Remember Window Position") {
		Menu, Tray, ToggleCheck, %A_ThisMenuItem%
		Menu, optsMenu, ToggleCheck, %A_ThisMenuItem%
		cur := settings.ea("//Options").RememberPosition
		settings.ssn("//Options/@RememberPosition").text := cur ? 0 : 1
		settings.save(1)
	}
	else if (mi = "Open Settings File") {
		run, % "*edit " settings.file
		ExitApp
	}
}