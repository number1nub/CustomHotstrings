Setup(dir="") {
	Version   = ;auto_version
	_HSDir   := dir ? dir : A_AppData "\WSNHapps\Custom Hotstrings"
	_HS_File :=_HSDir "\hsTxt.ahk"
	regPath  := "Software\WSNHapps\CustomHotstrings"
	_Strings := "`n"
	_Title   := "Custom Hotstring Manager"
	
	RegRead, edPath, HKCU, %regPath%, EditorPath
	if (ErrorLevel)
		RegWrite, REG_SZ, HKCU, %regPath%, EditorPath, %A_ScriptFullPath%
	
	if (!FileExist(_HS_File))
		CreateNewHSTxt()	
}