CmdLine(info*) {
	Loop, %info%
		plist .= (plist ? " " : "") %A_Index%
	Params := Args(plist)
	if (Params.update) {
		if (!CheckUpdate())
			m("No update found.", "ico:i")
		ExitApp
	}
}