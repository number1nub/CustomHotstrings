Read_File:
{
	LV_Delete()
	FileRead, _File, %_HS_File%
	StringReplace, _File, _File, `r`n, `n, All
	Loop, Parse, _File, `n, `r
		if RegExMatch(A_LoopField,"^:(.*):(.*)::(.*)", HS_)
			if (HS_3)
				LV_Add("", HS_2, HS_1, HS_3), _Strings .= HS_2 "`n"
	_File := "`n" _File
	if (SubStr(_File, StrLen(_File), 1) <> "`n")
		_File .= "`n"
	StringTrimRight, _Strings, _Strings, 1
	LV_ModifyCol(1, "AutoHdr")
	return
}