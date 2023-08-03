ScriptName ReadTheRoomMCM Extends MCM_ConfigBase

;--- Imports --------------------------------------------------------------
import IED ; Immersive Equipment Display
Import StringUtil ; SKSE String Utility
Import ReadTheRoomUtil ; Our helper Functions
Import MiscUtil ; Misc Utility Functions

;--- Properties -----------------------------------------------------------
Perk Property ReadTheRoomPerk Auto
GlobalVariable Property RTR_MCM_Updated Auto
GlobalVariable Property EquipWhenSafe Auto
GlobalVariable Property UnequipWhenUnsafe Auto
GlobalVariable Property ManageFollowers Auto
GlobalVariable Property CombatEquip Auto
GlobalVariable Property CombatEquipAnimation Auto
GlobalVariable Property ManageCirclets Auto
GlobalVariable Property RemoveHelmetWithoutArmor Auto
GlobalVariable Property ToggleKey Auto
GlobalVariable Property DeleteKey Auto
GlobalVariable Property EnableKey Auto
GlobalVariable Property HipPositionX Auto
GlobalVariable Property HipPositionY Auto
GlobalVariable Property HipPositionZ Auto
GlobalVariable Property HipRotationPitch Auto
GlobalVariable Property HipRotationRoll Auto
GlobalVariable Property HipRotationYaw Auto
GlobalVariable Property HipPositionXCirclet Auto
GlobalVariable Property HipPositionYCirclet Auto
GlobalVariable Property HipPositionZCirclet Auto
GlobalVariable Property HipRotationPitchCirclet Auto
GlobalVariable Property HipRotationRollCirclet Auto
GlobalVariable Property HipRotationYawCirclet Auto
GlobalVariable Property HandPositionX Auto
GlobalVariable Property HandPositionY Auto
GlobalVariable Property HandPositionZ Auto
GlobalVariable Property HandRotationPitch Auto
GlobalVariable Property HandRotationRoll Auto
GlobalVariable Property HandRotationYaw Auto
GlobalVariable Property HandPositionXCirclet Auto
GlobalVariable Property HandPositionYCirclet Auto
GlobalVariable Property HandPositionZCirclet Auto
GlobalVariable Property HandRotationPitchCirclet Auto
GlobalVariable Property HandRotationRollCirclet Auto
GlobalVariable Property HandRotationYawCirclet Auto
GlobalVariable Property HipPositionXFemale Auto
GlobalVariable Property HipPositionYFemale Auto
GlobalVariable Property HipPositionZFemale Auto
GlobalVariable Property HipRotationPitchFemale Auto
GlobalVariable Property HipRotationRollFemale Auto
GlobalVariable Property HipRotationYawFemale Auto
GlobalVariable Property HipPositionXCircletFemale Auto
GlobalVariable Property HipPositionYCircletFemale Auto
GlobalVariable Property HipPositionZCircletFemale Auto
GlobalVariable Property HipRotationPitchCircletFemale Auto
GlobalVariable Property HipRotationRollCircletFemale Auto
GlobalVariable Property HipRotationYawCircletFemale Auto
GlobalVariable Property HandPositionXFemale Auto
GlobalVariable Property HandPositionYFemale Auto
GlobalVariable Property HandPositionZFemale Auto
GlobalVariable Property HandRotationPitchFemale Auto
GlobalVariable Property HandRotationRollFemale Auto
GlobalVariable Property HandRotationYawFemale Auto
GlobalVariable Property HandPositionXCircletFemale Auto
GlobalVariable Property HandPositionYCircletFemale Auto
GlobalVariable Property HandPositionZCircletFemale Auto
GlobalVariable Property HandRotationPitchCircletFemale Auto
GlobalVariable Property HandRotationRollCircletFemale Auto
GlobalVariable Property HandRotationYawCircletFemale Auto
GlobalVariable Property RTR_Version Auto
GlobalVariable Property SheathWeaponsForAnimation Auto
GlobalVariable Property NotifyOnLocation Auto
GlobalVariable Property NotifyOnCombat Auto

;--- Private Variables ----------------------------------------------------
Bool migrated = False
String plugin = "ReadTheRoom.esp"
Actor player

;--- Functions ------------------------------------------------------------

; Returns version of this script.
Int Function GetVersion()
    return 5 ;MCM Helper
EndFunction

Event OnVersionUpdate(int aVersion)
	parent.OnVersionUpdate(aVersion)
    RTR_Version.SetValue(RTR_GetVersion())
    MigrateToMCMHelper()
    VerboseMessage("OnVersionUpdate: MCM Updated For Version " + Substring(RTR_Version.GetValue() as String, 0, Find(RTR_Version.GetValue() as String, ".", 0)+3))
    MiscUtil.PrintConsole("ReadTheRoom:OnVersionUpdate - MCM Updated")
    MiscUtil.PrintConsole("MCM Helper Version - " + aVersion)
    MiscUtil.PrintConsole("RTR Version - " + Substring(RTR_Version.GetValue() as String, 0, Find(RTR_Version.GetValue() as String, ".", 0)+3))
    RefreshMenu()
EndEvent

; Event called periodically if the active magic effect/alias/form is registered for update events. This event will not be sent if the game is in menu mode. 
Event OnUpdate()
    parent.OnUpdate()
    If !migrated
        MigrateToMCMHelper()
        migrated = True
        VerboseMessage("OnUpdate: Settings imported!")
    EndIf
EndEvent

; Called when game is reloaded.
Event OnGameReload()
    parent.OnGameReload()
    If !migrated
        MigrateToMCMHelper()
        migrated = True
        VerboseMessage("OnGameReload: Settings imported!")
    EndIf
    If GetModSettingBool("bLoadSettingsonReload:Maintenance")
        LoadSettings()
        VerboseMessage("OnGameReload: Settings autoloaded!")
    EndIf
