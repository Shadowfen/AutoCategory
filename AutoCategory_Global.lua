AC_BAG_TYPE_BACKPACK = 1
AC_BAG_TYPE_BANK = 2
AC_BAG_TYPE_GUILDBANK = 3
AC_BAG_TYPE_CRAFTBAG = 4
AC_BAG_TYPE_CRAFTSTATION = 5
AC_BAG_TYPE_HOUSEBANK = 6

local SF = LibSFUtils
 
AutoCategory = {
    name = "AutoCategory",
    version = "2.0.3",
    settingName = "AutoCategory",
    settingDisplayName = "AutoCategory - Revised",
    author = "Shadowfen, crafty35, RockingDice",
}
AutoCategory.settingDisplayName = SF.GetIconized(AutoCategory.settingDisplayName, SF.colors.gold.hex)
AutoCategory.version = SF.GetIconized(AutoCategory.version, SF.colors.gold.hex)
AutoCategory.author = SF.GetIconized(AutoCategory.author, SF.colors.purple.hex)

AutoCategory.RuleFunc = {}
AutoCategory.Plugins = {}
AutoCategory.Inited = false
AutoCategory.Enabled = true

SF.LoadLanguage(AutoCategory_localization_strings, "en")

