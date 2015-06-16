TrayMenu() {
	Menu, DefaultAHK, Standard
	Menu, Tray, NoStandard
	Menu, Tray, Add, Remember Window Position, MenuAction
	Menu, Tray, % settings.ea("//Options").RememberPosition ? "Check" : "UnCheck", Remember Window Position
	Menu, Tray, Add, Open Custom Hotstrings Folder, MenuAction
	Menu, Tray, Add, Open Settings File, MenuAction
	if (!A_IsCompiled) {
		Menu, Tray, Add
		Menu, Tray, Add, Default AHK Menu, :DefaultAHK
	}
	Menu, Tray, Add
	Menu, Tray, Add, Exit, MenuAction
	
	if (A_IsCompiled)
		Menu, Tray, Icon, %A_ScriptFullPath%, -159
	else
		Menu, Tray, Icon, % FileExist(mIco := (A_ScriptDir "\hotstrings.ico")) ? mIco : ""
}