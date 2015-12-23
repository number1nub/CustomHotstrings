ButtonEdit:
{
	_Row := LV_GetNext()
	if (!_Row)
		return
	Loop, % LV_GetCount("Col")
		LV_GetText(ED_%A_Index%, _Row, A_Index)
	
	_HS := ":" ED_2 ":" ED_1 "::" ED_3
	
	if (multi:=RegExMatch(ED_3, "i)\s*?;\s*?<+?\s*?Multi-Line.*?>+")) {
		edText:=SubStr(_File, InStr(_File, _HS) + StrLen(_HS)), topLine:=_HS
		loop, Parse, edText, `n
		{
			_HS.=A_LoopField "`n"
			if (RegExMatch(A_LoopField, "i)^\s*?return.*?")) {
				_HS := RegExReplace(_HS, "i)\n$")
				break
			}
		}
		ED_3 := StrReplace(_HS, topLine "`n")
	}
	
	ED_1 := From_Trigger(ED_1)
	ED_3 := !multi ? From_Raw(ED_3) : ED_3
	
	GuiControl, Disable, BT_Add
	GuiControl, Enable, BT_Repl
	GuiControl, Disable, BT_Find	
	GuiControl,, ED_1, % ED_1
	GuiControl,, ED_2, % ED_2
	GuiControl,, ED_3, % ED_3
	_Changed := False
	return
}