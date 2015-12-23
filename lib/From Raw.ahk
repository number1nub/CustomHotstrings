From_Raw(String) {
	StringReplace, String, String, ``r, `r`n, All
	StringReplace, String, String, ``t, %A_Tab%, All
	StringReplace, String, String, ```;, `;, All
	StringReplace, String, String, ```:, `:, All
	StringReplace, String, String, ````, ``, All
	return String
}