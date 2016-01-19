FileMenu(gui:="") {
	;FILE MENU
	Menu, fMenu, Add, Open Custom Hotstrings &Folder, MenuAction
	Menu, fMenu, Icon, Open Custom Hotstrings &Folder, shell32.dll, 127
	Menu, fMenu, Add, Open &Settings File, MenuAction
	Menu, fMenu, Icon, Open &Settings File, shell32.dll, 70
	Menu, fMenu, Add
	Menu, fMenu, Add, E&xit, MenuAction
	Menu, fMenu, Icon, E&xit, shell32.dll, 132
	
	;OPTIONS MENU
	Menu, optsMenu, Add, Keep Window On &Top, MenuAction
	Menu, optsMenu, % settings.ssn("//Gui[1]/Options/Option[text()='AlwaysOnTop']").text ? "Check":"UnCheck", Keep Window on &Top
	Menu, optsMenu, Add, &Remember Window Position, MenuAction
	Menu, optsMenu, % settings.ea("//Options").RememberPosition ? "Check" : "UnCheck", &Remember Window Position
	Menu, optsMenu, Add
	Menu, optsMenu, Add, GUI &Color, MenuAction
	Menu, optsMenu, Icon,  GUI &Color, imageres.dll, 110
	
	;HELP MENU
	Menu, helpMenu, Add, &About, MenuAction
	Menu, helpMenu, Icon, &About, shell32.dll, 278
	
	;CREATE GUI MENU, BAR
	Menu, MenuBar, Add, &File, :fMenu
	Menu, MenuBar, Add, &Options, :optsMenu
	;~ Menu, MenuBar, Add, &Help, :helpMenu
	
	if (gui)
		Gui, %gui%:Default
	Gui, Menu, MenuBar
}