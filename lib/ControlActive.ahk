ControlActive(Control_Name, winTitle) {
	ControlGetFocus, Active_Control, %winTitle%
	if (Active_Control = Control_Name)
		return 1
}