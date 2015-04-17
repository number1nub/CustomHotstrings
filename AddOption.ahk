AddOption() {
	AddOption:
	Gui, Submit, NoHide
	GuiControlGet, exOpts,, ED_2
	GuiControl,, ED_2, % exOpts StrSplit(%A_GuiControl%,":")[1]
	GuiControl, Choose, addOption, 1
	GuiControl, Focus, ED_2
	ControlSend, Edit2, ^{End}
	return
}