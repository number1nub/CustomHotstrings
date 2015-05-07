To_Raw(String) {
	StringReplace, String, String, ``, ````, All
	StringReplace, String, String, `r`n, ``r, All
	StringReplace, String, String, `n, ``r, All
	StringReplace, String, String, %A_Tab%, ``t, All
	StringReplace, String, String, `;, ```;, All
	StringReplace, String, String, `:, ```:, All
	return String
}