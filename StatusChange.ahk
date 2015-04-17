StatusChange(status := "") {	
	global _Changed := status ? !_Changed : status
	GuiControl, % (_Changed ? "+" : "-") "Disabled", ButtonSave
}