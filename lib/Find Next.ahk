Find_Next(str, lastRow, searchCol=3) {
	Global
	Local Options:="", Text:="", End:=LV_GetCount(), Row:=lastRow+1
	if (Row > End)
		return m("No (more) matches for", str, "ico:i")
	Loop {
		LV_GetText(Options, Row, 2)
		LV_GetText(Text, Row, 3)
		if (InStr(Options, "R") And !InStr(Options, "R0"))
			Text := From_Raw(Text)
		else
			Text:=StrReplace(StrReplace(Text, "{Enter}", "`n"), "{Tab}", A_Tab)
		if (InStr(Text, str))
			return Row
		Row++
		if (Row > End)
			return m("No (more) matches for", str, "ico:i")
	}
}