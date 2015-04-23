#NoEnv
#SingleInstance, Force
DetectHiddenWindows, on
SetTitleMatchMode, 2
SetWorkingDir, %A_ScriptDir%

global settings, _HS_File, _File, _Strings, _Search, _Match, _Changed, _Title, multi

Loop, %0%
	plist .= (plist ? " " : "") %A_Index%
Params := Args(plist)
if (Params.update) {
	if (!CheckUpdate())
		m("No update found.", "ico:i")
	ExitApp
}

Setup()
TrayMenu()
CheckUpdate()

;{===== Main GUI ====>>>

;{```` GUI OPTIONS ````}
color:=settings.ea("//Style/Color"), font:=settings.ea("//Style/Font"), hsOpts:=settings.sn("//HSOptions/Option"), gui:=settings.ssn("//Guis/Gui[@ID='1']"), guiOpts:=sn(gui, "//Options/Option")

while opt:=hsOpts.Item(A_Index-1)
	hsOptions .= "|" opt.text
while opt:=guiOpts.Item(A_Index-1)
	guiOptions .= " +" opt.text
Gui, Font, % "s" font.Size " c" font.Color, % font.Font
Gui, Color, % color.Background, % color.Control
Gui, Margin, % ssn(gui, "//Margin/@x").text, % ssn(gui, "//Margin/@y").text
Gui, % Trim(guiOptions)
;}

;{```` TRIGGER ````}
Gui, Font, wBold
Gui, Add, GroupBox, w850 h229 hwndGB_EditHS section, Edit Hotstring:
Gui, Font, wDefault
Gui, Add, GroupBox, xm+10 yp+22 w270 h55 hwndGB_Trigger Section, Trigger:
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
Gui, Font,, % font.Font
;}

;{```` ACTION BUTTONS ````}
Gui, Add, Button, xs+10 y+6 w85 h28 vBT_Add, &Add
Gui, Add, Button, x+5 yp w85 h28 +Disabled vBT_Repl, &Replace
Gui, Add, Button, x+5 yp w85 h28 vBT_Clear, &Clear
Gui, Add, Button, x+5 yp w85 h28 +default vBT_Find Disabled, &Find
;}

;{```` EXISTING HOTSTRINGS ````}
Gui, Font, wBold
Gui, Add, Groupbox, x10 y+20 h400 w850 hwndGB_Hotstrings Section, Hotstrings:
Gui, Font, wDefault
Gui, Add, Button, xs+10 ys+30 w85 h30, &Edit
Gui, Add, Button, x+5 yp w85 h30, &Delete
Gui, Add, Button, x+540 yp-1 w110 h30 hwndBtn_EditAHK +Center, E&dit AHK File
Gui, Font, % "s" font.Size - 1
Gui, Add, ListView, xs+10 y+5 w825 h330 vLV_1 gMainList hwndHSListID cBlack Sort ReadOnly Grid NoSortHdr, Trigger|Options|Replacement Text
Gui, Font, % "s" font.Size
;}

;{```` SAVE/CLOSE BUTTONS ````}
Gui, Add, Button, xm+320 y+15 w85 h30 +disabled vsaveButton hwndSaveButton, &Save
Gui, Add, Button, x+10 yp w85 h30 vcloseButton hwndCloseButton, &Close
;}

;{```` VERSION ````}
Gui, Font, s10 italic
Gui, Add, Text, xm+5 yp+15 hwndVersionTxt, version ;auto_version
;}

;{```` FILL LIST VIEW ````}
GoSub, Read_File
LV_ModifyCol(2,70)
;}

;{```` SHOW GUI ````}
Gui, Show,, % settings.ea(gui).Name
if (settings.ea("//Options").RememberPosition) {
	pos := settings.ea(ssn(gui, "//Position"))
	WinMove, % settings.ea(gui).Name,, % pos.x, % pos.y, % pos.w, % pos.h
}
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

ButtonReplace:
{
	Gui, Submit, NoHide
	_Row := LV_GetNext()
	if !(RegExMatch(ED_1, "[^\s]+") && RegExMatch(ED_3, "[^\s]+"))
		return
	ED_1:=To_Trigger(ED_1), ED_3:=!multi ? To_Raw(ED_3) : ED_3
	LV_Modify(_Row, "", ED_1, ED_2, ED_3)
	StringReplace, _File, _File, `n%_HS%`n, `n:%ED_2%:%ED_1%::%ED_3%`n
	_Changed := True
	GuiControl, -Disabled, saveButton
	ButtonClear()
	return
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
	if (RegExMatch(ED_3, "i)\s*?;\s*?<+?\s*?Multi-Line.*?>+")) {
		delText := SubStr(_File, InStr(_File, _HS) + StrLen(_HS))
		loop, Parse, delText, `n
		{
			_HS .= A_LoopField "`n"
			if (RegExMatch(A_LoopField, "i)^\s*?return.*?")) {
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


#Include AddOption.ahk
#Include Anchor.ahk
#Include Args.ahk
#Include ButtonAdd.ahk
#Include ButtonClear.ahk
#Include ButtonEdit.ahk
#Include ButtonEditAHKFile.ahk
#Include ButtonFind.ahk
#Include ChangedSomething.ahk
#Include CheckUpdate.ahk
#Include ControlActive.ahk
#Include CreateNewHSTxt.ahk
#Include DeletePrevious.ahk
#Include Edit 1.ahk
#Include Find Next.ahk
#Include From Raw.ahk
#Include From Trigger.ahk
#Include GuiClose.ahk
#Include m.ahk
#Include MainList.ahk
#Include MenuAction.ahk
#Include Setup.ahk
#Include StatusChange.ahk
#Include To Raw.ahk
#Include To Trigger.ahk
#Include TrayMenu.ahk
#Include class Xml.ahk
#Include ssn.ahk
#Include sn.ahk
#Include GuiContextMenu.ahk