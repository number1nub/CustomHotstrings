ButtonSave:
{
	Gui, +OwnDialogs
	if (FileExist(_HS_File "_New")) {
		FileDelete, %_HS_File%_New
		if (ErrorLevel) {
			m("Couldn't delete " _HS_File "_New", "ico:!")
			return
		}
	}
	FileAppend, % SubStr(_File, 2, StrLen(_File) -2), %_HS_File%_New
	if (ErrorLevel) {
		m("Couldn't write to " _HS_File "_New", "ico:!")
		return
	}
	FileMove, %_HS_File%_New, %_HS_File%, 1
	if (ErrorLevel)
		MsgBox, 4112, %_Title%, Couldn't overwrite %_HS_File%
	_Changed := False	
	sleep, 100
	SendMessage, 0x111, 65303,,, hsTxt.ahk - AutoHotkey
	if (ErrorLevel)
		run, %_HS_File%
	return
}