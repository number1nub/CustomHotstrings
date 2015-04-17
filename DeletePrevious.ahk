DeletePrevious() {
	cbBU:=Clipboard, Clipboard:=""
	SendInput, +{Home}
	SendInput, {Blind}^c
	ClipWait, 1
	if (ErrorLevel) {
		SendInput, {Right}
		return
	}
	Clipboard := RegExMatch(Clipboard,"i)(.*?)(\<\w+\>)$",v) ? v1 : SubStr(Clipboard,1,-1)
	SendInput, {Blind}^v
}