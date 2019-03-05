function IntegrateQuickMenu()
	if QuickMenu then
		QuickMenu.RegisterMenuEntry(AutoCategory.name, "Toggle", GetString(SI_BINDING_NAME_TOGGLE_AUTO_CATEGORY), "esoui/art/mainmenu/menubar_guilds_up.dds", "esoui/art/menubar/gamepad/gp_playermenu_icon_guilds.dds", AC_Binding_ToggleCategorize)
	end
end