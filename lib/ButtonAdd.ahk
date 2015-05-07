ButtonAdd() {
	GuiControlGet, ED_1
	GuiControlGet, ED_2
	GuiControlGet, ED_3
	if (!RegExMatch(ED_1, "[^\s]+") Or !RegExMatch(ED_3, "[^\s]+"))
		return
	ED_1:=To_Trigger(ED_1), ED_3:=To_Raw(ED_3)
	LV_Add("", ED_1, ED_2, ED_3)
	_HS := Format(":{1}:{2}::{3}", ED_2, ED_1, ED_3)
	_File .= _HS "`n"
	_Changed := True
	GuiControl, -Disabled, saveButton
	ButtonClear()
}