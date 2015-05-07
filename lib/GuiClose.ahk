GuiClose() {
	GuiEscape:
	ButtonQuit:
	ButtonClose:
	if (_Changed)
		if (m("You've changed your hotstrings!`n", "Save Changes??", "btn:yn", "ico:!") = "Yes")
			Gosub, ButtonSave
	pos := settings.ssn("//Guis/Gui[@ID='" A_Gui "']/Position")
	WinGetPos, wx, wy, ww, wh
	for c, v in {x:wx, y:wy, w:ww, h:wh}
		pos.setAttribute(c, v), posStr.=" " c v
	pos.text := Trim(posStr)
	settings.save(1)
	Exitapp
}