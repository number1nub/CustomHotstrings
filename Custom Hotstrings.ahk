/*
* * * Compile_AHK SETTINGS BEGIN * * *

[AHK2EXE]
Exe_File=%In_Dir%\build\Custom Hotstrings.exe
Created_Date=1
[VERSION]
Resource_Files=%In_Dir%\hotstrings.ico
Set_Version_Info=1
Company_Name=WSNHapps
File_Description=Quickly create, edit and remove custom text replacement hotstrings.
File_Version=;auto_version
Inc_File_Version=0
Internal_Name=Custom Hotstrings.ahk
Original_Filename=Custom Hotstrings.ahk
Product_Name=Custom Hotstrings
Product_Version=;auto_version
[ICONS]
Icon_1=%In_Dir%\hotstrings.ico

* * * Compile_AHK SETTINGS END * * *
*/
#NoEnv
#SingleInstance, Force
DetectHiddenWindows, on
SetTitleMatchMode, 2
SetWorkingDir, %A_ScriptDir%

global Version, _HS_File, _File, _Strings, _Search, _Match, _Changed, _Title

Setup()

;{===== Main GUI ====>>>

;{```` GUI OPTIONS ````}
GuiMinHeight := 510
GuiMinWidth  := 690
hsOptions    := "|?0: Don't trigger within words"
			  . "|B0: Don't erase trigger string"
			  . "|C: Trigger is case-sensitive"
			  . "|C0: Match case of trigger in replacement"
			  . "|*0: Require space, period or enter to trigger"
			  . "|R0: Send expressions (raw off)"
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
Gui, Add, DropDownList, x+5 yp-2 r8 w400 -TabStop cBlack hwndOptionsListID vaddOption gaddOption, %hsOptions%
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
Gui, Add, Button, x+5 yp w85 h28 +default vBT_Find Disabled, &Find
;}

;{```` EXISTING HOTSTRINGS ````}
Gui, Add, Groupbox, x10 y+20 h435 w850 hwndGB_Hotstrings Section, HotStrings:
Gui, Add, Button, xs+10 ys+30 w85 h30, &Edit
Gui, Add, Button, x+5 yp w85 h30, &Delete
Gui, Add, Button, x+540 yp-1 w110 h30 hwndBtn_EditAHK +Center, E&dit AHK File
Gui, Font, s10
Gui, Add, ListView, xs+10 y+5 w825 h365 vLV_1 gMainList hwndHSListID cBlack Sort ReadOnly Grid NoSortHdr, Trigger|Options|Replacement Text
Gui, Font, s11, Segoe UI
;}

;{```` SAVE/CLOSE BUTTONS ````}
Gui, Add, Button, xm+350 y+15 w85 h30 +disabled vsaveButton hwndSaveButton, &Save
Gui, Add, Button, x+10 yp w85 h30 vcloseButton hwndCloseButton, &Close
;}

;{```` VERSION ````}
Gui, Font, s10 italic
Gui, Add, Text, xm+5 yp+15 hwndVersionTxt, version %Version%
;}

;{```` FILL LIST VIEW ````}
GoSub, Read_File
LV_ModifyCol(2,70)
;}

;{```` SHOW GUI ````}
Gui, Show,, %_Title%
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
	FileRead, _File, %_HS_File%
	StringReplace, _File, _File, `r`n, `n, All
	Loop, Parse, _File, `n, `r
		if RegExMatch(A_LoopField,"^:(.*):(.*)::(.*)", HS_)
			if (HS_3)
				LV_Add("", HS_2, HS_1, HS_3), _Strings .= HS_2 "`n"
	_File := "`n" _File
	if (SubStr(_File, StrLen(_File), 1) <> "`n")
		_File .= "`n"
	StringTrimRight, _Strings, _Strings, 1
	LV_ModifyCol(1, "AutoHdr")
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

ButtonAdd() {
	GuiControlGet, ED_1
	GuiControlGet, ED_2
	GuiControlGet, ED_3
	if (!RegExMatch(ED_1, "[^\s]+") Or !RegExMatch(ED_3, "[^\s]+"))
		return
	ED_1:=To_Trigger(ED_1), ED_3:=To_Raw(ED_3)
	LV_Add("", ED_1, ED_2, ED_3)
	_HS := Format(":{1}:{2}::{3}", ED_2, ED_1, ED_3)
	_File .= _HS "`n"
	_Changed := True
	GuiControl, -Disabled, saveButton
	ButtonClear()
}

