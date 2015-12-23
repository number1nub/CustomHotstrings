CreateNewHSTxt() {
	static url:="https://raw.githubusercontent.com/number1nub/CustomHotstrings/master/Template.txt"
	
	try {
		SplitPath, _HS_File,, hsDir
		if (!FileExist(hsDir))
			FileCreateDir, % hsDir
		UrlDownloadToFile, %url%, %_HS_File%
		if (ErrorLevel) {
			FileDelete, %_HS_File%
			m("Unable to download the hotstrings base template file.","","Try again later...","!")
			ExitApp
		}
		FileRead, templateTxt, Template.txt
		FileAppend, %templateTxt%, % _HS_File
		RegWrite, REG_SZ, HKCU, Software\WSNHapps\CustomHotstrings, EditorPath, %A_ScriptFullPath%
		Run, % _HS_File
	}
	catch e {
		m("There was an issue while trying to create the new hotstrings file.", "Aborting...","ico:!")
		ExitAppo
	}
}