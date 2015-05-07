From_Trigger(String) {
	StringReplace, String, String,``n, <ENTER>, All
	StringReplace, String, String, %A_Space%, <SPACE>, All
	StringReplace, String, String, ``t, <TAB>, All
	StringReplace, String, String, %a_tab%, <TAB>, All
	return String
}