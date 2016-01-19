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
	else if (mi = "GUI Color") {
		gui, +OwnDialogs
		InputBox, clr, Change GUI Color, Enter GUI Background Color:,,,,,,,, % (curColor:=settings.ssn("//Style/Color/@Background")).text
		if (ErrorLevel || clr="" || clr=curColor.text)
			return
		curColor.text := clr
		Shutdown(1)
	}
	else if ("Keep Window on Top") {
		optsPath := "//Gui[@ID='1']/Options"
		if (aot:=settings.ssn(optsPath "/Option[text()='AlwaysOnTop']")) {
			Gui, 1:-AlwaysOnTop
			settings.Remove(aot)
		}
		else {
			settings.under(settings.ssn(optsPath), "Option",, "AlwaysOnTop")
			Gui, 1:+AlwaysOnTop
		}
		Menu, optsMenu, ToggleCheck, %A_ThisMenuItem%
		Menu, Tray, ToggleCheck, %A_ThisMenuItem%
		settings.Save(1)
	}
	else
		m("Not yet implemented", "ico:i")
}