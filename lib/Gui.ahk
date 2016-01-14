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