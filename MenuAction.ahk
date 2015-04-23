MenuAction() {
	if (A_ThisMenuItem = "Run hsTxt.ahk") {
		SendMessage, 0x111, 65303,,, hsTxt.ahk - AutoHotkey
		if (ErrorLevel)
			run, %_HS_File%
	}
	else if (A_ThisMenuItem = "Open Custom Hotstrings Folder")
		Run, *explore "%A_ScriptDir%"
	else if (A_ThisMenuItem = "Remember Window Position") {
		Menu, Tray, ToggleCheck, %A_ThisMenuItem%
		cur := settings.ea("//Options").RememberPosition
		settings.ssn("//Options/@RememberPosition").text := cur ? 0 : 1
		settings.save(1)
	}		
}