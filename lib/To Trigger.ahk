To_Trigger(String) {
	StringReplace, String, String, <ENTER>, ``n, All
	StringReplace, String, String, <TAB>, ``t, All
	StringReplace, String, String, <SPACE>, %A_Space%, All
	return String
}