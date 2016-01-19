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


AddOption() {
	AddOption:
	Gui, Submit, NoHide
	GuiControlGet, exOpts,, ED_2
	GuiControl,, ED_2, % exOpts StrSplit(%A_GuiControl%,":")[1]
	GuiControl, Choose, addOption, 1
	GuiControl, Focus, ED_2
	ControlSend, Edit2, {Blind}^{End}
	return
}
Anchor(i, a:="", r:=false) {
	static c,cs:=12,cx:=255,cl:=0,g,gs:=8,gl:=0,gpi,gw,gh,z:=0,k:=0xffff,ptr
	if z = 0
		VarSetCapacity(g,gs*99,0),VarSetCapacity(c,cs*cx,0),ptr:=A_PtrSize?"Ptr":"UInt",z:=true
	if !WinExist("ahk_id" . i) {
		GuiControlGet t, Hwnd, %i%
		if ErrorLevel = 0
			i := t
		else ControlGet i, Hwnd,, %i%
	}
	VarSetCapacity(gi, 68, 0), DllCall("GetWindowInfo", "UInt", gp := DllCall("GetParent", "UInt", i), ptr, &gi)
		, giw := NumGet(gi, 28, "Int") - NumGet(gi, 20, "Int"), gih := NumGet(gi, 32, "Int") - NumGet(gi, 24, "Int")
	if (gp != gpi) {
		gpi := gp
		loop %gl%
			if NumGet(g, cb := gs*(A_Index - 1), "UInt") == gp {
				gw := NumGet(g, cb+4, "Short"), gh := NumGet(g, cb+6, "Short"), gf := 1
				break
			}
		if !gf
			NumPut(gp, g, gl, "UInt"), NumPut(gw := giw, g, gl+4, "Short"), NumPut(gh := gih, g, gl+6, "Short"), gl += gs
	}
	ControlGetPos dx, dy, dw, dh,, ahk_id %i%
	loop %cl%
		if NumGet(c, cb := cs*(A_Index - 1), "UInt") == i {
			if (a = "") {
				cf := 1
				break
			}
			giw-=gw, gih-=gh, as:=1, dx:=NumGet(c, cb+4, "Short"), dy:=NumGet(c, cb+6, "Short"), cw:=dw, dw:=NumGet(c, cb+8, "Short"), ch:=dh, dh:=NumGet(c, cb+10, "Short")
			loop Parse, a, xywh
				if A_Index > 1
					av:=SubStr(a,as,1), as+=1+StrLen(A_LoopField), d%av%+=(InStr("yh",av)?gih:giw)*(A_LoopField+0?A_LoopField:1)
			DllCall("SetWindowPos", "UInt", i, "UInt", 0, "Int", dx, "Int", dy, "Int", InStr(a, "w") ? dw : cw, "Int", InStr(a, "h") ? dh : ch, "Int", 4)
			if r != 0
				DllCall("RedrawWindow", "UInt", i, "UInt", 0, "UInt", 0, "UInt", 0x0101)
			return
		}
	if cf != 1
		cb := cl, cl += cs
	bx := NumGet(gi, 48, "UInt"), by := NumGet(gi, 16, "Int") - NumGet(gi, 8, "Int") - gih - NumGet(gi, 52, "UInt")
	if cf = 1
		dw -= giw - gw, dh -= gih - gh
	NumPut(i, c, cb, "UInt"), NumPut(dx - bx, c, cb+4, "Short"), NumPut(dy - by, c, cb+6, "Short")
		, NumPut(dw, c, cb+8, "Short"), NumPut(dh, c, cb+10, "Short")
	return true
}
Args(paramList) {
	count:=0, options:={}	
	paramList := RegExReplace(paramList, "(?:([^\s])-|(\s+)-(\s+))", "$1$2<dash>$3")
	paramList := RegExReplace(paramList, "(?:([^\s])/|(\s+)/(\s+))", "$1$2<slash>$3")
	regex = (?<=[-|/])([a-zA-Z0-9]*)[ |:|=|"|']*([\w|.|@|?|#|$|`%|=|*|,|<|>|^|{|}|\[|\]|;|(|)|_|&|+| |:|!|~|\\]*)["| |']*(.*)	
	while (paramList) {
		count++
		RegExMatch(paramList, regex, data)
		value:=RegExReplace(RegExReplace(data2 , "<dash>", "-"), "<slash>", "/")
		options[data1] := value ? value : 1
		paramList := data3
	}
	ErrorLevel:=count
	return options
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
	if (RegExMatch(ED_3, "i)\s*?;\s*?<+?\s*?Multi-Line.*?>+")) {
		delText := SubStr(_File, InStr(_File, _HS) + StrLen(_HS))
		loop, Parse, delText, `n, `r
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
ButtonEdit:
{
	_Row := LV_GetNext()
	if (!_Row)
		return
	Loop, % LV_GetCount("Col")
		LV_GetText(ED_%A_Index%, _Row, A_Index)
	
	_HS := ":" ED_2 ":" ED_1 "::" ED_3
	
	if (multi:=RegExMatch(ED_3, "i)\s*?;\s*?<+?\s*?Multi-Line.*?>+")) {
		edText:=SubStr(_File, InStr(_File, _HS) + StrLen(_HS)), topLine:=_HS
		loop, Parse, edText, `n
		{
			_HS.=A_LoopField "`n"
			if (RegExMatch(A_LoopField, "i)^\s*?return.*?")) {
				_HS := RegExReplace(_HS, "i)\n$")
				break
			}
		}
		ED_3 := StrReplace(_HS, topLine "`n")
	}
	
	ED_1 := From_Trigger(ED_1)
	ED_3 := !multi ? From_Raw(ED_3) : ED_3
	
	GuiControl, Disable, BT_Add
	GuiControl, Enable, BT_Repl
	GuiControl, Disable, BT_Find	
	GuiControl,, ED_1, % ED_1
	GuiControl,, ED_2, % ED_2
	GuiControl,, ED_3, % ED_3
	_Changed := False
	return
}
ButtonEditAHKFile() {
	Run, *edit "%_HS_File%"
	ExitApp
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
ChangedSomething() {
	GuiControlGet, ED_3
	GuiControl, % "Enable" (ED_3?1:0), BT_Find
}
CheckAutoHotkey() {
	RegRead, ahkPath, HKLM, Software\AutoHotkey, InstallDir
	if (ErrorLevel || !FileExist(ahkPath)) {
		prompt := "You don't appear to have AutoHotkey installed on your computer!`n`nAutoHotkey is required for this application to run & manage dynamic hotstrings.`n`nWhat would you like to do?"
		btns := ["Launch Portable Mode", "Download && Install AutoHotkey", "Cancel"]
		URLDownloadToFile, http://ahkscript.org/download/ahk-u32.zip, % (zip:=A_Temp "\ahk.zip")
		if (ErrorLevel || !FileExist(zip)) {
			m("Failed to download AutoHotkey portable executable...", "!")
			ExitApp
		}
	}
}
CheckUpdate(_ReplaceCurrentScript:=1, _SuppressMsgBox:=0, _CallbackFunction:="", ByRef _Information:="") {
	Static Update_URL   := "http://files.wsnhapps.com/hotstrings/Custom%20Hotstrings.text"
		 , Download_URL := "http://files.wsnhapps.com/hotstrings/Custom%20Hotstrings.exe" 
		 , Retry_Count  := 2
		 , Script_Name
	
	version:="1.9.2.3"
	if (!Version)
		return
	if (!Script_Name) {
		SplitPath, A_ScriptFullPath,,,, scrName
		Script_Name := scrName
	}
	Random, Filler, 10000000, 99999999	
	Version_File := A_Temp "\" Filler ".ini", Temp_FileName:=A_Temp "\" Filler ".tmp", VBS_FileName:=A_Temp "\" Filler ".vbs"
	Loop, %Retry_Count% {
		_Information := ""
		UrlDownloadToFile,%Update_URL%,%Version_File%
		Loop, Read, %Version_File%
		{
			UDVersion := A_LoopReadLine ? A_LoopReadLine : "N/A"
			break
		}
		if (UDVersion = "N/A") {
			FileDelete,%Version_File%
			if (A_Index = Retry_Count)
				_Information .= "The version info file doesn't have a ""Version"" key in the ""Info"" section or the file can't be downloaded."
			else
				Sleep, 500
			Continue
		}
		if (UDVersion > Version) {
			if (_SuppressMsgBox != 1 && _SuppressMsgBox != 3)
				if (m("There is a new version of " Script_Name " available.", "Current version: " Version, "New version: " UDVersion," ", "Would you like to download it now?", "title:New version available", "btn:yn", "ico:i") = "Yes")
					MsgBox_Result := 1
			if (_SuppressMsgBox || MsgBox_Result) {
				URL := Download_URL
				SplitPath, URL,,, Extension					
				if (Extension = "ahk" && A_AHKPath = "")
					_Information .= "The new version of the script is an .ahk filetype and you do not have AutoHotKey installed on this computer.`r`nReplacing the current script is not supported."
				else if (Extension != "exe" && Extension != "ahk")
					_Information .= "The new file to download is not an .EXE or an .AHK file type. Replacing the current script is not supported."
				else {
					IniRead,MD5,%Version_File%,Info,MD5,N/A
					Loop, %Retry_Count% {
						UrlDownloadToFile,%URL%,%Temp_FileName%
						if (FileExist(Temp_FileName)) {
							if (MD5 = "N/A") {
								_Information.="The version info file doesn't have a valid MD5 key.", Success:= True
								Break
							}
							else {
								Ptr:=A_PtrSize?"Ptr":"UInt", H:=DllCall("CreateFile",Ptr,&Temp_FileName,"UInt",0x80000000,"UInt",3,"UInt",0,"UInt",3,"UInt",0,"UInt",0), DllCall("GetFileSizeEx",Ptr,H,"Int64*",FileSize), FileSize:=FileSize = -1 ? 0 : FileSize
								if (FileSize != 0) {
									VarSetCapacity(Data,FileSize,0), DllCall("ReadFile",Ptr,H,Ptr,&Data,"UInt",FileSize,"UInt",0,"UInt",0), DllCall("CloseHandle",Ptr,H), VarSetCapacity(MD5_CTX,104,0), DllCall("advapi32\MD5Init",Ptr,&MD5_CTX), DllCall("advapi32\MD5Update",Ptr,&MD5_CTX,Ptr,&Data,"UInt",FileSize), DllCall("advapi32\MD5Final",Ptr,&MD5_CTX), FileMD5:=""
									Loop, % StrLen(Hex:="123456789ABCDEF0")
										N := NumGet(MD5_CTX,87+A_Index,"Char"), FileMD5 .= SubStr(Hex,N>>4,1) SubStr(Hex,N&15,1)
									VarSetCapacity(Data,FileSize,0), VarSetCapacity(Data,0)
									if (FileMD5 != MD5) {
										FileDelete,%Temp_FileName%
										if (A_Index = Retry_Count)
											_Information .= "The MD5 hash of the downloaded file does not match the MD5 hash in the version info file."
										else
											Sleep, 500
										Continue
									}
									else
										Success := True
								}
								else
									DllCall("CloseHandle",Ptr,H), Success := True									
							}
						}
						else {
							if (A_Index = Retry_Count)
								_Information .= "Unable to download the latest version of the file from " URL "."
							else
								Sleep, 500
							Continue
						}
					}
				}
			}
		}
		else
			_Information .= "No update was found."
		FileDelete, %Version_File%
		Break
	}	
	if (_ReplaceCurrentScript && Success) {
		SplitPath, URL,,, Extension
		Process, Exist
		MyPID := ErrorLevel
		VBS_P1 =
		(LTrim Join`r`n
			On Error Resume Next
			Set objShell = CreateObject("WScript.Shell")
			objShell.Run "TaskKill /F /PID %MyPID%", 0, 1
			Set objFSO = CreateObject("Scripting.FileSystemObject")
		)
		if (A_IsCompiled) {
			SplitPath, A_ScriptFullPath,, Dir,, Name
			VBS_P2 =
			(LTrim Join`r`n
				Finished = False
				Count = 0
				Do Until (Finished = True Or Count = 5)
					Err.Clear
					objFSO.CopyFile "%Temp_FileName%", "%Dir%\%Name%.%Extension%", True
					if (Err.Number = 0) then
						Finished = True
						objShell.Run """%Dir%\%Name%.%Extension%"""
					else
						WScript.Sleep(1000)
						Count = Count + 1
					End if
				Loop
				objFSO.DeleteFile "%Temp_FileName%", True
			)
			Return_Val := Temp_FileName
		}
		else {
			if (Extension = "ahk") {
				FileMove,%Temp_FileName%,%A_ScriptFullPath%,1
				if (Errorlevel)
					_Information .= "Error (" Errorlevel ") unable to replace current script with the latest version."
				else {
					VBS_P2 =
					(LTrim Join`r`n
						objShell.Run """%A_ScriptFullPath%"""
					)
					Return_Val :=  A_ScriptFullPath
				}
			}
			else if (Extension = "exe") {
				SplitPath, A_ScriptFullPath,, FDirectory,, FName
				FileMove, %Temp_FileName%, %FDirectory%\%FName%.exe, 1
				FileDelete, %A_ScriptFullPath%
				VBS_P2 =
				(LTrim Join`r`n
					objShell.Run """%FDirectory%\%FName%.exe"""
				)
				Return_Val :=  FDirectory "\" FName ".exe"
			}
			else {
				FileDelete,%Temp_FileName%
				_Information .= "The downloaded file is not an .EXE or an .AHK file type. Replacing the current script is not supported."
			}
		}
		VBS_P3 =
		(LTrim Join`r`n
			objFSO.DeleteFile "%VBS_FileName%", True
		)
		if (_SuppressMsgBox < 2) {
			if (InStr(VBS_P2, "Do Until (Finished = True Or Count = 5)")) {
				VBS_P3.="`r`nif (Finished=False) Then", VBS_P3.="`r`nWScript.Echo ""Update failed.""", VBS_P3.="`r`nelse"
				if (Extension != "exe")
					VBS_P3 .= "`r`nobjFSO.DeleteFile """ A_ScriptFullPath """"
				VBS_P3.="`r`nWScript.Echo ""Update completed successfully.""", VBS_P3.="`r`nEnd if"
			}
			else
				VBS_P3 .= "`r`nWScript.Echo ""Update complected successfully."""
		}
		FileDelete, %VBS_FileName%
		FileAppend, %VBS_P1%`r`n%VBS_P2%`r`n%VBS_P3%, %VBS_FileName%
		if (_CallbackFunction != "") {
			if (IsFunc(_CallbackFunction))
				%_CallbackFunction%()
			else
				_Information .= "The callback function is not a valid function name."
		}
		RunWait, %VBS_FileName%, %A_Temp%, VBS_PID
		Sleep, 2000
		Process, Close, %VBS_PID%
		_Information := "Error (?) unable to replace current script with the latest version.`r`nPlease make sure your computer supports running .vbs scripts and that the script isn't running in a pipe."
	}
	_Information := _Information ? _Information : "None"
	Return Return_Val
}
class Xml
{
	__New(param*) {
		root:=param.1, file:=param.2?param.2:root ".xml"
		temp:=ComObjCreate("MSXML2.DOMDocument"), temp.setProperty("SelectionLanguage","XPath")
		this.xml:=temp, this.fileExists:=false
		if (FileExist(file)) {
			FileRead, info, %file%
			if (!info) {
				this.xml := this.create(temp, root)
				FileDelete, %file%
			}
			else
				this.fileExists:=true, temp.loadxml(info), this.xml:=temp
		}
		else
			this.xml := this.create(temp, root)
		this.file := file
	}
	
	__Get(x:="") {
		return this.xml.xml
	}
	
	Add(path, att:="", text:="", dup:=0, list:="") {
		p:="/",dup1:=this.ssn("//" path)?1:0,next:=this.ssn("//" path),last:=SubStr(path,InStr(path,"/",0,0)+1)
		if (!next.xml) {
			next := this.ssn("//*")
			Loop, Parse, path, /
				last:=A_LoopField, p.="/" last, next:=this.ssn(p)?this.ssn(p):next.appendchild(this.xml.createElement(last))
		}
		if (dup && dup1)
			next := next.parentnode.appendchild(this.xml.createElement(last))
		for a, b in att
			next.SetAttribute(a, b)
		for a, b in StrSplit(list, ",")
			next.SetAttribute(b, att[b])
		if (text)
			next.text := text
		return next
	}
	
	Create(doc, root) {
		return doc.AppendChild(this.xml.createElement(root)).parentnode
	}
	
	EA(path) {
		list:=[]
		if (nodes:=path.nodename)
			nodes := path.SelectNodes("@*")
		else if (path.text)
			nodes := this.sn("//*[text()='" path.text "']/@*")
		else if (!IsObject(path))
			nodes := this.sn(path "/@*")
		else
			for a, b in path
				nodes := this.sn("//*[@" a "='" b "']/@*")
		while, (n:=nodes.item(A_Index-1))
			list[n.nodename] := n.text
		return list
	}
	
	FF(info*) {
		doc := info.1.NodeName ? info.1 : this.xml
		if (info.1.NodeName)
			node:=info.2, find:=info.3
		else
			node:=info.1, find:=info.2
		if (InStr(find, "'"))
			return doc.selectSingleNode(node "[.=concat('" RegExReplace(find,"'","'," Chr(34) "'" Chr(34) ",'") "')]/..")
		else
			return doc.selectSingleNode(node "[.='" find "']/..")
	}
	
	Find(info) {
		if (info.att.1 && info.text) {
			MsgBox 4144,, You can only search by either the attribute or the text, not both
			return
		}
		search := info.path ? "//" info.path : "//*"
		for a, b in info.att
			search .= "[@" a "='" b "']"
		if (info.text)
			search .= "[text()='" info.text "']"
		return this.ssn(search)
	}
	
	Get(path, default:="") {
		return ((ptxt:=this.ssn(path).text) ? ptxt : default)
	}
	
	Lang(info) {
		info:=!info?"XPath":"XSLPattern", this.xml.temp.setProperty("SelectionLanguage", info)
	}
	
	Remove(rem) {
		if (!IsObject(rem))
			rem := this.ssn(rem)
		rem.parentNode.removeChild(rem)
	}
	
	Save(x*) {
		if (x.1=1)
			this.Transform()
		filename := this.file ? this.file : x.1.1
		SplitPath, filename,, fDir
		if (!FileExist(fDir))
			FileCreateDir, %fDir%
		file:=fileopen(filename, "rw", "Utf-8"), file.seek(0), file.write(this[]), file.length(file.position)
	}
	
	Search(node, find) {
		while, ff:=found.Item[A_Index-1]
			if (ff.text = find)
				return ff
	}
	
	SN(node) {
		return this.xml.SelectNodes(node)
	}
	
	SSN(node) {
		return this.xml.SelectSingleNode(node)
	}
	
	Transform() {
		static
		if (!IsObject(xsl)) {
			xsl := ComObjCreate("MSXML2.DOMDocument")
			style=
			(
			<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
			<xsl:output method="xml" indent="yes" encoding="UTF-8"/>
			<xsl:template match="@*|node()">
				<xsl:copy>
					<xsl:apply-templates select="@*|node()"/>
					<xsl:for-each select="@*">
						<xsl:text>
						</xsl:text>
					</xsl:for-each>
				</xsl:copy>
			</xsl:template>
			</xsl:stylesheet>
			)
			xsl.loadXML(style), style:=null
		}
		this.xml.transformNodeToObject(xsl, this.xml)
	}
	
	Under(under, node:="", att:="", text:="", list:="") {
		if (!node) {
			node:=under.node, att:=under.att, list:=under.list, under:=under.under
		}
		new := under.appendchild(this.xml.createElement(node))
		for a, b in att
			new.SetAttribute(a, b)
		for a, b in StrSplit(list, ",")
			new.SetAttribute(b, att[b])
		if (text)
			new.text := text
		return new
	}
	
	Unique(info) {
		if (info.check && info.text)
			return
		if (info.under) {
			if (info.check)
				find := info.under.selectSingleNode("*[@" info.check "='" info.att[info.check] "']")
			if (info.Text)
				find := this.ssn(info.under,"*[text()='" info.text "']")
			if (!find)
				find := this.under(info.under,info.path,info.att)
			for a, b in info.att
				find.SetAttribute(a, b)
		}
		else {
			if (info.check)
				find := this.ssn("//" info.path "[@" info.check "='" info.att[info.check] "']")
			else if (info.text)
				find := this.ssn("//" info.path "[text()='" info.text "']")
			if (!find)
				find := this.add({path:info.path,att:info.att,dup:1})
			for a, b in info.att
				find.SetAttribute(a,b)
		}
		if (info.text)
			find.text := info.text
		return find
	}
}
CMBox(msg, btns, opts:="") {
	iconVal:={"x":16,"?":32,"!":48,"i":64}, btnVal:={2:4, 3:2}, defVal:=[256, 512], btns:=IsObject(btns)?btns:StrSplit(btns, "|")
	opt := 262144+iconVal[opts.ico]+btnVal[btns.MaxIndex()]+(opts.def>1&&opts.def<4 ? defVal[opts.def-1] : 0)
	SetTimer, ChangeButtons, 5
	MsgBox, % opt, % mTitle:=opts.title?opts.title:A_ScriptName, % msg
	IfMsgBox, Yes
		return btns[1]
	else IfMsgBox, OK
		return btns[1]
	else IfMsgBox, Abort
		return btns[1]
	else IfMsgBox, No
		return btns[2]
	else IfMsgBox, Retry
		return btns[2]
	else IfMsgBox, Ignore
		return btns[3]
	
	ChangeButtons:
	IfWinNotExist, %mTitle%
		return
	SetTimer, ChangeButtons, off
	bGap:=3, wGap:=10, charW:=8, nx:=[]
	WinGetPos,,, ww
	ControlGetPos,,, cw1,, Button1
	ControlGetPos,,, cw2,, Button2
	ControlGetPos,,, cw3,, Button3
	req:=[StrLen(btns[1])*charW, StrLen(btns[2])*charW, StrLen(btns[3])*charW]
		, nw:=[cw1<req[1]?req[1]:cw1, cw2<req[2]?req[2]:cw2, cw3<req[3]?req[3]:cw3]
		, nww:=nw[1]+nw[2]+nw[3]+(5*wGap)+(bGap*btns.MaxIndex()-bGap)
	nx.Push((nww>ww?nww:ww-bGap)-3*(bGap*btns.MaxIndex()-bGap)-nw[1]-nw[2]-nw[3])
	nx.Push(nx[1]+nw[1]+bGap, nx[1]+nw[1]+bGap+nw[2]+bGap)
	WinMove,,,,, % nww>ww?nww:ww
	ControlMove, Button1, % nx[1],, % nw[1]
	ControlMove, Button2, % nx[2],, % nw[2]
	ControlMove, Button3, % nx[3],, % nw[3]
	ControlSetText, Button1, % btns[1]
	ControlSetText, Button2, % btns[2]
	ControlSetText, Button3, % btns[3]	
	return
}
CmdLine(info*) {
	Loop, %info%
		plist .= (plist ? " " : "") %A_Index%
	Params := Args(plist)
	if (Params.update) {
		if (!CheckUpdate())
			m("No update found.", "ico:i")
		ExitApp
	}
}
ControlActive(Control_Name, winTitle) {
	ControlGetFocus, Active_Control, %winTitle%
	if (Active_Control = Control_Name)
		return 1
}
CreateNewHSTxt() {
	static url:="https://raw.githubusercontent.com/number1nub/CustomHotstrings/master/Template.txt"
	
	try {
		SplitPath, _HS_File,, hsDir
		if (!FileExist(hsDir))
			FileCreateDir, % hsDir
		UrlDownloadToFile, %url%, %_HS_File%
		if (ErrorLevel) {
			FileDelete, %_HS_File%
			m("Unable to download the hotstrings base template file.","","Try again later...","!")
			ExitApp
		}
		FileRead, templateTxt, Template.txt
		FileAppend, %templateTxt%, % _HS_File
		RegWrite, REG_SZ, HKCU, Software\WSNHapps\CustomHotstrings, EditorPath, %A_ScriptFullPath%
		Run, % _HS_File
	}
	catch e {
		m("There was an issue while trying to create the new hotstrings file.", "Aborting...","ico:!")
		ExitApp
	}
}
DeletePrevious() {
	cbBU:=Clipboard, Clipboard:=""
	SendInput, {Blind}+{Home}
	SendInput, {Blind}^c
	ClipWait, 1
	if (ErrorLevel) {
		SendInput, {Blind}{Right}
		return
	}
	Clipboard := RegExMatch(Clipboard,"i)(.*?)(\<\w+\>)$",v) ? v1 : SubStr(Clipboard,1,-1)
	SendInput, {Blind}^v
}
FileMenu(gui:="") {
	;FILE MENU
	Menu, fMenu, Add, Open Custom Hotstrings &Folder, MenuAction
	Menu, fMenu, Icon, Open Custom Hotstrings &Folder, shell32.dll, 127
	Menu, fMenu, Add, Open &Settings File, MenuAction
	Menu, fMenu, Icon, Open &Settings File, shell32.dll, 70
	Menu, fMenu, Add
	Menu, fMenu, Add, E&xit, MenuAction
	Menu, fMenu, Icon, E&xit, shell32.dll, 132
	
	;OPTIONS MENU
	Menu, optsMenu, Add, Keep Window On &Top, MenuAction
	Menu, optsMenu, % settings.ssn("//Gui[1]/Options/Option[text()='AlwaysOnTop']").text ? "Check":"UnCheck", Keep Window on &Top
	Menu, optsMenu, Add, &Remember Window Position, MenuAction
	Menu, optsMenu, % settings.ea("//Options").RememberPosition ? "Check" : "UnCheck", &Remember Window Position
	Menu, optsMenu, Add
	Menu, optsMenu, Add, GUI &Color, MenuAction
	Menu, optsMenu, Icon,  GUI &Color, imageres.dll, 110
	
	;HELP MENU
	Menu, helpMenu, Add, &About, MenuAction
	Menu, helpMenu, Icon, &About, shell32.dll, 278
	
	;CREATE GUI MENU, BAR
	Menu, MenuBar, Add, &File, :fMenu
	Menu, MenuBar, Add, &Options, :optsMenu
	;~ Menu, MenuBar, Add, &Help, :helpMenu
	
	if (gui)
		Gui, %gui%:Default
	Gui, Menu, MenuBar
}
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
From_Raw(String) {
	StringReplace, String, String, ``r, `r`n, All
	StringReplace, String, String, ``t, %A_Tab%, All
	StringReplace, String, String, ```;, `;, All
	StringReplace, String, String, ```:, `:, All
	StringReplace, String, String, ````, ``, All
	return String
}
From_Trigger(String) {
	StringReplace, String, String,``n, <ENTER>, All
	StringReplace, String, String, %A_Space%, <SPACE>, All
	StringReplace, String, String, ``t, <TAB>, All
	StringReplace, String, String, %a_tab%, <TAB>, All
	return String
}
Gui() {
	global
	vColor  := settings.ea("//Style/Color")
	vFont   := settings.ea("//Style/Font")
	vHSOpts := settings.sn("//HSOptions/Option")
	vGui    := settings.ssn("//Guis/Gui[@ID='1']")
	guiOpts := sn(vGui, "//Options/Option")
	
	;{=== GUI OPTIONS ===>> 
	Gui, 1:Default
	Gui, Font, % "s" vFont.Size " c" vFont.Color, % vFont.Font
	Gui, Color, % vColor.Background, % vColor.Control
	Gui, Margin, % ssn(vGui, "//Margin/@x").text, % ssn(vGui, "//Margin/@y").text
	while opt:=guiOpts.Item(A_Index-1)
		guiOptions .= " +" opt.text
	Gui, % Trim(guiOptions)
	FileMenu()
	;}
	
	
	;{=== TRIGGER ===>>
	Gui, Font, bold
	Gui, Add, GroupBox, w850 h229 hwndGB_EditHS section, Edit Hotstring:
	Gui, Font, norm
	Gui, Add, GroupBox, xm+10 yp+22 w270 h55 hwndGB_Trigger Section, Trigger:
	Gui, Add, Edit, xs+10 ys+23 w250 h25 cBlack hwndTriggerID vED_1 gTriggerChange
	;}
	
	
	;{=== OPTIONS ===>>
	Gui, Add, GroupBox, xs+280 ys w545 h55 hwndGB_Options Section, Options
	Gui, Add, Edit, xs+10 ys+23 w120 h25 cBlack hwndOptionsID vED_2 gChangedSomething,
	while opt:=vHSOpts.Item(A_Index-1)
		hsOptions .= "|" opt.text
	Gui, Add, DropDownList, x+5 yp-2 r8 w400 -TabStop cBlack hwndOptionsListID vaddOption gaddOption, %hsOptions%
	Gui, Add, Text, xp+25 yp+4 +BackgroundTrans cADADAD hwndHelpTxtID, < Select from available options > 
	;}
	
	
	;{=== REPLACEMENT TXT ===>>
	Gui, Add, GroupBox, xm+10 ys+60 w825 h140 hwndGB_Replacement Section, Replacement Text: (Press Find to search)
	Gui, Font,, Consolas
	Gui, Add, Edit, xs+10 ys+22 w805 h75 cBlack vED_3 hwndReplacementID WantTab WantReturn gChangedSomething
	Gui, Font,, % vFont.Font
	;}
	
	
	;{=== ACTION BUTTONS ===>>
	Gui, Add, Button, xs+10 y+6 w85 h28 vBT_Add, &Add
	Gui, Add, Button, x+5 yp w85 h28 +Disabled vBT_Repl, &Replace
	Gui, Add, Button, x+5 yp w85 h28 vBT_Clear, &Clear
	Gui, Add, Button, x+5 yp w85 h28 +default vBT_Find Disabled, &Find
	;}
	
	
	;{=== EXISTING HOTSTRINGS ===>>
	Gui, Font, bold
	Gui, Add, Groupbox, x10 y+20 h400 w850 hwndGB_Hotstrings Section, Hotstrings:
	Gui, Font, norm
	Gui, Add, Button, xs+10 ys+30 w85 h30  vBtnEdit, &Edit
	Gui, Add, Button, x+5 yp w85 h30 vbtnDelete, &Delete
	Gui, Add, Button, x+540 yp-1 w110 h30 hwndBtn_EditAHK +Center, E&dit AHK File
	Gui, Font, % "s" vFont.Size - 1
	Gui, Add, ListView, xs+10 y+5 w825 h330 vLV_1 gMainList hwndHSListID cBlack Sort ReadOnly Grid NoSortHdr, Trigger|Options|Replacement Text
	Gui, Font, % "s" vFont.Size
	;}
	
	
	;{=== SAVE/CLOSE BUTTONS ===>>
	Gui, Add, Button, xm+320 y+15 w85 h30 +disabled vsaveButton hwndSaveButton, &Save
	Gui, Add, Button, x+10 yp w85 h30 vcloseButton hwndCloseButton, &Close
	;}
	
	
	;{=== VERSION ===>>
	Gui, Font, s10 italic
	Gui, Add, Text, xm+5 yp+15 hwndVersionTxt, % version ? "v" version : "DUBUGGING..."
	;}
	
	
	;{=== FILL LIST VIEW ===>>
	GoSub, Read_File
	LV_ModifyCol(2,70)
	;}
	
	
	;{=== SHOW GUI ===>>
	Gui, Show,, % settings.ea(vGui).Name
	if (settings.ea("//Options").RememberPosition) {
		pos := settings.ea(ssn(vGui, "//Position"))
		WinMove, % settings.ea(vGui).Name,, % pos.x, % pos.y, % pos.w, % pos.h
	}
	;}
}
GuiClose() {
	GuiEscape:
	ButtonQuit:
	ButtonClose:
	Shutdown()
}
GuiContextMenu() {
	if (A_GuiControl != "LV_1")
		return
	Menu, rClick, Add, Edit, buttonEdit
	Menu, rClick, Add, Delete, buttonDelete
	Menu, rClick, Show
	Menu, rClick, DeleteAll
}
GuiSize() {
	global
	Anchor(GB_EditHS, "wh", 1)
	Anchor(GB_Trigger, "w", 1)
	Anchor(TriggerID, "w")
	Anchor(GB_Options, "x", 1)
	Anchor(OptionsID, "x")	
	Anchor(OptionsListID, "x", 1)
	Anchor(HelpTxtID, "x")
	Anchor(GB_Replacement, "wh", 1)
	Anchor(ReplacementID, "wh")
	Anchor("BT_Add", "y", 1)
	Anchor("BT_Clear", "y", 1)
	Anchor("BT_Repl", "y", 1)
	Anchor("BT_Find", "y", 1)
	Anchor("BtnEdit", "y", 1)
	Anchor("BtnDelete", "y", 1)
	Anchor(Btn_EditAHK, "xy", 1)
	Anchor(GB_Hotstrings, "wy", 1)
	Anchor(HSListID, "wy", 1)
	Anchor(VersionTxt, "y")
	Anchor(saveButton, "yx.5", 1)
	Anchor(CloseButton, "yx.5", 1)
	return
}
m(info*) {
	static icons:={"x":16,"?":32,"!":48,"i":64}, btns:={c:1,oc:1,co:1,ari:2,iar:2,ria:2,rai:2,ync:3,nyc:3,cyn:3,cny:3,yn:4,ny:4,rc:5,cr:5}
	for c, v in info {
		if RegExMatch(v, "imS)^(?:btn:(?P<btn>c|\w{2,3})|(?:ico:)?(?P<ico>x|\?|\!|i)|title:(?P<title>.+)|def:(?P<def>\d+)|time:(?P<time>\d+(?:\.\d{1,2})?|\.\d{1,2}))$", m_) {
			mBtns:=m_btn?1:mBtns, title:=m_title?m_title:title, timeout:=m_time?m_time:timeout
			opt += m_btn?btns[m_btn]:m_ico?icons[m_ico]:m_def?(m_def-1)*256:0
		} else
			txt .= (txt ? "`n":"") v
	}
	MsgBox, % (opt+262144), %title%, %txt%, %timeout%
	for c, v in ["OK", "YES", "NO", "CANCEL", "RETRY", "ABORT"]
		IfMsgBox, %v%
			return (mBtns ? v : "")
}
MainList:
{
	if (A_GuiEvent = "DoubleClick")
		goto, ButtonEdit
	return
}
MenuAction() {
	mi := StrReplace(A_ThisMenuItem, "&")
	
	if (mi = "Run hsTxt.ahk") {
		SendMessage, 0x111, 65303,,, hsTxt.ahk - AutoHotkey
		if (ErrorLevel)
			run, %_HS_File%
	}
	else if (mi = "Open Custom Hotstrings Folder") {
		Run, *explore "%A_ScriptDir%"
		ExitApp
	}
	else if (mi = "Remember Window Position") {
		Menu, Tray, ToggleCheck, %A_ThisMenuItem%
		Menu, optsMenu, ToggleCheck, %A_ThisMenuItem%
		cur := settings.ea("//Options").RememberPosition
		settings.ssn("//Options/@RememberPosition").text := cur ? 0 : 1
		settings.save(1)
	}
	else if (mi = "Open Settings File") {
		run, % "*edit " settings.file
		ExitApp
	}
	else if (mi = "GUI Color") {
		gui, +OwnDialogs
		InputBox, clr, Change GUI Color, Enter GUI Background Color:,,,,,,,, % (curColor:=settings.ssn("//Style/Color/@Background")).text
		if (ErrorLevel || clr="" || clr=curColor.text)
			return
		curColor.text := clr
		Shutdown(1)
	}
	else if ("Keep Window on Top") {
		optsPath := "//Gui[@ID='1']/Options"
		if (aot:=settings.ssn(optsPath "/Option[text()='AlwaysOnTop']")) {
			Gui, 1:-AlwaysOnTop
			settings.Remove(aot)
		}
		else {
			settings.under(settings.ssn(optsPath), "Option",, "AlwaysOnTop")
			Gui, 1:+AlwaysOnTop
		}
		Menu, optsMenu, ToggleCheck, %A_ThisMenuItem%
		Menu, Tray, ToggleCheck, %A_ThisMenuItem%
		settings.Save(1)
	}
	else
		m("Not yet implemented", "ico:i")
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
Setup(dir:="") {	
	_HSDir   := dir ? dir : A_AppData "\WSNHapps\Custom Hotstrings"
	_HS_File := _HSDir "\hsTxt.ahk"
	regPath  := "Software\WSNHapps\CustomHotstrings"
	_Strings := "`n"
	_Title   := "Custom Hotstring Manager"
	settings := new Xml("settings", _HSDir "\settings.xml")
	
	if (!settings.fileExists) {
		settings.add2("Options", {RememberPosition:0},"")
		style := settings.add2("Style")
		settings.under(style, "Color", {Background:"8A4444", Control:"White"})
		settings.under(style, "Font", {Font:"Segoe UI", Color:"White", Size:11})
		guis := settings.add2("Guis")
		gui := settings.under(guis, "Gui", {ID:1, Name:"Custom Hotstring Manager"})
		settings.under(gui, "Margin",{x:10, y:5})
		settings.under(gui, "Position", {x:"Center", y:"Center"}, "xCenter yCenter")
		guiOpts := settings.under(gui, "Options")
		settings.under(guiOpts, "Option",, "Resize")
		settings.under(guiOpts, "Option",, "ToolWindow")
		settings.under(guiOpts, "Option",, "MinSize690x510")
		hsopts := settings.add2("HSOptions")
		settings.under(hsopts, "Option",, "?0: Don't trigger within words")
		settings.under(hsopts, "Option",, "B0: Don't erase trigger")
		settings.under(hsopts, "Option",, "C: Trigger is case-sensitive")
		settings.under(hsopts, "Option",, "C0: Match case of trigger in replacement")
		settings.under(hsopts, "Option",, "*0: Require space, period or enter to trigger")
		settings.under(hsopts, "Option",, "R0: Send expressions (raw off)")
		settings.save(1)
	}
	
	;Catch Major Config File Changes Here
	if (tmp:=settings.ssn("//Gui/Options/Option[text()='ToolWindow']"))
		tmp.parentNode.removeChild(tmp)
		
	RegRead, edPath, HKCU, %regPath%, EditorPath
	if (ErrorLevel || (A_IsCompiled && edPath != A_ScriptFullPath))
		RegWrite, REG_SZ, HKCU, %regPath%, EditorPath, %A_ScriptFullPath%
	
	if (!FileExist(_HS_File))
		CreateNewHSTxt()
}
sn(node, path) {
	return node.selectNodes(path)
}
ssn(node, path) {
	return node.selectSingleNode(path)
}
StatusChange(status := "") {	
	global _Changed := status ? !_Changed : status
	GuiControl, % (_Changed ? "+" : "-") "Disabled", ButtonSave
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
To_Trigger(String) {
	StringReplace, String, String, <ENTER>, ``n, All
	StringReplace, String, String, <TAB>, ``t, All
	StringReplace, String, String, <SPACE>, %A_Space%, All
	return String
}
TrayMenu() {
	Menu, DefaultAHK, Standard
	Menu, Tray, NoStandard
	
	Menu, Tray, Add, Keep Window On &Top, MenuAction
	Menu, Tray, % settings.ssn("//Gui[1]/Options/Option[text()='AlwaysOnTop']").text ? "Check":"UnCheck", Keep Window on &Top
	Menu, Tray, Add, &Remember Window Position, MenuAction
	Menu, Tray, % settings.ea("//Options").RememberPosition ? "Check":"UnCheck", &Remember Window Position
	Menu, Tray, Add, Open Custom Hotstrings Folder, MenuAction
	Menu, Tray, Add, Open Settings File, MenuAction
	if (!A_IsCompiled) {
		Menu, Tray, Add
		Menu, Tray, Add, Default AHK Menu, :DefaultAHK
	}
	Menu, Tray, Add
	Menu, Tray, Add, Exit, MenuAction
	
	if (A_IsCompiled)
		Menu, Tray, Icon, %A_ScriptFullPath%, -159
	else
		Menu, Tray, Icon, % FileExist(mIco := (A_ScriptDir "\hotstrings.ico")) ? mIco : ""
}
TriggerChange() {
	GuiControlGet, ED_1
	if (!RegExMatch(ED_1, "[^\s]+"))
		return	
	if (InStr(_Strings, ED_1))
		ControlSend, SysListView321, {Blind}{Home}%ED_1%
	return
}
Shutdown(reload:="") {
	if (_Changed)
		if (m("You've changed your hotstrings!`n", "Save Changes??", "btn:yn", "ico:!") = "Yes")
			Gosub, ButtonSave
	pos := settings.ssn("//Guis/Gui[@ID='" A_Gui "']/Position")
	WinGetPos, wx, wy, ww, wh
	for c, v in {x:wx, y:wy, w:ww, h:wh}
		pos.setAttribute(c, v), posStr.=" " c v
	pos.text := Trim(posStr)
	settings.save(1)
	if (reload){
		Reload
		Pause
	}
	Exitapp
}