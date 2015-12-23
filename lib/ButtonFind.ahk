ButtonFind() {
	GuiControlGet, ED_3
	if (!RegExMatch(ED_3, "[^\s]+"))
		return
	if (ED_3 != _SEARCH)
		_MATCH:=0, _SEARCH:=ED_3
	_MATCH := Find_Next(ED_3, _MATCH)
	if (_MATCH~="\d+")
		LV_Modify(_MATCH, "Select Focus Vis")
	return
}