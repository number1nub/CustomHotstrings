ButtonReplace:
{
	Gui, Submit, NoHide
	_Row := LV_GetNext()
	if !(RegExMatch(ED_1, "[^\s]+") && RegExMatch(ED_3, "[^\s]+"))
		return
	ED_1:=To_Trigger(ED_1), ED_3:=!multi ? To_Raw(ED_3) : ED_3
	LV_Modify(_Row, "", ED_1, ED_2, ED_3)
	StringReplace, _File, _File, `n%_HS%`n, `n:%ED_2%:%ED_1%::%ED_3%`n
	_Changed := True
	GuiControl, -Disabled, saveButton
	ButtonClear()
	return
}