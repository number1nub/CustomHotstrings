#NoEnv
#SingleInstance, Force
DetectHiddenWindows, on
SetTitleMatchMode, 2
SetWorkingDir, %A_ScriptDir%

myVersion := "1.8.8.3"

hsDir := A_AppData "\WSNHapps\Custom Hotstrings"

global _HS_File:=hsDir "\hsTxt.ahk", _FILE, _STRINGS:="`n", _CHANGED, _TITLE:="Custom Hotstring Manager"
_MATCH := 0
GuiMinHeight := 510
GuiMinWidth := 690

regPath := "Software\WSNHapps\CustomHotstrings"
RegRead, version, HKCU, %regPath%, Version
if (ErrorLevel || !version)
	RegWrite, REG_SZ, HKCU, Software\WSNHapps\CustomHotstrings, Version, % (version:=myVersion)

TrayMenu() {
	Menu, DefaultAHK, Standard
	Menu, Tray, NoStandard
	Menu, Tray, Add, Open Custom Hotstrings Folder, MenuAction
	;~ Menu, Tray, Add, Run hsTxt.ahk, MenuAction
	
	if (!A_IsCompiled) {
		Menu, Tray, Add
		Menu, Tray, Add, Default AHK Menu, :DefaultAHK
	}
	Menu, Tray, Add
	Menu, Tray, Add, Exit, MenuAction
	
	if (A_IsCompiled)
		Menu, Tray, Icon, %A_ScriptFullPath%, -159
	else
		Menu, Tray, Icon, % FileExist(mIco := (A_ScriptDir "\res\hotstrings.ico")) ? mIco : ""
}

MenuAction() {
	if (A_ThisMenuItem = "Run hsTxt.ahk") {
		SendMessage, 0x111, 65303,,, hsTxt.ahk - AutoHotkey
		If (ErrorLevel)
			run, %_HS_FILE%
	}
	else if (A_ThisMenuItem = "Open Custom Hotstrings Folder")
		Run, *explore "%A_ScriptDir%"
}


If (!FileExist(_HS_File))
	CreateNewHSTxt()


;{===== Main GUI ====>>>

;{```` GUI OPTIONS ````}
hsOptions := "|?0: Don't trigger within words|B0: Don't erase trigger string|C: Trigger is case-sensitive|C0: Match case of trigger in replacement|*0: Require space, period or enter to trigger|R0: Send expressions (raw off)"
lvOptions := "cBlack Sort ReadOnly Grid NoSortHdr"
Gui, Font, s11 cWhite, Segoe UI
Gui, Color, 8A4444
Gui, Margin, 10, 10
Gui, % "+HwndWinHwnd +Resize +ToolWindow +AlwaysOnTop +MinSize" GuiMinWidth "x" GuiMinHeight
;}

;{```` TRIGGER ````}
Gui, Add, GroupBox, x10 y10 w850 h225 hwndGB_EditHS section, Edit HotString:
Gui, Add, GroupBox, xm+10 yp+18 w270 h55 hwndGB_Trigger Section, Trigger:
Gui, Add, Edit, xs+10 ys+23 w250 h25 cBlack hwndTriggerID vED_1 gEdit_1
;}

;{```` OPTIONS ````}
Gui, Add, GroupBox, xs+280 ys w545 h55 hwndGB_Options Section, Options
Gui, Add, Edit, xs+10 ys+23 w120 h25 cBlack hwndOptionsID vED_2 gChangedSomething,
Gui, Add, DropDownList, x+5 yp-2 r8 w400 cBlack hwndOptionsListID vaddOption gaddOption, %hsOptions%
Gui, Add, Text, xp+25 yp+4 +BackgroundTrans cADADAD hwndHelpTxtID, < Select from available options > 
;}

;{```` REPLACEMENT TXT ````}
Gui, Add, GroupBox, xm+10 ys+60 w825 h140 hwndGB_Replacement Section, Replacement Text: (Press Find to search)
Gui, Font,, Consolas
Gui, Add, Edit, xs+10 ys+22 w805 h75 cBlack vED_3 hwndReplacementID WantTab WantReturn gChangedSomething
Gui, Font,, Segoe UI
;}

;{```` ACTION BUTTONS ````}
Gui, Add, Button, xs+10 y+6 w85 h28 vBT_Add, &Add
Gui, Add, Button, x+5 yp w85 h28 +Disabled vBT_Repl, &Replace
Gui, Add, Button, x+5 yp w85 h28 vBT_Clear, &Clear
Gui, Add, Button, x+5 yp w85 h28 +default vBT_Find, &Find
;}

