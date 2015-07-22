#NoEnv
#SingleInstance, Force
DetectHiddenWindows, on
SetTitleMatchMode, 2
SetWorkingDir, %A_ScriptDir%
info = %1%

global settings, _HS_File, _File, _Strings, _Search, _Match, _Changed, _Title, multi

CmdLineCheck(info)
Setup()
TrayMenu()
CheckUpdate()


;{=== GUI Options ===>>
	color   := settings.ea("//Style/Color"), font:=settings.ea("//Style/Font")
	hsOpts  := settings.sn("//HSOptions/Option"), gui:=settings.ssn("//Guis/Gui[@ID='1']")
	guiOpts := sn(gui, "//Options/Option")
	
	while opt:=hsOpts.Item(A_Index-1)
		hsOptions .= "|" opt.text
	while opt:=guiOpts.Item(A_Index-1)
		guiOptions .= " +" opt.text
	
	;#[TODO: Add a file menu]
	Gui, Font, % "s" font.Size " c" font.Color, % font.Font
	Gui, Color, % color.Background, % color.Control
	Gui, Margin, % ssn(gui, "//Margin/@x").text, % ssn(gui, "//Margin/@y").text
	Gui, % Trim(guiOptions)
;}


;{=== TRIGGER ===>>
	Gui, Font, wBold
	Gui, Add, GroupBox, w850 h229 hwndGB_EditHS section, Edit Hotstring:
	Gui, Font, wDefault
	Gui, Add, GroupBox, xm+10 yp+22 w270 h55 hwndGB_Trigger Section, Trigger:
	Gui, Add, Edit, xs+10 ys+23 w250 h25 cBlack hwndTriggerID vED_1 gEdit_1
;}


;{=== OPTIONS ===>>
	Gui, Add, GroupBox, xs+280 ys w545 h55 hwndGB_Options Section, Options
	Gui, Add, Edit, xs+10 ys+23 w120 h25 cBlack hwndOptionsID vED_2 gChangedSomething,
	Gui, Add, DropDownList, x+5 yp-2 r8 w400 -TabStop cBlack hwndOptionsListID vaddOption gaddOption, %hsOptions%
	Gui, Add, Text, xp+25 yp+4 +BackgroundTrans cADADAD hwndHelpTxtID, < Select from available options > 
;}


;{=== REPLACEMENT TXT ===>>
	Gui, Add, GroupBox, xm+10 ys+60 w825 h140 hwndGB_Replacement Section, Replacement Text: (Press Find to search)
	Gui, Font,, Consolas
	Gui, Add, Edit, xs+10 ys+22 w805 h75 cBlack vED_3 hwndReplacementID WantTab WantReturn gChangedSomething
	Gui, Font,, % font.Font
;}


;{=== ACTION BUTTONS ===>>
	Gui, Add, Button, xs+10 y+6 w85 h28 vBT_Add, &Add
	Gui, Add, Button, x+5 yp w85 h28 +Disabled vBT_Repl, &Replace
	Gui, Add, Button, x+5 yp w85 h28 vBT_Clear, &Clear
	Gui, Add, Button, x+5 yp w85 h28 +default vBT_Find Disabled, &Find
;}


;{=== EXISTING HOTSTRINGS ===>>
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


;{=== SAVE/CLOSE BUTTONS ===>>
	Gui, Add, Button, xm+320 y+15 w85 h30 +disabled vsaveButton hwndSaveButton, &Save
	Gui, Add, Button, x+10 yp w85 h30 vcloseButton hwndCloseButton, &Close
;}


;{=== VERSION ===>>
	Gui, Font, s10 italic
	Gui, Add, Text, xm+5 yp+15 hwndVersionTxt, % StrReplace("v;auto_version", "Version=")
;}


;{=== FILL LIST VIEW ===>>
	GoSub, Read_File
	LV_ModifyCol(2,70)
;}


;{=== SHOW GUI ===>>
	Gui, Show,, % settings.ea(gui).Name
	if (settings.ea("//Options").RememberPosition) {
		pos := settings.ea(ssn(gui, "//Position"))
		WinMove, % settings.ea(gui).Name,, % pos.x, % pos.y, % pos.w, % pos.h
	}
;}<<= SHOW GUI =====
return


;{=== HOTKEYS ===>>
	#if ControlActive("Edit1", _Title)
	space::SendInput, {Blind}<SPACE>
	Enter::SendInput, {Blind}<ENTER>
	tab::  SendInput, {Blind}<TAB>
	^tab:: SendInput, {Blind}`t
	bs::   DeletePrevious()
	
	#if ControlActive("SysListView321", _Title)
	Delete::goto, buttonDelete
	#if
;}<<= HOTKEYS =====



#Include lib\AddOption.ahk
#Include Lib\Anchor.ahk
#Include lib\Args.ahk
#Include lib\ButtonAdd.ahk
#Include lib\ButtonClear.ahk
#Include lib\ButtonDelete.ahk
#Include lib\ButtonEdit.ahk
#Include lib\ButtonEditAHKFile.ahk
#Include lib\ButtonFind.ahk
#Include lib\ButtonReplace.ahk
#Include lib\ButtonSave.ahk
#Include lib\ChangedSomething.ahk
#Include lib\CheckAutoHotkey.ahk
#Include lib\CheckUpdate.ahk
#Include lib\class Xml.ahk
#Include lib\CmdLineCheck.ahk
#Include lib\ControlActive.ahk
#Include lib\CreateNewHSTxt.ahk
#Include lib\DeletePrevious.ahk
#Include lib\Edit 1.ahk
#Include lib\Find Next.ahk
#Include lib\From Raw.ahk
#Include lib\From Trigger.ahk
#Include lib\GuiClose.ahk
#Include lib\GuiContextMenu.ahk
#Include lib\GuiSize.ahk
#Include lib\m.ahk
#Include lib\MainList.ahk
#Include lib\MenuAction.ahk
#Include lib\Read File.ahk
#Include lib\Setup.ahk
#Include lib\sn.ahk
#Include lib\ssn.ahk
#Include lib\StatusChange.ahk
#Include lib\To Raw.ahk
#Include lib\To Trigger.ahk
#Include lib\TrayMenu.ahk