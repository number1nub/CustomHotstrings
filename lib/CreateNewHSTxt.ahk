CreateNewHSTxt() {
	try {
		SplitPath, _HS_File,, hsDir
		if (!FileExist(hsDir))
			FileCreateDir, % hsDir
		if (A_IsCompiled)
			FileInstall, Template.txt, % _HS_File
		else {
			FileRead, templateTxt, Template.txt
			FileAppend, %templateTxt%, % _HS_File
		}
		RegWrite, REG_SZ, HKCU, Software\WSNHapps\CustomHotstrings, EditorPath, %A_ScriptFullPath%
		Run, % _HS_File
	}
	catch e {
		m("There was an issue while trying to create the new hotstrings file.", "Aborting...","ico:!")
		ExitApp
	}
}