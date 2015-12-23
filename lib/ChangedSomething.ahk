ChangedSomething() {
	GuiControlGet, ED_3
	GuiControl, % "Enable" (ED_3?1:0), BT_Find
}