EndEvent

; Called when this config menu is opened.
Event OnConfigOpen()
    parent.OnConfigOpen()
    If !migrated
        MigrateToMCMHelper()
        migrated = True
        VerboseMessage("OnConfigOpen: Settings imported!")
    EndIf
EndEvent

; Called when a new page is selected, including the initial empty page.
Event OnPageSelect(String a_page)
    parent.OnPageSelect(a_page)
    SetModSettingString("sAddPerk:TroubleshootingUninstall", "Enable Mod - Player")
    SetModSettingString("sRemovePerk:TroubleshootingUninstall", "Disabe Mod - Player")
    SetModSettingString("sDisableAllHelmets:TroubleshootingUninstall", "Clear any placed headgear")
    RefreshMenu()
EndEvent

; Called when this config menu is initialized.
Event OnConfigInit()
    parent.OnConfigInit()
    migrated = True
    LoadSettings()
EndEvent

; Called when setting changed to different value.
Event OnSettingChange(String a_ID)
    parent.OnSettingChange(a_ID)
    If a_ID == "iEquipWhen:HelmetEquipUnequip"
        EquipWhenSafe.SetValue(GetModSettingInt("iEquipWhen:HelmetEquipUnequip") as Float)
    ElseIf a_ID == "iUnequipWhen:HelmetEquipUnequip"
        UnequipWhenUnsafe.SetValue(GetModSettingInt("iUnequipWhen:HelmetEquipUnequip") as Float)
    ElseIf a_ID == "bManageFollowerHeadgear:HelmetEquipUnequip"
        ManageFollowers.SetValue(GetModSettingBool("bManageFollowerHeadgear:HelmetEquipUnequip") as Float)
    ElseIf a_ID == "bCombatEquip:HelmetEquipUnequip"
        CombatEquip.SetValue(GetModSettingBool("bCombatEquip:HelmetEquipUnequip") as Float)
    ElseIf a_ID == "bCombatequipusesanimation:HelmetEquipUnequip"
        CombatEquipAnimation.SetValue(GetModSettingBool("bCombatequipusesanimation:HelmetEquipUnequip") as Float)
    ElseIf a_ID == "bManageCircletslikeHelmets:HelmetEquipUnequip"
        ManageCirclets.SetValue(GetModSettingBool("bManageCircletslikeHelmets:HelmetEquipUnequip") as Float)
    ElseIf a_ID == "bRequirearmorforhipplacement:HelmetEquipUnequip"
        RemoveHelmetWithoutArmor.SetValue(GetModSettingBool("bRequirearmorforhipplacement:HelmetEquipUnequip") as Float)
    ElseIf a_ID == "bSheathWeaponsForAnimation:HelmetEquipUnequip"
        SheathWeaponsForAnimation.SetValue(GetModSettingBool("bSheathWeaponsForAnimation:HelmetEquipUnequip") as Float)
    ElseIf a_ID == "iNotifyOn:HelmetEquipUnequip"
        Int iNotifyValue = GetModSettingInt("iNotifyOn:HelmetEquipUnequip")
        If iNotifyValue == 0
            NotifyOnLocation.SetValue(1.0)
            NotifyOnCombat.SetValue(1.0)
        ElseIf iNotifyValue == 1
            NotifyOnLocation.SetValue(1.0)
            NotifyOnCombat.SetValue(0.0)
        ElseIf iNotifyValue == 2
            NotifyOnLocation.SetValue(0.0)
            NotifyOnCombat.SetValue(1.0)
        Else
            NotifyOnLocation.SetValue(0.0)
            NotifyOnCombat.SetValue(0.0)
        EndIf
    ElseIf a_ID == "iToggleequipped:Keybinds"
        ToggleKey.SetValue(GetModSettingInt("iToggleequipped:Keybinds") as Float)
        HotkeyGuard("iToggleequipped:Keybinds", ToggleKey)
    ElseIf a_ID == "iClearplacedheadgear:Keybinds"
        DeleteKey.SetValue(GetModSettingInt("iClearplacedheadgear:Keybinds") as Float)
        HotkeyGuard("iClearplacedheadgear:Keybinds", DeleteKey)
    ElseIf a_ID == "iDisablesPlayerFunctionality:Keybinds"
        EnableKey.SetValue(GetModSettingInt("iDisablesPlayerFunctionality:Keybinds") as Float)
        HotkeyGuard("iDisablesPlayerFunctionality:Keybinds", EnableKey)
    ElseIf a_ID == "fX:HelmetHipPositionMale"
        HipPositionX.SetValue(GetModSettingFloat("fX:HelmetHipPositionMale") as Float)
        RTR_MCM_Updated.SetValue(1.0)
    ElseIf a_ID == "fY:HelmetHipPositionMale"
        HipPositionY.SetValue(GetModSettingFloat("fY:HelmetHipPositionMale") as Float)
        RTR_MCM_Updated.SetValue(1.0)
    ElseIf a_ID == "fZ:HelmetHipPositionMale"
        HipPositionZ.SetValue(GetModSettingFloat("fZ:HelmetHipPositionMale") as Float)
        RTR_MCM_Updated.SetValue(1.0)
    ElseIf a_ID == "fPitch:HelmetHipPositionMale"
        HipRotationPitch.SetValue(GetModSettingFloat("fPitch:HelmetHipPositionMale") as Float)
        RTR_MCM_Updated.SetValue(1.0)
    ElseIf a_ID == "fRoll:HelmetHipPositionMale"
        HipRotationRoll.SetValue(GetModSettingFloat("fRoll:HelmetHipPositionMale") as Float)
        RTR_MCM_Updated.SetValue(1.0)
    ElseIf a_ID == "fYaw:HelmetHipPositionMale"
        HipRotationYaw.SetValue(GetModSettingFloat("fYaw:HelmetHipPositionMale") as Float)
        RTR_MCM_Updated.SetValue(1.0)
    ElseIf a_ID == "fX:CircletHipPositionMale"
        HipPositionXCirclet.SetValue(GetModSettingFloat("fX:CircletHipPositionMale") as Float)
        RTR_MCM_Updated.SetValue(1.0)
    ElseIf a_ID == "fY:CircletHipPositionMale"
        HipPositionYCirclet.SetValue(GetModSettingFloat("fY:CircletHipPositionMale") as Float)
        RTR_MCM_Updated.SetValue(1.0)
    ElseIf a_ID == "fZ:CircletHipPositionMale"
        HipPositionZCirclet.SetValue(GetModSettingFloat("fZ:CircletHipPositionMale") as Float)
        RTR_MCM_Updated.SetValue(1.0)
    ElseIf a_ID == "fPitch:CircletHipPositionMale"
        HipRotationPitchCirclet.SetValue(GetModSettingFloat("fPitch:CircletHipPositionMale") as Float)
        RTR_MCM_Updated.SetValue(1.0)
    ElseIf a_ID == "fRoll:CircletHipPositionMale"
        HipRotationRollCirclet.SetValue(GetModSettingFloat("fRoll:CircletHipPositionMale") as Float)
        RTR_MCM_Updated.SetValue(1.0)
    ElseIf a_ID == "fYaw:CircletHipPositionMale"
        HipRotationYawCirclet.SetValue(GetModSettingFloat("fYaw:CircletHipPositionMale") as Float)
        RTR_MCM_Updated.SetValue(1.0)
    ElseIf a_ID == "fX:HelmetHandPositionMale"
        HandPositionX.SetValue(GetModSettingFloat("fX:HelmetHandPositionMale") as Float)
        RTR_MCM_Updated.SetValue(1.0)
    ElseIf a_ID == "fY:HelmetHandPositionMale"
        HandPositionY.SetValue(GetModSettingFloat("fY:HelmetHandPositionMale") as Float)
        RTR_MCM_Updated.SetValue(1.0)
    ElseIf a_ID == "fZ:HelmetHandPositionMale"
        HandPositionZ.SetValue(GetModSettingFloat("fZ:HelmetHandPositionMale") as Float)
        RTR_MCM_Updated.SetValue(1.0)
    ElseIf a_ID == "fPitch:HelmetHandPositionMale"
        HandRotationPitch.SetValue(GetModSettingFloat("fPitch:HelmetHandPositionMale") as Float)
        RTR_MCM_Updated.SetValue(1.0)
    ElseIf a_ID == "fRoll:HelmetHandPositionMale"
        HandRotationRoll.SetValue(GetModSettingFloat("fRoll:HelmetHandPositionMale") as Float)
        RTR_MCM_Updated.SetValue(1.0)
    ElseIf a_ID == "fYaw:HelmetHandPositionMale"
        HandRotationYaw.SetValue(GetModSettingFloat("fYaw:HelmetHandPositionMale") as Float)
        RTR_MCM_Updated.SetValue(1.0)
    ElseIf a_ID == "fX:CircletHandPositionMale"
        HandPositionXCirclet.SetValue(GetModSettingFloat("fX:CircletHandPositionMale") as Float)
        RTR_MCM_Updated.SetValue(1.0)
    ElseIf a_ID == "fY:CircletHandPositionMale"
        HandPositionYCirclet.SetValue(GetModSettingFloat("fY:CircletHandPositionMale") as Float)
        RTR_MCM_Updated.SetValue(1.0)
    ElseIf a_ID == "fZ:CircletHandPositionMale"
        HandPositionZCirclet.SetValue(GetModSettingFloat("fZ:CircletHandPositionMale") as Float)
        RTR_MCM_Updated.SetValue(1.0)
    ElseIf a_ID == "fPitch:CircletHandPositionMale"
        HandRotationPitchCirclet.SetValue(GetModSettingFloat("fPitch:CircletHandPositionMale") as Float)
        RTR_MCM_Updated.SetValue(1.0)
    ElseIf a_ID == "fRoll:CircletHandPositionMale"
        HandRotationRollCirclet.SetValue(GetModSettingFloat("fRoll:CircletHandPositionMale") as Float)
        RTR_MCM_Updated.SetValue(1.0)
    ElseIf a_ID == "fYaw:CircletHandPositionMale"
        HandRotationYawCirclet.SetValue(GetModSettingFloat("fYaw:CircletHandPositionMale") as Float)
        RTR_MCM_Updated.SetValue(1.0)
    ElseIf a_ID == "fX:HelmetHipPositionFemale"
        HipPositionXFemale.SetValue(GetModSettingFloat("fX:HelmetHipPositionFemale") as Float)
        RTR_MCM_Updated.SetValue(1.0)
    ElseIf a_ID == "fY:HelmetHipPositionFemale"
        HipPositionYFemale.SetValue(GetModSettingFloat("fY:HelmetHipPositionFemale") as Float)
        RTR_MCM_Updated.SetValue(1.0)
    ElseIf a_ID == "fZ:HelmetHipPositionFemale"
        HipPositionZFemale.SetValue(GetModSettingFloat("fZ:HelmetHipPositionFemale") as Float)
        RTR_MCM_Updated.SetValue(1.0)
    ElseIf a_ID == "fPitch:HelmetHipPositionFemale"
        HipRotationPitchFemale.SetValue(GetModSettingFloat("fPitch:HelmetHipPositionFemale") as Float)
        RTR_MCM_Updated.SetValue(1.0)
    ElseIf a_ID == "fRoll:HelmetHipPositionFemale"
        HipRotationRollFemale.SetValue(GetModSettingFloat("fRoll:HelmetHipPositionFemale") as Float)
        RTR_MCM_Updated.SetValue(1.0)
    ElseIf a_ID == "fYaw:HelmetHipPositionFemale"
        HipRotationYawFemale.SetValue(GetModSettingFloat("fYaw:HelmetHipPositionFemale") as Float)
        RTR_MCM_Updated.SetValue(1.0)
    ElseIf a_ID == "fX:CircletHipPositionFemale"
        HipPositionXCircletFemale.SetValue(GetModSettingFloat("fX:CircletHipPositionFemale") as Float)
        RTR_MCM_Updated.SetValue(1.0)
    ElseIf a_ID == "fY:CircletHipPositionFemale"
        HipPositionYCircletFemale.SetValue(GetModSettingFloat("fY:CircletHipPositionFemale") as Float)
        RTR_MCM_Updated.SetValue(1.0)
    ElseIf a_ID == "fZ:CircletHipPositionFemale"
        HipPositionZCircletFemale.SetValue(GetModSettingFloat("fZ:CircletHipPositionFemale") as Float)
        RTR_MCM_Updated.SetValue(1.0)
    ElseIf a_ID == "fPitch:CircletHipPositionFemale"
        HipRotationPitchCircletFemale.SetValue(GetModSettingFloat("fPitch:CircletHipPositionFemale") as Float)
        RTR_MCM_Updated.SetValue(1.0)
    ElseIf a_ID == "fRoll:CircletHipPositionFemale"
        HipRotationRollCircletFemale.SetValue(GetModSettingFloat("fRoll:CircletHipPositionFemale") as Float)
        RTR_MCM_Updated.SetValue(1.0)
    ElseIf a_ID == "fYaw:CircletHipPositionFemale"
        HipRotationYawCircletFemale.SetValue(GetModSettingFloat("fYaw:CircletHipPositionFemale") as Float)
        RTR_MCM_Updated.SetValue(1.0)
    ElseIf a_ID == "fX:HelmetHandPositionFemale"
        HandPositionXFemale.SetValue(GetModSettingFloat("fX:HelmetHandPositionFemale") as Float)
        RTR_MCM_Updated.SetValue(1.0)
    ElseIf a_ID == "fY:HelmetHandPositionFemale"
        HandPositionYFemale.SetValue(GetModSettingFloat("fY:HelmetHandPositionFemale") as Float)
        RTR_MCM_Updated.SetValue(1.0)
    ElseIf a_ID == "fZ:HelmetHandPositionFemale"
        HandPositionZFemale.SetValue(GetModSettingFloat("fZ:HelmetHandPositionFemale") as Float)
        RTR_MCM_Updated.SetValue(1.0)
    ElseIf a_ID == "fPitch:HelmetHandPositionFemale"
        HandRotationPitchFemale.SetValue(GetModSettingFloat("fPitch:HelmetHandPositionFemale") as Float)
        RTR_MCM_Updated.SetValue(1.0)
    ElseIf a_ID == "fRoll:HelmetHandPositionFemale"
        HandRotationRollFemale.SetValue(GetModSettingFloat("fRoll:HelmetHandPositionFemale") as Float)
        RTR_MCM_Updated.SetValue(1.0)
    ElseIf a_ID == "fYaw:HelmetHandPositionFemale"
        HandRotationYawFemale.SetValue(GetModSettingFloat("fYaw:HelmetHandPositionFemale") as Float)
        RTR_MCM_Updated.SetValue(1.0)
    ElseIf a_ID == "fX:CircletHandPositionFemale"
        HandPositionXCircletFemale.SetValue(GetModSettingFloat("fX:CircletHandPositionFemale") as Float)
        RTR_MCM_Updated.SetValue(1.0)
    ElseIf a_ID == "fY:CircletHandPositionFemale"
        HandPositionYCircletFemale.SetValue(GetModSettingFloat("fY:CircletHandPositionFemale") as Float)
        RTR_MCM_Updated.SetValue(1.0)
    ElseIf a_ID == "fZ:CircletHandPositionFemale"
        HandPositionZCircletFemale.SetValue(GetModSettingFloat("fZ:CircletHandPositionFemale") as Float)
        RTR_MCM_Updated.SetValue(1.0)
    ElseIf a_ID == "fPitch:CircletHandPositionFemale"
        HandRotationPitchCircletFemale.SetValue(GetModSettingFloat("fPitch:CircletHandPositionFemale") as Float)
        RTR_MCM_Updated.SetValue(1.0)
    ElseIf a_ID == "fRoll:CircletHandPositionFemale"
        HandRotationRollCircletFemale.SetValue(GetModSettingFloat("fRoll:CircletHandPositionFemale") as Float)
        RTR_MCM_Updated.SetValue(1.0)
    ElseIf a_ID == "fYaw:CircletHandPositionFemale"
        HandRotationYawCircletFemale.SetValue(GetModSettingFloat("fYaw:CircletHandPositionFemale") as Float)
        RTR_MCM_Updated.SetValue(1.0)
    EndIf
