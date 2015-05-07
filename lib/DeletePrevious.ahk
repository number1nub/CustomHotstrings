DeletePrevious() {
	cbBU:=Clipboard, Clipboard:=""
	SendInput, {Blind}+{Home}
	SendInput, {Blind}^c
	ClipWait, 1
	if (ErrorLevel) {
		SendInput, {Blind}{Right}
		return
	}
	Clipboard := RegExMatch(Clipboard,"i)(.*?)(\<\w+\>)$",v) ? v1 : SubStr(Clipboard,1,-1)
	SendInput, {Blind}^v
}