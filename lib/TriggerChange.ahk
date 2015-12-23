TriggerChange() {
	GuiControlGet, ED_1
	if (!RegExMatch(ED_1, "[^\s]+"))
		return	
	if (InStr(_Strings, ED_1))
		ControlSend, SysListView321, {Blind}{Home}%ED_1%
	return
}