EndEvent

Function Default()
    SetModSettingInt("iEquipWhen:HelmetEquipUnequip", 0)
    SetModSettingInt("iUnequipWhen:HelmetEquipUnequip", 0)
    SetModSettingBool("bManageFollowerHeadgear:HelmetEquipUnequip", True)
    SetModSettingBool("bCombatEquip:HelmetEquipUnequip", True)
    SetModSettingBool("bCombatequipusesanimation:HelmetEquipUnequip", True)
    SetModSettingBool("bManageCircletslikeHelmets:HelmetEquipUnequip", True)
    SetModSettingBool("bRequirearmorforhipplacement:HelmetEquipUnequip", True)
    SetModSettingBool("bSheathWeaponsForAnimation:HelmetEquipUnequip", True) 
    SetModSettingInt("iNotifyOn:HelmetEquipUnequip", 0)
    SetModSettingString("sVersion:Version", "1.0")
    SetModSettingInt("iToggleequipped:Keybinds", 27)
    SetModSettingInt("iClearplacedheadgear:Keybinds", 40)
    SetModSettingInt("iDisablesPlayerFunctionality:Keybinds", 26)
    SetModSettingFloat("fX:HelmetHipPositionMale", 12.8)
    SetModSettingFloat("fY:HelmetHipPositionMale", -10.25)
    SetModSettingFloat("fZ:HelmetHipPositionMale", -0.65)
    SetModSettingFloat("fPitch:HelmetHipPositionMale", -52.9)
    SetModSettingFloat("fRoll:HelmetHipPositionMale", 15.0)
    SetModSettingFloat("fYaw:HelmetHipPositionMale", 94.5)
    SetModSettingFloat("fX:CircletHipPositionMale", 12.8)
    SetModSettingFloat("fY:CircletHipPositionMale", -10.25)
    SetModSettingFloat("fZ:CircletHipPositionMale", -0.65)
    SetModSettingFloat("fPitch:CircletHipPositionMale", 46.0)
    SetModSettingFloat("fRoll:CircletHipPositionMale", 15.0)
    SetModSettingFloat("fYaw:CircletHipPositionMale", 68.9)
    SetModSettingFloat("fX:HelmetHandPositionMale", 6.8)
    SetModSettingFloat("fY:HelmetHandPositionMale", -11.75)
    SetModSettingFloat("fZ:HelmetHandPositionMale", -10.85)
    SetModSettingFloat("fPitch:HelmetHandPositionMale", 270.6)
    SetModSettingFloat("fRoll:HelmetHandPositionMale", 0.44)
    SetModSettingFloat("fYaw:HelmetHandPositionMale", 260.45)
    SetModSettingFloat("fX:CircletHandPositionMale", -0.2)
    SetModSettingFloat("fY:CircletHandPositionMale", -11.25)
    SetModSettingFloat("fZ:CircletHandPositionMale", 10.85)
    SetModSettingFloat("fPitch:CircletHandPositionMale", 270.6)
    SetModSettingFloat("fRoll:CircletHandPositionMale", 22.94)
    SetModSettingFloat("fYaw:CircletHandPositionMale", 260.45)
    SetModSettingFloat("fX:HelmetHipPositionFemale", 12.8)
    SetModSettingFloat("fY:HelmetHipPositionFemale", -10.25)
    SetModSettingFloat("fZ:HelmetHipPositionFemale", -0.65)
    SetModSettingFloat("fPitch:HelmetHipPositionFemale", -52.9)
    SetModSettingFloat("fRoll:HelmetHipPositionFemale", 15.0)
    SetModSettingFloat("fYaw:HelmetHipPositionFemale", 94.4)
    SetModSettingFloat("fX:CircletHipPositionFemale", 12.8)
    SetModSettingFloat("fY:CircletHipPositionFemale", -10.25)
    SetModSettingFloat("fZ:CircletHipPositionFemale", -0.65)
    SetModSettingFloat("fPitch:CircletHipPositionFemale", 46.0)
    SetModSettingFloat("fRoll:CircletHipPositionFemale", 15.0)
    SetModSettingFloat("fYaw:CircletHipPositionFemale", 68.9)
    SetModSettingFloat("fX:HelmetHandPositionFemale", 8.0)
    SetModSettingFloat("fY:HelmetHandPositionFemale", -15.0)
    SetModSettingFloat("fZ:HelmetHandPositionFemale", 10.85)
    SetModSettingFloat("fPitch:HelmetHandPositionFemale", 260.0)
    SetModSettingFloat("fRoll:HelmetHandPositionFemale", 29.0)
    SetModSettingFloat("fYaw:HelmetHandPositionFemale", 245.0)
    SetModSettingFloat("fX:CircletHandPositionFemale", -0.2)
    SetModSettingFloat("fY:CircletHandPositionFemale", -15.0)
    SetModSettingFloat("fZ:CircletHandPositionFemale", 10.85)
    SetModSettingFloat("fPitch:CircletHandPositionFemale", 270.6)
    SetModSettingFloat("fRoll:CircletHandPositionFemale", 22.94)
    SetModSettingFloat("fYaw:CircletHandPositionFemale", 260.45)
    SetModSettingBool("bEnabled:Maintenance", True)
    SetModSettingInt("iLoadingDelay:Maintenance", 0)
    SetModSettingBool("bLoadSettingsonReload:Maintenance", False)
    SetModSettingBool("bVerbose:Maintenance", False)
    VerboseMessage("Settings reset!")
    Load()
