ButtonEdit:
{
	_Row := LV_GetNext()
	if (!_Row)
		return
	Loop, % LV_GetCount("Col")
		LV_GetText(ED_%A_Index%, _Row, A_Index)
	
	_HS := ":" ED_2 ":" ED_1 "::" ED_3
	ED_1 := From_Trigger(ED_1)
	ED_3 := From_Raw(ED_3)
	
	GuiControl, Disable, BT_Add
	GuiControl, Enable, BT_Repl
	GuiControl, Disable, BT_Find	
	GuiControl,, ED_1, % ED_1
	GuiControl,, ED_2, % ED_2
	GuiControl,, ED_3, % ED_3
	_Changed := False
	return
}