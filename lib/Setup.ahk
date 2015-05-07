Setup(dir="") {
	_HSDir   := dir ? dir : A_AppData "\WSNHapps\Custom Hotstrings"
	_HS_File :=_HSDir "\hsTxt.ahk"
	regPath  := "Software\WSNHapps\CustomHotstrings"
	_Strings := "`n"
	_Title   := "Custom Hotstring Manager"
	settings := new Xml("settings", _HSDir "\settings.xml")
	
	if (!settings.fileExists) {
		settings.add2("Options", {RememberPosition:1},"")
		style := settings.add2("Style")
		settings.under(style, "Color", {Background:"8A4444", Control:"White"})
		settings.under(style, "Font", {Font:"Segoe UI", Color:"White", Size:11})
		guis := settings.add2("Guis")
		gui := settings.under(guis, "Gui", {ID:1, Name:"Custom Hotstring Manager"})
		settings.under(gui, "Margin",{x:10, y:5})
		settings.under(gui, "Position", {x:"Center", y:"Center"}, "xCenter yCenter")
		guiOpts := settings.under(gui, "Options")
		settings.under(guiOpts, "Option",, "Resize")
		settings.under(guiOpts, "Option",, "ToolWindow")
		settings.under(guiOpts, "Option",, "AlwaysOnTop")
		settings.under(guiOpts, "Option",, "MinSize690x510")
		hsopts := settings.add2("HSOptions")
		settings.under(hsopts, "Option",, "?0: Don't trigger within words")
		settings.under(hsopts, "Option",, "B0: Don't erase trigger")
		settings.under(hsopts, "Option",, "C: Trigger is case-sensitive")
		settings.under(hsopts, "Option",, "C0: Match case of trigger in replacement")
		settings.under(hsopts, "Option",, "*0: Require space, period or enter to trigger")
		settings.under(hsopts, "Option",, "R0: Send expressions (raw off)")
		settings.save(1)
	}
	
	RegRead, edPath, HKCU, %regPath%, EditorPath
	if (ErrorLevel || (A_IsCompiled && edPath != A_ScriptFullPath))
		RegWrite, REG_SZ, HKCU, %regPath%, EditorPath, %A_ScriptFullPath%
	
	if (!FileExist(_HS_File))
		CreateNewHSTxt()
}