;{```` EXISTING HOTSTRINGS ````}
Gui, Add, Groupbox, x10 y+20 h435 w850 hwndGB_Hotstrings Section, HotStrings:
Gui, Add, Button, xs+10 ys+30 w85 h30 , &Edit
Gui, Add, Button, x+5 yp w85 h30, &Delete	
Gui, Add, Button, x+540 yp-1 w110 h30 hwndBtn_EditAHK +Center, E&dit AHK File
Gui, Font, s10
Gui, Add, ListView, xs+10 y+5 w825 h365 vLV_1 gMainList hwndHSListID %lvOptions%, Trigger|Options|Replacement Text
Gui, Font, s11, Segoe UI
;}

;{```` SAVE/CLOSE BUTTONS ````}
Gui, Add, Button, xm+350 y+15 w85 h30 +disabled vsaveButton hwndSaveButton, &Save
Gui, Add, Button, x+10 yp w85 h30 vcloseButton hwndCloseButton, &Close
;}

;{```` VERSION ````}
Gui, Font, s10 italic
Gui, Add, Text, xm+5 yp+15 hwndVersionTxt, version %version%
;}

;{```` FILL LIST VIEW ````}
GoSub, Read_File
LV_ModifyCol(2,70)
;}

;{```` SHOW GUI ````}
Gui, Show,, %_TITLE%
;}

return

;}<<<==== Main GUI =====


GuiSize:
{
	Anchor(GB_EditHS, "w", 1)
	Anchor(GB_Trigger, "w", 1)
	Anchor(TriggerID, "w")
	Anchor(GB_Options, "x", 1)
	Anchor(OptionsID, "x")	
	Anchor(OptionsListID, "x", 1)
	Anchor(HelpTxtID, "x")
	Anchor(GB_Replacement, "w", 1)
	Anchor(ReplacementID, "w")
	Anchor(Btn_EditAHK, "x", 1)
	Anchor(GB_Hotstrings, "wh", 1)
	Anchor(HSListID, "wh", 1)
	Anchor(VersionTxt, "y")
	Anchor(saveButton, "yx.5", 1)
	Anchor(CloseButton, "yx.5", 1)
	return
}

Read_File:
{
	LV_Delete()
	FileRead, _FILE, %_HS_File%
	StringReplace, _FILE, _FILE, `r`n, `n, All
	Loop, Parse, _File, `n, `r
		if RegExMatch(A_LoopField,"^:(.*):(.*)::(.*)", HS_)
			if (HS_3)
				LV_Add("", HS_2, HS_1, HS_3), _STRINGS .= HS_2 "`n"
	_FILE := "`n" _File
	if (SubStr(_FILE, StrLen(_FILE), 1) <> "`n")
		_FILE .= "`n"
	StringTrimRight, _STRINGS, _STRINGS, 1
	LV_ModifyCol(1, "AutoHdr")
	return
}



addOption:
{
	gui, submit, nohide
	StringSplit, opts, %A_GuiControl%, :
	GuiControl, text, Edit2, %ED_2%%opts1%
	GuiControl, Choose, addOption, 1
	GuiControl, Focus, Edit2
	return
}

MainList:
{
	if (A_GuiEvent = "DoubleClick")
		goto, buttonEdit
	return
}

GuiContextMenu:
{
	if (A_GuiControl = "LV_1") {
		Menu, rClick, Add, Edit, buttonEdit
		Menu, rClick, Add, Delete, buttonDelete
		Menu, rClick, Show
		Menu, rClick, DeleteAll
	}
	return
}

ChangedSomething:
{
	return
}

Edit_1:
{
	GuiControlGet, ED_1
	If (!RegExMatch(ED_1, "[^\s]+"))
		return	
	If (InStr(_STRINGS, ED_1))
		ControlSend, , {Home}%ED_1%, ahk_id %HSListID%
	return
}

ButtonEditAHKFile:
{
	run, *edit `"%_HS_File%`"
	sleep, 100
	ExitApp
	return
}

ButtonAdd:
{
	Gui, Submit, NoHide
	If (!RegExMatch(ED_1, "[^\s]+") Or !RegExMatch(ED_3, "[^\s]+"))
		return
	ED_1:=To_Trigger(ED_1), ED_3:=To_Raw(ED_3)
	LV_Add("", ED_1, ED_2, ED_3)
	_HS := Format(":{1}:{2}::{3}", ED_2, ED1, ED_3)
	_FILE .= _HS "`n"
	_CHANGED := True
	GuiControl, -Disabled, saveButton
	Gosub, ButtonClear
	return
}

ButtonReplace:
{
	Gui, Submit, NoHide
	If !(RegExMatch(ED_1, "[^\s]+") && RegExMatch(ED_3, "[^\s]+"))
		return
	ED_1:=To_Trigger(ED_1), ED_3:=To_Raw(ED_3)
	LV_Modify(_Row, "", ED_1, ED_2, ED_3)
	StringReplace, _FILE, _FILE, `n%_HS%`n, `n:%ED_2%:%ED_1%::%ED_3%`n
	_CHANGED := True
	GuiControl, -Disabled, saveButton
	Gosub, ButtonClear
	return
}

