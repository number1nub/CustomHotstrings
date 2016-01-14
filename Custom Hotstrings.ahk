#NoEnv
#SingleInstance, Force
DetectHiddenWindows, on
SetTitleMatchMode, 2
SetWorkingDir, %A_ScriptDir%

global settings, _HS_File, _File, _Strings, _Search, _Match, _Changed, _Title, multi, version

CmdLine(%true%)
Setup()
TrayMenu()
CheckUpdate()
Gui()
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


#Include <AddOption>
#Include <Anchor>
#Include <Args>
#Include <ButtonAdd>
#Include <ButtonClear>
#Include <ButtonDelete>
#Include <ButtonEdit>
#Include <ButtonEditAHKFile>
#Include <ButtonFind>
#Include <ButtonReplace>
#Include <ButtonSave>
#Include <ChangedSomething>
#Include <CheckAutoHotkey>
#Include <CheckUpdate>
#Include <class Xml>
#Include <CMBox>
#Include <CmdLine>
#Include <ControlActive>
#Include <CreateNewHSTxt>
#Include <DeletePrevious>
#Include <FileMenu>
#Include <Find Next>
#Include <From Raw>
#Include <From Trigger>
#Include <Gui>
#Include <GuiClose>
#Include <GuiContextMenu>
#Include <GuiSize>
#Include <m>
#Include <MainList>
#Include <MenuAction>
#Include <Read File>
#Include <Setup>
#Include <sn>
#Include <ssn>
#Include <StatusChange>
#Include <To Raw>
#Include <To Trigger>
#Include <TrayMenu>
#Include <TriggerChange>