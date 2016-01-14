FileMenu(gui:="") {
	;FILE MENU
	Menu, fMenu, Add, Open Custom Hotstrings &Folder, MenuAction
	Menu, fMenu, Icon, Open Custom Hotstrings &Folder, shell32.dll, 46
	Menu, fMenu, Add, Open &Settings File, MenuAction
	Menu, fMenu, Icon, Open &Settings File, shell32.dll, 70
	Menu, fMenu, Add
	Menu, fMenu, Add, E&xit, MenuAction
	Menu, fMenu, Icon, E&xit, shell32.dll, 131
	
	;OPTIONS MENU
	Menu, optsMenu, Add, Remember &Window Position, MenuAction
	Menu, optsMenu, Add
	Menu, optsMenu, % settings.ea("//Options").RememberPosition ? "Check" : "UnCheck", Remember &Window Position
	
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