ButtonReplace:
{
	Gui, Submit, NoHide
	_Row := LV_GetNext()
	if !(RegExMatch(ED_1, "[^\s]+") && RegExMatch(ED_3, "[^\s]+"))
		return
	ED_1:=To_Trigger(ED_1), ED_3:=To_Raw(ED_3)
	LV_Modify(_Row, "", ED_1, ED_2, ED_3)
	StringReplace, _File, _File, `n%_HS%`n, `n:%ED_2%:%ED_1%::%ED_3%`n
	_Changed := True
	GuiControl, -Disabled, saveButton
	ButtonClear()
	return
}

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

ButtonClear() {
	GuiControl, Enable, BT_Add
	GuiControl, Disable, BT_Repl
	GuiControl, Enable, BT_Find
	GuiControl,, ED_1
	GuiControl,, ED_2
	GuiControl,, ED_3
	ControlFocus, Edit1
}

ButtonDelete:
{
	_Row := LV_GetNext()
	if (!_Row)
		return
	
	; Get the full text from the selected item
	Loop, % LV_GetCount("Col")
		LV_GetText(ED_%A_Index%, _Row, A_Index)
	_HS := ":" ED_2 ":" ED_1 "::" ED_3
	
	; Determine if the selected hotstring is a "Multi-Line" entry. if it
	; is, loop through the file and retrieve all lines associated with it
	if (RegExMatch(ED_3, "i)\s*?;\s*?<+?\s*?Multi-Line.*?>+"))
	{
		delText := SubStr(_File, InStr(_File, _HS) + StrLen(_HS))
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
	if (m("Are you sure you want to delete the hotstring:", _HS, "btn:yn", "ico:?") = "YES") {
		LV_Delete(_Row)
		StringReplace, _File, _File, `n%_HS%`n, `n
		GuiControl, Enable, BT_Add
		GuiControl, Disable, BT_Repl
		GuiControl, Enable, BT_Find
		_Changed := True
		GuiControl, -Disabled, saveButton
	}
	return
}

ButtonSave:
{
	Gui, +OwnDialogs
	if (FileExist(_HS_File "_New")) {
		FileDelete, %_HS_File%_New
		if (ErrorLevel) {
			m("Couldn't delete " _HS_File "_New", "ico:!")
			return
		}
	}
	FileAppend, % SubStr(_File, 2, StrLen(_File) -2), %_HS_File%_New
	if (ErrorLevel) {
		m("Couldn't write to " _HS_File "_New", "ico:!")
		return
	}
	FileMove, %_HS_File%_New, %_HS_File%, 1
	if (ErrorLevel)
		MsgBox, 4112, %_Title%, Couldn't overwrite %_HS_File%
	_Changed := False
	
	sleep, 100
	SendMessage, 0x111, 65303,,, hsTxt.ahk - AutoHotkey
	if (ErrorLevel)
		run, %_HS_File%
	return
}

#if controlActive("Edit1", _Title)

space::SendInput, {Blind}<SPACE>
Enter::SendInput, {Blind}<ENTER>
tab::  SendInput, {Blind}<TAB>
^tab:: SendInput, {Blind}`t
bs::   DeletePrevious()


#if controlActive("SysListView321", _Title)
Delete::goto, buttonDelete
#if


#Include Anchor.ahk
#Include ControlActive.ahk
#Include CreateNewHSTxt.ahk
#Include Find Next.ahk
#Include From Raw.ahk
#Include From Trigger.ahk
#Include GuiClose.ahk
#Include m.ahk
#Include MenuAction.ahk
#Include StatusChange.ahk
#Include To Raw.ahk
#Include To Trigger.ahk
#Include TrayMenu.ahk
#Include DeletePrevious.ahk
#Include AddOption.ahk
#Include Setup.ahk
#Include ButtonEdit.ahk
#Include ButtonEditAHKFile.ahk
#Include ChangedSomething.ahk
#Include Edit 1.ahk
#Include MainList.ahk