EndFunction

Function Load()
    EquipWhenSafe.SetValue(GetModSettingInt("iEquipWhen:HelmetEquipUnequip") as Float)
    UnequipWhenUnsafe.SetValue(GetModSettingInt("iUnequipWhen:HelmetEquipUnequip") as Float)
    ManageFollowers.SetValue(GetModSettingBool("bManageFollowerHeadgear:HelmetEquipUnequip") as Float)
    CombatEquip.SetValue(GetModSettingBool("bCombatEquip:HelmetEquipUnequip") as Float)
    CombatEquipAnimation.SetValue(GetModSettingBool("bCombatequipusesanimation:HelmetEquipUnequip") as Float)
    ManageCirclets.SetValue(GetModSettingBool("bManageCircletslikeHelmets:HelmetEquipUnequip") as Float)
    RemoveHelmetWithoutArmor.SetValue(GetModSettingBool("bRequirearmorforhipplacement:HelmetEquipUnequip") as Float)
    SheathWeaponsForAnimation.SetValue(GetModSettingBool("bSheathWeaponsForAnimation:HelmetEquipUnequip") as Float)
    Int iNotifyValue = GetModSettingInt("iNotifyOn:HelmetEquipUnequip")
    If iNotifyValue == 0
        NotifyOnLocation.SetValue(1.0)
        NotifyOnCombat.SetValue(1.0)
    ElseIf iNotifyValue == 1
        NotifyOnLocation.SetValue(1.0)
        NotifyOnCombat.SetValue(0.0)
    ElseIf iNotifyValue == 2
        NotifyOnLocation.SetValue(0.0)
        NotifyOnCombat.SetValue(1.0)
    Else
        NotifyOnLocation.SetValue(0.0)
        NotifyOnCombat.SetValue(0.0)
    EndIf
    SetModSettingString("sVersion:Version", Substring(RTR_Version.GetValue() as String, 0, Find(RTR_Version.GetValue() as String, ".", 0)+3))
    ToggleKey.SetValue(GetModSettingInt("iToggleequipped:Keybinds") as Float)
    DeleteKey.SetValue(GetModSettingInt("iClearplacedheadgear:Keybinds") as Float)
    EnableKey.SetValue(GetModSettingInt("iDisablesPlayerFunctionality:Keybinds") as Float)
    HipPositionX.SetValue(GetModSettingFloat("fX:HelmetHipPositionMale") as Float)
    HipPositionY.SetValue(GetModSettingFloat("fY:HelmetHipPositionMale") as Float)
    HipPositionZ.SetValue(GetModSettingFloat("fZ:HelmetHipPositionMale") as Float)
    HipRotationPitch.SetValue(GetModSettingFloat("fPitch:HelmetHipPositionMale") as Float)
    HipRotationRoll.SetValue(GetModSettingFloat("fRoll:HelmetHipPositionMale") as Float)
    HipRotationYaw.SetValue(GetModSettingFloat("fYaw:HelmetHipPositionMale") as Float)
    HipPositionXCirclet.SetValue(GetModSettingFloat("fX:CircletHipPositionMale") as Float)
    HipPositionYCirclet.SetValue(GetModSettingFloat("fY:CircletHipPositionMale") as Float)
    HipPositionZCirclet.SetValue(GetModSettingFloat("fZ:CircletHipPositionMale") as Float)
    HipRotationPitchCirclet.SetValue(GetModSettingFloat("fPitch:CircletHipPositionMale") as Float)
    HipRotationRollCirclet.SetValue(GetModSettingFloat("fRoll:CircletHipPositionMale") as Float)
    HipRotationYawCirclet.SetValue(GetModSettingFloat("fYaw:CircletHipPositionMale") as Float)
    HandPositionX.SetValue(GetModSettingFloat("fX:HelmetHandPositionMale") as Float)
    HandPositionY.SetValue(GetModSettingFloat("fY:HelmetHandPositionMale") as Float)
    HandPositionZ.SetValue(GetModSettingFloat("fZ:HelmetHandPositionMale") as Float)
    HandRotationPitch.SetValue(GetModSettingFloat("fPitch:HelmetHandPositionMale") as Float)
    HandRotationRoll.SetValue(GetModSettingFloat("fRoll:HelmetHandPositionMale") as Float)
    HandRotationYaw.SetValue(GetModSettingFloat("fYaw:HelmetHandPositionMale") as Float)
    HandPositionXCirclet.SetValue(GetModSettingFloat("fX:CircletHandPositionMale") as Float)
    HandPositionYCirclet.SetValue(GetModSettingFloat("fY:CircletHandPositionMale") as Float)
    HandPositionZCirclet.SetValue(GetModSettingFloat("fZ:CircletHandPositionMale") as Float)
    HandRotationPitchCirclet.SetValue(GetModSettingFloat("fPitch:CircletHandPositionMale") as Float)
    HandRotationRollCirclet.SetValue(GetModSettingFloat("fRoll:CircletHandPositionMale") as Float)
    HandRotationYawCirclet.SetValue(GetModSettingFloat("fYaw:CircletHandPositionMale") as Float)
    HipPositionXFemale.SetValue(GetModSettingFloat("fX:HelmetHipPositionFemale") as Float)
    HipPositionYFemale.SetValue(GetModSettingFloat("fY:HelmetHipPositionFemale") as Float)
    HipPositionZFemale.SetValue(GetModSettingFloat("fZ:HelmetHipPositionFemale") as Float)
    HipRotationPitchFemale.SetValue(GetModSettingFloat("fPitch:HelmetHipPositionFemale") as Float)
    HipRotationRollFemale.SetValue(GetModSettingFloat("fRoll:HelmetHipPositionFemale") as Float)
    HipRotationYawFemale.SetValue(GetModSettingFloat("fYaw:HelmetHipPositionFemale") as Float)
    HipPositionXCircletFemale.SetValue(GetModSettingFloat("fX:CircletHipPositionFemale") as Float)
    HipPositionYCircletFemale.SetValue(GetModSettingFloat("fY:CircletHipPositionFemale") as Float)
    HipPositionZCircletFemale.SetValue(GetModSettingFloat("fZ:CircletHipPositionFemale") as Float)
    HipRotationPitchCircletFemale.SetValue(GetModSettingFloat("fPitch:CircletHipPositionFemale") as Float)
    HipRotationRollCircletFemale.SetValue(GetModSettingFloat("fRoll:CircletHipPositionFemale") as Float)
    HipRotationYawCircletFemale.SetValue(GetModSettingFloat("fYaw:CircletHipPositionFemale") as Float)
    HandPositionXFemale.SetValue(GetModSettingFloat("fX:HelmetHandPositionFemale") as Float)
    HandPositionYFemale.SetValue(GetModSettingFloat("fY:HelmetHandPositionFemale") as Float)
    HandPositionZFemale.SetValue(GetModSettingFloat("fZ:HelmetHandPositionFemale") as Float)
    HandRotationPitchFemale.SetValue(GetModSettingFloat("fPitch:HelmetHandPositionFemale") as Float)
    HandRotationRollFemale.SetValue(GetModSettingFloat("fRoll:HelmetHandPositionFemale") as Float)
    HandRotationYawFemale.SetValue(GetModSettingFloat("fYaw:HelmetHandPositionFemale") as Float)
    HandPositionXCircletFemale.SetValue(GetModSettingFloat("fX:CircletHandPositionFemale") as Float)
    HandPositionYCircletFemale.SetValue(GetModSettingFloat("fY:CircletHandPositionFemale") as Float)
    HandPositionZCircletFemale.SetValue(GetModSettingFloat("fZ:CircletHandPositionFemale") as Float)
    HandRotationPitchCircletFemale.SetValue(GetModSettingFloat("fPitch:CircletHandPositionFemale") as Float)
    HandRotationRollCircletFemale.SetValue(GetModSettingFloat("fRoll:CircletHandPositionFemale") as Float)
    HandRotationYawCircletFemale.SetValue(GetModSettingFloat("fYaw:CircletHandPositionFemale") as Float)
    player = Game.GetPlayer()
    player.removeperk(ReadTheRoomPerk)
    player.addperk(ReadTheRoomPerk)
    VerboseMessage("Settings applied!")
