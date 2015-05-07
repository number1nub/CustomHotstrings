GuiContextMenu() {
	if (A_GuiControl != "LV_1")
		return
	Menu, rClick, Add, Edit, buttonEdit
	Menu, rClick, Add, Delete, buttonDelete
	Menu, rClick, Show
	Menu, rClick, DeleteAll
}