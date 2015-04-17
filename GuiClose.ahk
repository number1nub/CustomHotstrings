GuiClose() {
	GuiEscape:
	ButtonQuit:
	ButtonClose:
	Gui, +OwnDialogs
	if (_Changed) {
		MsgBox, 4132, %_Title%,
	   (LTrim
		  You've changed your hotstrings!

		  Do you want to save the changes?
	   )
		ifMsgBox, Yes
			Gosub, ButtonSave
	}
	if (A_GuiControl = "&Quit") {
		Gui, Destroy
		ExitApp
	}
	exitapp
}