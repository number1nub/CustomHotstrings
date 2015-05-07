ButtonClear() {
	GuiControl, Enable, BT_Add
	GuiControl, Disable, BT_Repl
	GuiControl, Enable, BT_Find
	GuiControl,, ED_1
	GuiControl,, ED_2
	GuiControl,, ED_3
	ControlFocus, Edit1
}