EndFunction

Function LoadSettings()
    If GetModSettingBool("bEnabled:Maintenance") == false
        return
    EndIf
    Utility.Wait(GetModSettingInt("iLoadingDelay:Maintenance"))
    VerboseMessage("Settings autoloaded!")
    Load()
EndFunction

Function AddPerk()
    player = Game.GetPlayer()
    player.AddPerk(ReadTheRoomPerk)
    SetModSettingString("sAddPerk:TroubleshootingUninstall", "$Perkadded")
    RefreshMenu()
EndFunction

Function RemovePerk()
    player = Game.GetPlayer()
    player.RemovePerk(ReadTheRoomPerk)
    SetModSettingString("sRemovePerk:TroubleshootingUninstall", "$Perkremoved")
    RefreshMenu()
EndFunction

Function HotkeyGuard(String SettingsName, GlobalVariable var)
    If GetModSettingInt(SettingsName) == 271
        SetModSettingInt(SettingsName, -1)
        var.SetValueInt(-1)
    EndIf
    ; @note Commented out becaues it is no longer needed since we're tracking MCM updates via globalvariable
    player = Game.GetPlayer()
    player.removeperk(ReadTheRoomPerk)
    player.addperk(ReadTheRoomPerk)
EndFunction

Function MigrateToMCMHelper()
    ; Migrating to MCM Helper
    SetModSettingInt("iEquipWhen:HelmetEquipUnequip", EquipWhenSafe.GetValue() as Int)
    SetModSettingInt("iUnequipWhen:HelmetEquipUnequip", UnequipWhenUnsafe.GetValue() as Int)
    SetModSettingBool("bManageFollowerHeadgear:HelmetEquipUnequip", ManageFollowers.GetValue() as Bool)
    SetModSettingBool("bCombatEquip:HelmetEquipUnequip", CombatEquip.GetValue() as Bool)
    SetModSettingBool("bCombatequipusesanimation:HelmetEquipUnequip", CombatEquipAnimation.GetValue() as Bool)
    SetModSettingBool("bManageCircletslikeHelmets:HelmetEquipUnequip", ManageCirclets.GetValue() as Bool)
    SetModSettingBool("bRequirearmorforhipplacement:HelmetEquipUnequip", RemoveHelmetWithoutArmor.GetValue() as Bool)
    SetModSettingBool("bSheathWeaponsForAnimation:HelmetEquipUnequip", SheathWeaponsForAnimation.GetValue() as Bool)
    If (NotifyOnLocation.GetValue() as Bool) && (NotifyOnCombat.GetValue() as Bool)
        SetModSettingInt("iNotifyOn:HelmetEquipUnequip", 0)
    ElseIf (NotifyOnLocation.GetValue() as Bool) && !(NotifyOnCombat.GetValue() as Bool)
        SetModSettingInt("iNotifyOn:HelmetEquipUnequip", 1)
    ElseIf !(NotifyOnLocation.GetValue() as Bool) && (NotifyOnCombat.GetValue() as Bool)
        SetModSettingInt("iNotifyOn:HelmetEquipUnequip", 2)
    Else
        SetModSettingInt("iNotifyOn:HelmetEquipUnequip", 3)
    EndIf
    SetModSettingString("sVersion:Version", Substring(RTR_Version.GetValue() as String, 0, Find(RTR_Version.GetValue() as String, ".", 0)+3))
    SetModSettingInt("iToggleequipped:Keybinds", ToggleKey.GetValue() as Int)
    SetModSettingInt("iClearplacedheadgear:Keybinds", DeleteKey.GetValue() as Int)
    SetModSettingInt("iDisablesPlayerFunctionality:Keybinds", EnableKey.GetValue() as Int)
    SetModSettingFloat("fX:HelmetHipPositionMale", HipPositionX.GetValue())
    SetModSettingFloat("fY:HelmetHipPositionMale", HipPositionY.GetValue())
    SetModSettingFloat("fZ:HelmetHipPositionMale", HipPositionZ.GetValue())
    SetModSettingFloat("fPitch:HelmetHipPositionMale", HipRotationPitch.GetValue())
    SetModSettingFloat("fRoll:HelmetHipPositionMale", HipRotationRoll.GetValue())
    SetModSettingFloat("fYaw:HelmetHipPositionMale", HipRotationYaw.GetValue())
    SetModSettingFloat("fX:CircletHipPositionMale", HipPositionXCirclet.GetValue())
    SetModSettingFloat("fY:CircletHipPositionMale", HipPositionYCirclet.GetValue())
    SetModSettingFloat("fZ:CircletHipPositionMale", HipPositionZCirclet.GetValue())
    SetModSettingFloat("fPitch:CircletHipPositionMale", HipRotationPitchCirclet.GetValue())
    SetModSettingFloat("fRoll:CircletHipPositionMale", HipRotationRollCirclet.GetValue())
    SetModSettingFloat("fYaw:CircletHipPositionMale", HipRotationYawCirclet.GetValue())
    SetModSettingFloat("fX:HelmetHandPositionMale", HandPositionX.GetValue())
    SetModSettingFloat("fY:HelmetHandPositionMale", HandPositionY.GetValue())
    SetModSettingFloat("fZ:HelmetHandPositionMale", HandPositionZ.GetValue())
    SetModSettingFloat("fPitch:HelmetHandPositionMale", HandRotationPitch.GetValue())
    SetModSettingFloat("fRoll:HelmetHandPositionMale", HandRotationRoll.GetValue())
    SetModSettingFloat("fYaw:HelmetHandPositionMale", HandRotationYaw.GetValue())
    SetModSettingFloat("fX:CircletHandPositionMale", HandPositionXCirclet.GetValue())
    SetModSettingFloat("fY:CircletHandPositionMale", HandPositionYCirclet.GetValue())
    SetModSettingFloat("fZ:CircletHandPositionMale", HandPositionZCirclet.GetValue())
    SetModSettingFloat("fPitch:CircletHandPositionMale", HandRotationPitchCirclet.GetValue())
    SetModSettingFloat("fRoll:CircletHandPositionMale", HandRotationRollCirclet.GetValue())
    SetModSettingFloat("fYaw:CircletHandPositionMale", HandRotationYawCirclet.GetValue())
    SetModSettingFloat("fX:HelmetHipPositionFemale", HipPositionXFemale.GetValue())
    SetModSettingFloat("fY:HelmetHipPositionFemale", HipPositionYFemale.GetValue())
    SetModSettingFloat("fZ:HelmetHipPositionFemale", HipPositionZFemale.GetValue())
    SetModSettingFloat("fPitch:HelmetHipPositionFemale", HipRotationPitchFemale.GetValue())
    SetModSettingFloat("fRoll:HelmetHipPositionFemale", HipRotationRollFemale.GetValue())
    SetModSettingFloat("fYaw:HelmetHipPositionFemale", HipRotationYawFemale.GetValue())
    SetModSettingFloat("fX:CircletHipPositionFemale", HipPositionXCircletFemale.GetValue())
    SetModSettingFloat("fY:CircletHipPositionFemale", HipPositionYCircletFemale.GetValue())
    SetModSettingFloat("fZ:CircletHipPositionFemale", HipPositionZCircletFemale.GetValue())
    SetModSettingFloat("fPitch:CircletHipPositionFemale", HipRotationPitchCircletFemale.GetValue())
    SetModSettingFloat("fRoll:CircletHipPositionFemale", HipRotationRollCircletFemale.GetValue())
    SetModSettingFloat("fYaw:CircletHipPositionFemale", HipRotationYawCircletFemale.GetValue())
    SetModSettingFloat("fX:HelmetHandPositionFemale", HandPositionXFemale.GetValue())
    SetModSettingFloat("fY:HelmetHandPositionFemale", HandPositionYFemale.GetValue())
    SetModSettingFloat("fZ:HelmetHandPositionFemale", HandPositionZFemale.GetValue())
    SetModSettingFloat("fPitch:HelmetHandPositionFemale", HandRotationPitchFemale.GetValue())
    SetModSettingFloat("fRoll:HelmetHandPositionFemale", HandRotationRollFemale.GetValue())
    SetModSettingFloat("fYaw:HelmetHandPositionFemale", HandRotationYawFemale.GetValue())
    SetModSettingFloat("fX:CircletHandPositionFemale", HandPositionXCircletFemale.GetValue())
    SetModSettingFloat("fY:CircletHandPositionFemale", HandPositionYCircletFemale.GetValue())
    SetModSettingFloat("fZ:CircletHandPositionFemale", HandPositionZCircletFemale.GetValue())
    SetModSettingFloat("fPitch:CircletHandPositionFemale", HandRotationPitchCircletFemale.GetValue())
    SetModSettingFloat("fRoll:CircletHandPositionFemale", HandRotationRollCircletFemale.GetValue())
    SetModSettingFloat("fYaw:CircletHandPositionFemale", HandRotationYawCircletFemale.GetValue())
EndFunction

Function VerboseMessage(String m)
    Debug.Trace("[Read the Room - Immersive and Animated Helmet Management] " + m)
    If GetModSettingBool("bVerbose:Maintenance")
        Debug.Notification("[Read the Room - Immersive and Animated Helmet Management] " + m)
    EndIf
EndFunction