ButtonClear:
{
	GuiControl, Enable, BT_Add
	GuiControl, Disable, BT_Repl
	GuiControl, Enable, BT_Find
	GuiControl, , ED_1 ; reset to blank
	GuiControl, , ED_2 ; reset to blank
	GuiControl, , ED_3 ; reset to blank
	ControlFocus, Edit1
	return
}

ButtonFind:
{
	Gui, Submit, NoHide
	If (!RegExMatch(ED_3, "[^\s]+"))
		return
	If (ED_3 != _SEARCH)
		_MATCH:=0, _SEARCH:=ED_3
	_MATCH := Find_Next(ED_3, _MATCH)
	If (_MATCH)
		LV_Modify(_MATCH, "Select Focus Vis")
	return
}

ButtonEdit:
{
	_Row := LV_GetNext()
	If (!_Row)
		return	
	Loop, % LV_GetCount("Col")
		LV_GetText(ED_%A_Index%, _Row, A_Index)
	
	_HS := ":" ED_2 ":" ED_1 "::" ED_3
	ED_1 := From_Trigger(ED_1)
	ED_3 := From_Raw(ED_3)
	
	GuiControl, Disable, BT_Add
	GuiControl, Enable, BT_Repl
	GuiControl, Disable, BT_Find	
	GuiControl, , ED_1, % ED_1
	GuiControl, , ED_2, % ED_2
	GuiControl, , ED_3, % ED_3
	_CHANGED := False
	return
}

ButtonDelete:
{
	_Row := LV_GetNext()
	If (!_Row)
		return
	
	; Get the full text from the selected item
	Loop, % LV_GetCount("Col")
		LV_GetText(ED_%A_Index%, _Row, A_Index)
	_HS := ":" ED_2 ":" ED_1 "::" ED_3
	
	; Determine if the selected hotstring is a "Multi-Line" entry. If it
	; is, loop through the file and retrieve all lines associated with it
	if (RegExMatch(ED_3, "i)\s*?;\s*?<+?\s*?Multi-Line.*?>+"))
	{
		delText := SubStr(_FILE, InStr(_FILE, _HS) + StrLen(_HS))
		loop, Parse, delText, `n
		{
			_HS .= A_LoopField "`n"
			if (RegExMatch(A_LoopField, "i)^\s*?return.*?"))
			{
				_HS := RegExReplace(_HS, "i)\n$")
				break
			}
		}
	}
	; Verify delete. Mostly to ensure that multi-lines are handled correctly
	if (m("Are you sure you want to delete the hotstring:", "_HS", "btn:yn", "ico:?") = "YES") {
		LV_Delete(_Row)
		StringReplace, _FILE, _FILE, `n%_HS%`n, `n
		GuiControl, Enable, BT_Add
		GuiControl, Disable, BT_Repl
		GuiControl, Enable, BT_Find
		_CHANGED := True
		GuiControl, -Disabled, saveButton
	}
	return
}

ButtonSave:
{
	Gui, +OwnDialogs
	If (FileExist(_HS_FILE "_New")) {
		FileDelete, %_HS_FILE%_New
		If (ErrorLevel) {
			m("Couldn't delete " _HS_FILE "_New", "ico:!")
			return
		}
	}
	FileAppend, % SubStr(_FILE, 2, StrLen(_FILE) -2), %_HS_FILE%_New
	If (ErrorLevel) {
		m("Couldn't write to " _HS_FILE "_New", "ico:!")
		return
	}
	FileMove, %_HS_FILE%_New, %_HS_FILE%, 1
	If (ErrorLevel)
		MsgBox, 4112, %_TITLE%, Couldn't overwrite %_HS_FILE%
	_CHANGED := False
	
	sleep, 100
	SendMessage, 0x111, 65303,,, hsTxt.ahk - AutoHotkey
	If (ErrorLevel)
		run, %_HS_FILE%
	return
}


StatusChange(status := "") {	
	global _CHANGED := status ? !_CHANGED : status
	GuiControl, % (_CHANGED ? "+" : "-") "Disabled", ButtonSave
}

GuiClose() {
	GuiEscape:
	ButtonQuit:
	ButtonClose:
	Gui, +OwnDialogs
	If (_CHANGED) {
		MsgBox, 4132, %_TITLE%,
	   (LTrim
		  You've changed your hotstrings!

		  Do you want to save the changes?
	   )
		IfMsgBox, Yes
			Gosub, ButtonSave
	}
	If (A_GuiControl = "&Quit") {
		Gui, Destroy
		ExitApp
	}
	exitapp
}

Find_Next(str, lastRow, searchCol = 3) {
	Global
	Local Options := ""
	Local Text := ""
	Local End := LV_GetCount()
	Local Row := lastRow + 1
	If (Row > End) {
		MsgBox, 4160, %_TITLE%, No (more) matches for`n%str%
		return 0
	}
	Loop {
		LV_GetText(Options, Row, 2)
		LV_GetText(Text, Row, 3)
		If (InStr(Options, "R") And !InStr(Options, "R0"))
			Text := From_Raw(Text)
		Else
		{
			StringReplace, Text, Text, {Tab}, %A_Tab%, All
			StringReplace, Text, Text, {Enter}, `n, All
		}
		If (InStr(Text, str))
			return Row
		Row++
		If (Row > End)
		{
			MsgBox, 4160, %_TITLE%, No (more) matches for`n%str%
			return 0
		}
	}
}

