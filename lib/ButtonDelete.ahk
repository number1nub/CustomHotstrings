ButtonDelete:
{
	_Row := LV_GetNext()
	if (!_Row)
		return
	
	; Get the full text from the selected item
	Loop, % LV_GetCount("Col")
		LV_GetText(ED_%A_Index%, _Row, A_Index)
	_HS := ":" ED_2 ":" ED_1 "::" ED_3
	
	; Determine if the selected hotstring is a "Multi-Line" entry. if it
	; is, loop through the file and retrieve all lines associated with it
	if (RegExMatch(ED_3, "i)\s*?;\s*?<+?\s*?Multi-Line.*?>+")) {
		delText := SubStr(_File, InStr(_File, _HS) + StrLen(_HS))
		loop, Parse, delText, `n
		{
			_HS .= A_LoopField "`n"
			if (RegExMatch(A_LoopField, "i)^\s*?return.*?")) {
				_HS := RegExReplace(_HS, "i)\n$")
				break
			}
		}
	}
	; Verify delete. Mostly to ensure that multi-lines are handled correctly
	if (m("Are you sure you want to delete the hotstring:", _HS, "btn:yn", "ico:?") = "YES") {
		LV_Delete(_Row)
		StringReplace, _File, _File, `n%_HS%`n, `n
		GuiControl, Enable, BT_Add
		GuiControl, Disable, BT_Repl
		GuiControl, Enable, BT_Find
		_Changed := True
		GuiControl, -Disabled, saveButton
	}
	return
}