To_Raw(String) {
	StringReplace, String, String, ``, ````, All
	StringReplace, String, String, `r`n, ``r, All
	StringReplace, String, String, `n, ``r, All
	StringReplace, String, String, %A_Tab%, ``t, All
	StringReplace, String, String, `;, ```;, All
	StringReplace, String, String, `:, ```:, All
	return String
}

From_Raw(String) {
	StringReplace, String, String, ``r, `r`n, All
	StringReplace, String, String, ``t, %A_Tab%, All
	StringReplace, String, String, ```;, `;, All
	StringReplace, String, String, ```:, `:, All
	StringReplace, String, String, ````, ``, All
	return String
}

To_Trigger(String) {
	StringReplace, String, String, <ENTER>, ``n, All
	StringReplace, String, String, <TAB>, ``t, All
	StringReplace, String, String, <SPACE>, %A_Space%, All
	return String
}

From_Trigger(String) {
	StringReplace, String, String,``n, <ENTER>, All
	StringReplace, String, String, %A_Space%, <SPACE>, All
	StringReplace, String, String, ``t, <TAB>, All
	StringReplace, String, String, %a_tab%, <TAB>, All
	return String
}

ControlActive(Control_Name, winTitle) {
	ControlGetFocus, Active_Control, %winTitle%
	If Active_Control = %Control_Name%
		return 1
}

m(t*) {
	opt:=4096, cnt:=0, icons:={x:16,"?":32,"!":48,i:64}, btns:={c:1,oc:1,co:1,ync:3,nyc:3,cyn:3,cny:3,yn:4,ny:4,rc:5,cr:5}
	for c, v in t {
		btn1:=ico1:=ttl1:=""
		if RegExMatch(v,"i)btn:(c|\w{2,3})",btn)||RegExMatch(v,"i)ico:(x|\?|\!|i)",ico)||RegExMatch(v,"i)(?:ttl|title):(.+)",ttl)
			opt+=btn1?btns[btn1]:ico1?icons[ico1]:0, title.=ttl1?ttl1:""
		else
			txt .= (txt ? "`n" : "") v
	}
	MsgBox, % opt, % title, % txt
	IfMsgBox,OK
		return "OK"
	else IfMsgBox,Yes
		return "YES"
	else IfMsgBox,No
		return "NO"
	else IfMsgBox,Cancel
		return "CANCEL"
	else IfMsgBox,Retry
		return "RETRY"
}

CreateNewHSTxt() {
	try {
		SplitPath, _HS_File,, hsDir
		if (!FileExist(hsDir))
			FileCreateDir, % hsDir
		if (A_IsCompiled) {
			FileInstall, Template.txt, % _HS_File
			RegWrite, REG_SZ, HKCU, Software\WSNHapps\CustomHotstrings, EditorPath, %A_ScriptFullPath%
		}
		else {
			FileRead, templateTxt, Template.txt
			FileAppend, %templateTxt%, % _HS_File
		}
		Run, % _HS_File
	}
	catch e {
		m("There was an issue while trying to create the new hotstrings file.", "Aborting...","ico:!")
		ExitApp
	}
}


#If controlActive("Edit1", _TITLE)

space:: Send, {Blind}<SPACE>
Enter:: Send, {Blind}<ENTER>
tab::   Send, {Blind}<TAB>
^tab::  Send, {Blind}`t	
bs::
cbBU := Clipboard, KD := A_KeyDelay, BL := A_BatchLines
Clipboard := ""
SetKeyDelay, -1
SetBatchLines, -1
send, {Blind}+{Home}
send, {Blind}^c
ClipWait, 1
If (ErrorLevel)
	Send, {Blind}{Right}
else if (RegExMatch(Clipboard, "i)(.*?)(\<\w+\>)$", v))
	Clipboard := v1
else
	Clipboard := SubStr(Clipboard, 1, -1)
Send, {Blind}^v
return

#If controlActive("SysListView321", _TITLE)
Delete::goto, buttonDelete

#If