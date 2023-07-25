scriptname ReadTheRoomMCM extends SKI_ConfigBase

GlobalVariable property ToggleKey auto
GlobalVariable property DeleteKey auto
GlobalVariable property EnableKey auto
GlobalVariable property HipPositionX auto
GlobalVariable property HipPositionY auto
GlobalVariable property HipPositionZ auto
GlobalVariable property HipRotationPitch auto
GlobalVariable property HipRotationRoll auto
GlobalVariable property HipRotationYaw auto
GlobalVariable property HipPositionXCirclet auto
GlobalVariable property HipPositionYCirclet auto
GlobalVariable property HipPositionZCirclet auto
GlobalVariable property HipRotationPitchCirclet auto
GlobalVariable property HipRotationRollCirclet auto
GlobalVariable property HipRotationYawCirclet auto
GlobalVariable property HandPositionX auto
GlobalVariable property HandPositionY auto
GlobalVariable property HandPositionZ auto
GlobalVariable property HandRotationPitch auto
GlobalVariable property HandRotationRoll auto
GlobalVariable property HandRotationYaw auto
GlobalVariable property HandPositionXCirclet auto
GlobalVariable property HandPositionYCirclet auto
GlobalVariable property HandPositionZCirclet auto
GlobalVariable property HandRotationPitchCirclet auto
GlobalVariable property HandRotationRollCirclet auto
GlobalVariable property HandRotationYawCirclet auto
GlobalVariable property HipPositionXFemale auto
GlobalVariable property HipPositionYFemale auto
GlobalVariable property HipPositionZFemale auto
GlobalVariable property HipRotationPitchFemale auto
GlobalVariable property HipRotationRollFemale auto
GlobalVariable property HipRotationYawFemale auto
GlobalVariable property HipPositionXCircletFemale auto
GlobalVariable property HipPositionYCircletFemale auto
GlobalVariable property HipPositionZCircletFemale auto
GlobalVariable property HipRotationPitchCircletFemale auto
GlobalVariable property HipRotationRollCircletFemale auto
GlobalVariable property HipRotationYawCircletFemale auto
GlobalVariable property HandPositionXFemale auto
GlobalVariable property HandPositionYFemale auto
GlobalVariable property HandPositionZFemale auto
GlobalVariable property HandRotationPitchFemale auto
GlobalVariable property HandRotationRollFemale auto
GlobalVariable property HandRotationYawFemale auto
GlobalVariable property HandPositionXCircletFemale auto
GlobalVariable property HandPositionYCircletFemale auto
GlobalVariable property HandPositionZCircletFemale auto
GlobalVariable property HandRotationPitchCircletFemale auto
GlobalVariable property HandRotationRollCircletFemale auto
GlobalVariable property HandRotationYawCircletFemale auto
GlobalVariable property EquipWhenSafe auto
GlobalVariable property UnequipWhenUnsafe auto
GlobalVariable property CombatEquip auto
GlobalVariable property CombatEquipAnimation auto
GlobalVariable property ManageCirclets auto
GlobalVariable property ManageFollowers auto
GlobalVariable property RemoveHelmetWithoutArmor auto

; Remaster only

GlobalVariable property RTR_Version auto
GlobalVariable property SheathWeaponsForAnimation auto
GlobalVariable property NotifyOnLocation auto
GlobalVariable property NotifyOnCombat auto

Perk property ReadTheRoomPerk auto

Import IED
Int OID_ManageFollowers
Int OID_CombatEquip
Int OID_CombatEquipAnimation
Int OID_ManageCirclets
Int OID_RemoveHelmetWithoutArmor
Int OID_EquipWhenSafe
Int OID_UnequipWhenUnsafe
Int OID_AddPerk
Int OID_RemovePerk
Int OID_DeleteAll
Int OID_ToggleKey
Int OID_DeleteKey
Int OID_EnableKey
Int OID_HipPositionX
Int OID_HipPositionY
Int OID_HipPositionZ
Int OID_HipRotationPitch
Int OID_HipRotationRoll
Int OID_HipRotationYaw
Int OID_HipPositionXCirclet
Int OID_HipPositionYCirclet
Int OID_HipPositionZCirclet
Int OID_HipRotationPitchCirclet
Int OID_HipRotationRollCirclet
Int OID_HipRotationYawCirclet
Int OID_HandPositionX
Int OID_HandPositionY
Int OID_HandPositionZ
Int OID_HandRotationPitch
Int OID_HandRotationRoll
Int OID_HandRotationYaw
Int OID_HandPositionXCirclet
Int OID_HandPositionYCirclet
Int OID_HandPositionZCirclet
Int OID_HandRotationPitchCirclet
Int OID_HandRotationRollCirclet
Int OID_HandRotationYawCirclet
Int OID_HipPositionXFemale
Int OID_HipPositionYFemale
Int OID_HipPositionZFemale
Int OID_HipRotationPitchFemale
Int OID_HipRotationRollFemale
Int OID_HipRotationYawFemale
Int OID_HipPositionXCircletFemale
Int OID_HipPositionYCircletFemale
Int OID_HipPositionZCircletFemale
Int OID_HipRotationPitchCircletFemale
Int OID_HipRotationRollCircletFemale
Int OID_HipRotationYawCircletFemale
Int OID_HandPositionXFemale
Int OID_HandPositionYFemale
Int OID_HandPositionZFemale
Int OID_HandRotationPitchFemale
Int OID_HandRotationRollFemale
Int OID_HandRotationYawFemale
Int OID_HandPositionXCircletFemale
Int OID_HandPositionYCircletFemale
Int OID_HandPositionZCircletFemale
Int OID_HandRotationPitchCircletFemale
Int OID_HandRotationRollCircletFemale
Int OID_HandRotationYawCircletFemale
Int CurrentEquipWhenSafe = 0
Int CurrentUnequipWhenUnsafe = 0
Actor player
String[] EquipOptions
String[] UnequipOptions
String plugin = "ReadTheRoom.esp"
String precision = "{1}"
Bool CombatEquipVal
Bool CombatEquipAnimationVal
Bool ManageCircletsVal
Bool RemoveHelmetWithoutArmorVal
Bool ManageFollowersVal

; Remaster only
Int OID_SheathWeaponsForAnimation
Int OID_Notify

Bool SheathWeaponsForAnimationVal
Int CurrentNotify = 0
String[] NotifyOptions

Event OnConfigInit()
	EquipOptions = new string[3]
	EquipOptions[0] = "Nearing danger"
	EquipOptions[1] = "Leaving safety"
	EquipOptions[2] = "Only with toggle key"
	UnequipOptions = new string[3]
	UnequipOptions[0] = "Entering safety"
	UnequipOptions[1] = "Leaving danger"
	UnequipOptions[2] = "Only with toggle key"
	NotifyOptions = new string[4]
	NotifyOptions[0] = "Location and Combat"
	NotifyOptions[1] = "Location Change"
	NotifyOptions[2] = "Combat Equip"
	NotifyOptions[3] = "Disable Notifications"
	
	Pages = new string[2]
	Pages[0] = "General"
	Pages[1] = "Positioning"
	
	if CombatEquip.GetValue() == 1
		CombatEquipVal = true
	else
		CombatEquipVal = false
	endif
	if CombatEquipAnimation.GetValue() == 1
		CombatEquipAnimationVal = true
	else
		CombatEquipAnimationVal = false
	endif
	if ManageCirclets.GetValue() == 1
		ManageCircletsVal = true
	else
		ManageCircletsVal = false
	endif
	if RemoveHelmetWithoutArmor.GetValue() == 1
		RemoveHelmetWithoutArmorVal = true
	else
		RemoveHelmetWithoutArmorVal = false
	endif
	if ManageFollowers.GetValue() == 1
		ManageFollowersVal = true
	else
		ManageFollowersVal = false
	endif
	if SheathWeaponsForAnimation.GetValue() == 1
		SheathWeaponsForAnimationVal = true
	else
		SheathWeaponsForAnimationVal = false
	endif
	if NotifyOnLocation.GetValue() == 1 && NotifyOnCombat.GetValue() == 1
		CurrentNotify = 0
	elseif NotifyOnLocation.GetValue() == 1 && NotifyOnCombat.GetValue() == 0
		CurrentNotify = 1
	elseif NotifyOnLocation.GetValue() == 0 && NotifyOnCombat.GetValue() == 1
		CurrentNotify = 2
	else
		CurrentNotify = 3
	endif
EndEvent

Event OnPageReset(String page)
	SetCursorFillMode(TOP_TO_BOTTOM)
	SetCursorPosition(0)
	if page == "General"
		AddHeaderOption("Read The Room - Version " + RTR_Version.GetValue())
		AddHeaderOption("Helmet Equip/Unequip")
		OID_EquipWhenSafe = AddMenuOption("Equip When:", EquipOptions[CurrentEquipWhenSafe])
		OID_UnequipWhenUnsafe = AddMenuOption("Unequip When:", UnequipOptions[CurrentUnequipWhenUnsafe])
		OID_ManageFollowers = AddToggleOption("Manage Follower Headgear", ManageFollowersVal)
		OID_CombatEquip = AddToggleOption("Combat Equip", CombatEquipVal)
		OID_CombatEquipAnimation = AddToggleOption("Combat equip uses animation", CombatEquipAnimationVal)
		OID_ManageCirclets = AddToggleOption("Manage Circlets like Helmets", ManageCircletsVal)
		OID_RemoveHelmetWithoutArmor = AddToggleOption("Require armor for hip placement", RemoveHelmetWithoutArmorVal)
		
		; Remaster options
		OID_SheathWeaponsForAnimation = AddToggleOption("Sheath Weapons to Equip/Unequip", SheathWeaponsForAnimationVal)
		OID_Notify = AddMenuOption("Notify On:", NotifyOptions[CurrentNotify])
		; End Remaster Options
		
		AddHeaderOption("Keybinds")
		OID_ToggleKey = AddKeyMapOption("Toggle equipped:", ToggleKey.GetValueInt(), 0)
		OID_DeleteKey = AddKeyMapOption("Clear placed headgear:", DeleteKey.GetValueInt(), 0)
		OID_EnableKey = AddKeyMapOption("Disables Player Functionality:", EnableKey.GetValueInt(), 0)
		AddEmptyOption()
		AddHeaderOption("Troubleshooting/Uninstall")
		OID_AddPerk = AddTextOption("", "Enable Mod - Player")
		OID_RemovePerk = AddTextOption("", "Disabe Mod - Player")
		OID_DeleteAll = AddTextOption("", "Clear any placed headgear")
	endif
	if page == "Positioning"
		AddHeaderOption("Helmet Hip Position - Male")
		OID_HipPositionX = AddSliderOption("X:", HipPositionX.GetValue(), precision)
		OID_HipPositionY = AddSliderOption("Y:", HipPositionY.GetValue(), precision)
		OID_HipPositionZ = AddSliderOption("Z:", HipPositionZ.GetValue(), precision)
		OID_HipRotationPitch = AddSliderOption("Pitch:", HipRotationPitch.GetValue(), precision)
		OID_HipRotationRoll = AddSliderOption("Roll:", HipRotationRoll.GetValue(), precision)
		OID_HipRotationYaw = AddSliderOption("Yaw:", HipRotationYaw.GetValue(), precision)
		AddEmptyOption()
		AddHeaderOption("Circlet Hip Position - Male")
		OID_HipPositionXCirclet = AddSliderOption("X:", HipPositionXCirclet.GetValue(), precision)
		OID_HipPositionYCirclet = AddSliderOption("Y:", HipPositionYCirclet.GetValue(), precision)
		OID_HipPositionZCirclet = AddSliderOption("Z:", HipPositionZCirclet.GetValue(), precision)
		OID_HipRotationPitchCirclet = AddSliderOption("Pitch:", HipRotationPitchCirclet.GetValue(), precision)
		OID_HipRotationRollCirclet = AddSliderOption("Roll:", HipRotationRollCirclet.GetValue(), precision)
		OID_HipRotationYawCirclet = AddSliderOption("Yaw:", HipRotationYawCirclet.GetValue(), precision)
		AddEmptyOption()
		AddHeaderOption("Helmet Hand Position - Male")
		OID_HandPositionX = AddSliderOption("X:", HandPositionX.GetValue(), precision)
		OID_HandPositionY = AddSliderOption("Y:", HandPositionY.GetValue(), precision)
		OID_HandPositionZ = AddSliderOption("Z:", HandPositionZ.GetValue(), precision)
		OID_HandRotationPitch = AddSliderOption("Pitch:", HandRotationPitch.GetValue(), precision)
		OID_HandRotationRoll = AddSliderOption("Roll:", HandRotationRoll.GetValue(), precision)
		OID_HandRotationYaw = AddSliderOption("Yaw:", HandRotationYaw.GetValue(), precision)
		AddEmptyOption()
		AddHeaderOption("Circlet Hand Position - Male")
		OID_HandPositionXCirclet = AddSliderOption("X:", HandPositionXCirclet.GetValue(), precision)
		OID_HandPositionYCirclet = AddSliderOption("Y:", HandPositionYCirclet.GetValue(), precision)
		OID_HandPositionZCirclet = AddSliderOption("Z:", HandPositionZCirclet.GetValue(), precision)
		OID_HandRotationPitchCirclet = AddSliderOption("Pitch:", HandRotationPitchCirclet.GetValue(), precision)
		OID_HandRotationRollCirclet = AddSliderOption("Roll:", HandRotationRollCirclet.GetValue(), precision)
		OID_HandRotationYawCirclet = AddSliderOption("Yaw:", HandRotationYawCirclet.GetValue(), precision)
		
		AddHeaderOption("Helmet Hip Position - Female")
		OID_HipPositionXFemale = AddSliderOption("X:", HipPositionXFemale.GetValue(), precision)
		OID_HipPositionYFemale = AddSliderOption("Y:", HipPositionYFemale.GetValue(), precision)
		OID_HipPositionZFemale = AddSliderOption("Z:", HipPositionZFemale.GetValue(), precision)
		OID_HipRotationPitchFemale = AddSliderOption("Pitch:", HipRotationPitchFemale.GetValue(), precision)
		OID_HipRotationRollFemale = AddSliderOption("Roll:", HipRotationRollFemale.GetValue(), precision)
		OID_HipRotationYawFemale = AddSliderOption("Yaw:", HipRotationYawFemale.GetValue(), precision)
		AddEmptyOption()
		AddHeaderOption("Circlet Hip Position - Female")
		OID_HipPositionXCircletFemale = AddSliderOption("X:", HipPositionXCircletFemale.GetValue(), precision)
		OID_HipPositionYCircletFemale = AddSliderOption("Y:", HipPositionYCircletFemale.GetValue(), precision)
		OID_HipPositionZCircletFemale = AddSliderOption("Z:", HipPositionZCircletFemale.GetValue(), precision)
		OID_HipRotationPitchCircletFemale = AddSliderOption("Pitch:", HipRotationPitchCircletFemale.GetValue(), precision)
		OID_HipRotationRollCircletFemale = AddSliderOption("Roll:", HipRotationRollCircletFemale.GetValue(), precision)
		OID_HipRotationYawCircletFemale = AddSliderOption("Yaw:", HipRotationYawCircletFemale.GetValue(), precision)
		AddEmptyOption()
		AddHeaderOption("Helmet Hand Position - Female")
		OID_HandPositionXFemale = AddSliderOption("X:", HandPositionXFemale.GetValue(), precision)
		OID_HandPositionYFemale = AddSliderOption("Y:", HandPositionYFemale.GetValue(), precision)
		OID_HandPositionZFemale = AddSliderOption("Z:", HandPositionZFemale.GetValue(), precision)
		OID_HandRotationPitchFemale = AddSliderOption("Pitch:", HandRotationPitchFemale.GetValue(), precision)
		OID_HandRotationRollFemale = AddSliderOption("Roll:", HandRotationRollFemale.GetValue(), precision)
		OID_HandRotationYawFemale = AddSliderOption("Yaw:", HandRotationYawFemale.GetValue(), precision)
		AddEmptyOption()
		AddHeaderOption("Circlet Hand Position - Female")
		OID_HandPositionXCircletFemale = AddSliderOption("X:", HandPositionXCircletFemale.GetValue(), precision)
		OID_HandPositionYCircletFemale = AddSliderOption("Y:", HandPositionYCircletFemale.GetValue(), precision)
		OID_HandPositionZCircletFemale = AddSliderOption("Z:", HandPositionZCircletFemale.GetValue(), precision)
		OID_HandRotationPitchCircletFemale = AddSliderOption("Pitch:", HandRotationPitchCircletFemale.GetValue(), precision)
		OID_HandRotationRollCircletFemale = AddSliderOption("Roll:", HandRotationRollCircletFemale.GetValue(), precision)
		OID_HandRotationYawCircletFemale = AddSliderOption("Yaw:", HandRotationYawCircletFemale.GetValue(), precision)
	endif
EndEvent

Event OnOptionSliderOpen(int a_option)
	if a_option == OID_HipPositionX
		SetSliderDialogStartValue(HipPositionX.GetValue())
		SetSliderDialogDefaultValue(12.8)
		SetSliderDialogRange(-360, 360)
		SetSliderDialogInterval(0.1)
	endif
	if a_option == OID_HipPositionY
		SetSliderDialogStartValue(HipPositionY.GetValue())
		SetSliderDialogDefaultValue(-10.25)
		SetSliderDialogRange(-360, 360)
		SetSliderDialogInterval(0.1)
	endif
	if a_option == OID_HipPositionZ
		SetSliderDialogStartValue(HipPositionZ.GetValue())
		SetSliderDialogDefaultValue(-0.65)
		SetSliderDialogRange(-360, 360)
		SetSliderDialogInterval(0.1)
	endif
	if a_option == OID_HipRotationPitch
		SetSliderDialogStartValue(HipRotationPitch.GetValue())
		SetSliderDialogDefaultValue(-52.9)
		SetSliderDialogRange(-360, 360)
		SetSliderDialogInterval(0.1)
	endif
	if a_option == OID_HipRotationRoll
		SetSliderDialogStartValue(HipRotationRoll.GetValue())
		SetSliderDialogDefaultValue(15.0)
		SetSliderDialogRange(-360, 360)
		SetSliderDialogInterval(0.1)
	endif
	if a_option == OID_HipRotationYaw
		SetSliderDialogStartValue(HipRotationYaw.GetValue())
		SetSliderDialogDefaultValue(94.5)
		SetSliderDialogRange(-360, 360)
		SetSliderDialogInterval(0.1)
	endif
	if a_option == OID_HipPositionXCirclet
		SetSliderDialogStartValue(HipPositionXCirclet.GetValue())
		SetSliderDialogDefaultValue(12.8)
		SetSliderDialogRange(-360, 360)
		SetSliderDialogInterval(0.1)
	endif
	if a_option == OID_HipPositionYCirclet
		SetSliderDialogStartValue(HipPositionYCirclet.GetValue())
		SetSliderDialogDefaultValue(-10.25)
		SetSliderDialogRange(-360, 360)
		SetSliderDialogInterval(0.1)
	endif
	if a_option == OID_HipPositionZCirclet
		SetSliderDialogStartValue(HipPositionZCirclet.GetValue())
		SetSliderDialogDefaultValue(-0.65)
		SetSliderDialogRange(-360, 360)
		SetSliderDialogInterval(0.1)
	endif
	if a_option == OID_HipRotationPitchCirclet
		SetSliderDialogStartValue(HipRotationPitchCirclet.GetValue())
		SetSliderDialogDefaultValue(46.0)
		SetSliderDialogRange(-360, 360)
		SetSliderDialogInterval(0.1)
	endif
	if a_option == OID_HipRotationRollCirclet
		SetSliderDialogStartValue(HipRotationRollCirclet.GetValue())
		SetSliderDialogDefaultValue(15.0)
		SetSliderDialogRange(-360, 360)
		SetSliderDialogInterval(0.1)
	endif
	if a_option == OID_HipRotationYawCirclet
		SetSliderDialogStartValue(HipRotationYawCirclet.GetValue())
		SetSliderDialogDefaultValue(68.9)
		SetSliderDialogRange(-360, 360)
		SetSliderDialogInterval(0.1)
	endif
	
	if a_option == OID_HandPositionX
		SetSliderDialogStartValue(HandPositionX.GetValue())
		SetSliderDialogDefaultValue(6.8)
		SetSliderDialogRange(-360, 360)
		SetSliderDialogInterval(0.1)
	endif
	if a_option == OID_HandPositionY
		SetSliderDialogStartValue(HandPositionY.GetValue())
		SetSliderDialogDefaultValue(-11.75)
		SetSliderDialogRange(-360, 360)
		SetSliderDialogInterval(0.1)
	endif
	if a_option == OID_HandPositionZ
		SetSliderDialogStartValue(HandPositionZ.GetValue())
		SetSliderDialogDefaultValue(-10.85)
		SetSliderDialogRange(-360, 360)
		SetSliderDialogInterval(0.1)
	endif
	if a_option == OID_HandRotationPitch
		SetSliderDialogStartValue(HandRotationPitch.GetValue())
		SetSliderDialogDefaultValue(270.6)
		SetSliderDialogRange(-360, 360)
		SetSliderDialogInterval(0.1)
	endif
	if a_option == OID_HandRotationRoll
		SetSliderDialogStartValue(HandRotationRoll.GetValue())
		SetSliderDialogDefaultValue(0.44)
		SetSliderDialogRange(-360, 360)
		SetSliderDialogInterval(0.1)
	endif
	if a_option == OID_HandRotationYaw
		SetSliderDialogStartValue(HandRotationYaw.GetValue())
		SetSliderDialogDefaultValue(260.45)
		SetSliderDialogRange(-360, 360)
		SetSliderDialogInterval(0.1)
	endif
	if a_option == OID_HandPositionXCirclet
		SetSliderDialogStartValue(HandPositionXCirclet.GetValue())
		SetSliderDialogDefaultValue(-0.2)
		SetSliderDialogRange(-360, 360)
		SetSliderDialogInterval(0.1)
	endif
	if a_option == OID_HandPositionYCirclet
		SetSliderDialogStartValue(HandPositionYCirclet.GetValue())
		SetSliderDialogDefaultValue(-11.25)
		SetSliderDialogRange(-360, 360)
		SetSliderDialogInterval(0.1)
	endif
	if a_option == OID_HandPositionZCirclet
		SetSliderDialogStartValue(HandPositionZCirclet.GetValue())
		SetSliderDialogDefaultValue(10.85)
		SetSliderDialogRange(-360, 360)
		SetSliderDialogInterval(0.1)
	endif
	if a_option == OID_HandRotationPitchCirclet
		SetSliderDialogStartValue(HandRotationPitchCirclet.GetValue())
		SetSliderDialogDefaultValue(270.6)
		SetSliderDialogRange(-360, 360)
		SetSliderDialogInterval(0.1)
	endif
	if a_option == OID_HandRotationRollCirclet
		SetSliderDialogStartValue(HandRotationRollCirclet.GetValue())
		SetSliderDialogDefaultValue(22.94)
		SetSliderDialogRange(-360, 360)
		SetSliderDialogInterval(0.1)
	endif
	if a_option == OID_HandRotationYawCirclet
		SetSliderDialogStartValue(HandRotationYawCirclet.GetValue())
		SetSliderDialogDefaultValue(260.45)
		SetSliderDialogRange(-360, 360)
		SetSliderDialogInterval(0.1)
	endif
	
	if a_option == OID_HipPositionXFemale
		SetSliderDialogStartValue(HipPositionXFemale.GetValue())
		SetSliderDialogDefaultValue(12.8)
		SetSliderDialogRange(-360, 360)
		SetSliderDialogInterval(0.1)
	endif
	if a_option == OID_HipPositionYFemale
		SetSliderDialogStartValue(HipPositionYFemale.GetValue())
		SetSliderDialogDefaultValue(-10.25)
		SetSliderDialogRange(-360, 360)
		SetSliderDialogInterval(0.1)
	endif
	if a_option == OID_HipPositionZFemale
		SetSliderDialogStartValue(HipPositionZFemale.GetValue())
		SetSliderDialogDefaultValue(-0.65)
		SetSliderDialogRange(-360, 360)
		SetSliderDialogInterval(0.1)
	endif
	if a_option == OID_HipRotationPitchFemale
		SetSliderDialogStartValue(HipRotationPitchFemale.GetValue())
		SetSliderDialogDefaultValue(-52.9)
		SetSliderDialogRange(-360, 360)
		SetSliderDialogInterval(0.1)
	endif
	if a_option == OID_HipRotationRollFemale
		SetSliderDialogStartValue(HipRotationRollFemale.GetValue())
		SetSliderDialogDefaultValue(15.0)
		SetSliderDialogRange(-360, 360)
		SetSliderDialogInterval(0.1)
	endif
	if a_option == OID_HipRotationYaw
		SetSliderDialogStartValue(HipRotationYaw.GetValue())
		SetSliderDialogDefaultValue(94.5)
		SetSliderDialogRange(-360, 360)
		SetSliderDialogInterval(0.1)
	endif
	if a_option == OID_HipPositionXCircletFemale
		SetSliderDialogStartValue(HipPositionXCircletFemale.GetValue())
		SetSliderDialogDefaultValue(12.8)
		SetSliderDialogRange(-360, 360)
		SetSliderDialogInterval(0.1)
	endif
	if a_option == OID_HipPositionYCircletFemale
		SetSliderDialogStartValue(HipPositionYCircletFemale.GetValue())
		SetSliderDialogDefaultValue(-10.25)
		SetSliderDialogRange(-360, 360)
		SetSliderDialogInterval(0.1)
	endif
	if a_option == OID_HipPositionZCircletFemale
		SetSliderDialogStartValue(HipPositionZCircletFemale.GetValue())
		SetSliderDialogDefaultValue(-0.65)
		SetSliderDialogRange(-360, 360)
		SetSliderDialogInterval(0.1)
	endif
	if a_option == OID_HipRotationPitchCircletFemale
		SetSliderDialogStartValue(HipRotationPitchCircletFemale.GetValue())
		SetSliderDialogDefaultValue(46.0)
		SetSliderDialogRange(-360, 360)
		SetSliderDialogInterval(0.1)
	endif
	if a_option == OID_HipRotationRollCircletFemale
		SetSliderDialogStartValue(HipRotationRollCircletFemale.GetValue())
		SetSliderDialogDefaultValue(15.0)
		SetSliderDialogRange(-360, 360)
		SetSliderDialogInterval(0.1)
	endif
	if a_option == OID_HipRotationYawCircletFemale
		SetSliderDialogStartValue(HipRotationYawCircletFemale.GetValue())
		SetSliderDialogDefaultValue(68.9)
		SetSliderDialogRange(-360, 360)
		SetSliderDialogInterval(0.1)
	endif
	
	if a_option == OID_HandPositionXFemale
		SetSliderDialogStartValue(HandPositionXFemale.GetValue())
		SetSliderDialogDefaultValue(6.8)
		SetSliderDialogRange(-360, 360)
		SetSliderDialogInterval(0.1)
	endif
	if a_option == OID_HandPositionYFemale
		SetSliderDialogStartValue(HandPositionYFemale.GetValue())
		SetSliderDialogDefaultValue(-11.75)
		SetSliderDialogRange(-360, 360)
		SetSliderDialogInterval(0.1)
	endif
	if a_option == OID_HandPositionZFemale
		SetSliderDialogStartValue(HandPositionZFemale.GetValue())
		SetSliderDialogDefaultValue(-10.85)
		SetSliderDialogRange(-360, 360)
		SetSliderDialogInterval(0.1)
	endif
	if a_option == OID_HandRotationPitchFemale
		SetSliderDialogStartValue(HandRotationPitchFemale.GetValue())
		SetSliderDialogDefaultValue(270.6)
		SetSliderDialogRange(-360, 360)
		SetSliderDialogInterval(0.1)
	endif
	if a_option == OID_HandRotationRollFemale
		SetSliderDialogStartValue(HandRotationRollFemale.GetValue())
		SetSliderDialogDefaultValue(0.44)
		SetSliderDialogRange(-360, 360)
		SetSliderDialogInterval(0.1)
	endif
	if a_option == OID_HandRotationYawFemale
		SetSliderDialogStartValue(HandRotationYawFemale.GetValue())
		SetSliderDialogDefaultValue(260.45)
		SetSliderDialogRange(-360, 360)
		SetSliderDialogInterval(0.1)
	endif
	if a_option == OID_HandPositionXCircletFemale
		SetSliderDialogStartValue(HandPositionXCircletFemale.GetValue())
		SetSliderDialogDefaultValue(-0.2)
		SetSliderDialogRange(-360, 360)
		SetSliderDialogInterval(0.1)
	endif
	if a_option == OID_HandPositionYCircletFemale
		SetSliderDialogStartValue(HandPositionYCircletFemale.GetValue())
		SetSliderDialogDefaultValue(-11.25)
		SetSliderDialogRange(-360, 360)
		SetSliderDialogInterval(0.1)
	endif
	if a_option == OID_HandPositionZCircletFemale
		SetSliderDialogStartValue(HandPositionZCircletFemale.GetValue())
		SetSliderDialogDefaultValue(10.85)
		SetSliderDialogRange(-360, 360)
		SetSliderDialogInterval(0.1)
	endif
	if a_option == OID_HandRotationPitchCircletFemale
		SetSliderDialogStartValue(HandRotationPitchCircletFemale.GetValue())
		SetSliderDialogDefaultValue(270.6)
		SetSliderDialogRange(-360, 360)
		SetSliderDialogInterval(0.1)
	endif
	if a_option == OID_HandRotationRollCircletFemale
		SetSliderDialogStartValue(HandRotationRollCircletFemale.GetValue())
		SetSliderDialogDefaultValue(22.94)
		SetSliderDialogRange(-360, 360)
		SetSliderDialogInterval(0.1)
	endif
	if a_option == OID_HandRotationYawCircletFemale
		SetSliderDialogStartValue(HandRotationYawCircletFemale.GetValue())
		SetSliderDialogDefaultValue(260.45)
		SetSliderDialogRange(-360, 360)
		SetSliderDialogInterval(0.1)
	endif
EndEvent

Event OnOptionSliderAccept(int a_option, float a_value)
	if a_option == OID_HipPositionXCirclet
		HipPositionXCirclet.SetValue(a_value)
		SetSliderOptionValue(a_option, a_value)
	endif
	if a_option == OID_HipPositionYCirclet
		HipPositionYCirclet.SetValue(a_value)
		SetSliderOptionValue(a_option, a_value)
	endif
	if a_option == OID_HipPositionZCirclet
		HipPositionZCirclet.SetValue(a_value)
		SetSliderOptionValue(a_option, a_value)
	endif
	if a_option == OID_HipRotationPitchCirclet
		HipRotationPitchCirclet.SetValue(a_value)
		SetSliderOptionValue(a_option, a_value)
	endif
	if a_option == OID_HipRotationRollCirclet
		HipRotationRollCirclet.SetValue(a_value)
		SetSliderOptionValue(a_option, a_value)
	endif
	if a_option == OID_HipRotationYawCirclet
		HipRotationYawCirclet.SetValue(a_value)
		SetSliderOptionValue(a_option, a_value)
	endif
	if a_option == OID_HipPositionX
		HipPositionX.SetValue(a_value)
		SetSliderOptionValue(a_option, a_value)
	endif
	if a_option == OID_HipPositionY
		HipPositionY.SetValue(a_value)
		SetSliderOptionValue(a_option, a_value)
	endif
	if a_option == OID_HipPositionZ
		HipPositionZ.SetValue(a_value)
		SetSliderOptionValue(a_option, a_value)
	endif
	if a_option == OID_HipRotationPitch
		HipRotationPitch.SetValue(a_value)
		SetSliderOptionValue(a_option, a_value)
	endif
	if a_option == OID_HipRotationRoll
		HipRotationRoll.SetValue(a_value)
		SetSliderOptionValue(a_option, a_value)
	endif
	if a_option == OID_HipRotationYaw
		HipRotationYaw.SetValue(a_value)
		SetSliderOptionValue(a_option, a_value)
	endif
	
	if a_option == OID_HandPositionXCirclet
		HandPositionXCirclet.SetValue(a_value)
		SetSliderOptionValue(a_option, a_value)
	endif
	if a_option == OID_HandPositionYCirclet
		HandPositionYCirclet.SetValue(a_value)
		SetSliderOptionValue(a_option, a_value)
	endif
	if a_option == OID_HandPositionZCirclet
		HandPositionZCirclet.SetValue(a_value)
		SetSliderOptionValue(a_option, a_value)
	endif
	if a_option == OID_HandRotationPitchCirclet
		HandRotationPitchCirclet.SetValue(a_value)
		SetSliderOptionValue(a_option, a_value)
	endif
	if a_option == OID_HandRotationRollCirclet
		HandRotationRollCirclet.SetValue(a_value)
		SetSliderOptionValue(a_option, a_value)
	endif
	if a_option == OID_HandRotationYawCirclet
		HandRotationYawCirclet.SetValue(a_value)
		SetSliderOptionValue(a_option, a_value)
	endif
	if a_option == OID_HandPositionX
		HandPositionX.SetValue(a_value)
		SetSliderOptionValue(a_option, a_value)
	endif
	if a_option == OID_HandPositionY
		HandPositionY.SetValue(a_value)
		SetSliderOptionValue(a_option, a_value)
	endif
	if a_option == OID_HandPositionZ
		HandPositionZ.SetValue(a_value)
		SetSliderOptionValue(a_option, a_value)
	endif
	if a_option == OID_HandRotationPitch
		HandRotationPitch.SetValue(a_value)
		SetSliderOptionValue(a_option, a_value)
	endif
	if a_option == OID_HandRotationRoll
		HandRotationRoll.SetValue(a_value)
		SetSliderOptionValue(a_option, a_value)
	endif
	if a_option == OID_HandRotationYaw
		HandRotationYaw.SetValue(a_value)
		SetSliderOptionValue(a_option, a_value)
	endif
	
	if a_option == OID_HipPositionXCircletFemale
		HipPositionXCircletFemale.SetValue(a_value)
		SetSliderOptionValue(a_option, a_value)
	endif
	if a_option == OID_HipPositionYCircletFemale
		HipPositionYCircletFemale.SetValue(a_value)
		SetSliderOptionValue(a_option, a_value)
	endif
	if a_option == OID_HipPositionZCircletFemale
		HipPositionZCircletFemale.SetValue(a_value)
		SetSliderOptionValue(a_option, a_value)
	endif
	if a_option == OID_HipRotationPitchCircletFemale
		HipRotationPitchCircletFemale.SetValue(a_value)
		SetSliderOptionValue(a_option, a_value)
	endif
	if a_option == OID_HipRotationRollCircletFemale
		HipRotationRollCircletFemale.SetValue(a_value)
		SetSliderOptionValue(a_option, a_value)
	endif
	if a_option == OID_HipRotationYawCircletFemale
		HipRotationYawCircletFemale.SetValue(a_value)
		SetSliderOptionValue(a_option, a_value)
	endif
	if a_option == OID_HipPositionXFemale
		HipPositionXFemale.SetValue(a_value)
		SetSliderOptionValue(a_option, a_value)
	endif
	if a_option == OID_HipPositionYFemale
		HipPositionYFemale.SetValue(a_value)
		SetSliderOptionValue(a_option, a_value)
	endif
	if a_option == OID_HipPositionZFemale
		HipPositionZFemale.SetValue(a_value)
		SetSliderOptionValue(a_option, a_value)
	endif
	if a_option == OID_HipRotationPitchFemale
		HipRotationPitchFemale.SetValue(a_value)
		SetSliderOptionValue(a_option, a_value)
	endif
	if a_option == OID_HipRotationRollFemale
		HipRotationRollFemale.SetValue(a_value)
		SetSliderOptionValue(a_option, a_value)
	endif
	if a_option == OID_HipRotationYawFemale
		HipRotationYawFemale.SetValue(a_value)
		SetSliderOptionValue(a_option, a_value)
	endif
	
	if a_option == OID_HandPositionXCircletFemale
		HandPositionXCircletFemale.SetValue(a_value)
		SetSliderOptionValue(a_option, a_value)
	endif
	if a_option == OID_HandPositionYCircletFemale
		HandPositionYCircletFemale.SetValue(a_value)
		SetSliderOptionValue(a_option, a_value)
	endif
	if a_option == OID_HandPositionZCircletFemale
		HandPositionZCircletFemale.SetValue(a_value)
		SetSliderOptionValue(a_option, a_value)
	endif
	if a_option == OID_HandRotationPitchCircletFemale
		HandRotationPitchCircletFemale.SetValue(a_value)
		SetSliderOptionValue(a_option, a_value)
	endif
	if a_option == OID_HandRotationRollCircletFemale
		HandRotationRollCircletFemale.SetValue(a_value)
		SetSliderOptionValue(a_option, a_value)
	endif
	if a_option == OID_HandRotationYawCircletFemale
		HandRotationYawCircletFemale.SetValue(a_value)
		SetSliderOptionValue(a_option, a_value)
	endif
	if a_option == OID_HandPositionXFemale
		HandPositionXFemale.SetValue(a_value)
		SetSliderOptionValue(a_option, a_value)
	endif
	if a_option == OID_HandPositionYFemale
		HandPositionYFemale.SetValue(a_value)
		SetSliderOptionValue(a_option, a_value)
	endif
	if a_option == OID_HandPositionZFemale
		HandPositionZFemale.SetValue(a_value)
		SetSliderOptionValue(a_option, a_value)
	endif
	if a_option == OID_HandRotationPitchFemale
		HandRotationPitchFemale.SetValue(a_value)
		SetSliderOptionValue(a_option, a_value)
	endif
	if a_option == OID_HandRotationRollFemale
		HandRotationRollFemale.SetValue(a_value)
		SetSliderOptionValue(a_option, a_value)
	endif
	if a_option == OID_HandRotationYawFemale
		HandRotationYawFemale.SetValue(a_value)
		SetSliderOptionValue(a_option, a_value)
	endif
EndEvent

Event OnOptionKeyMapChange(int a_option, int a_keyCode, string a_conflictControl, string a_conflictName)
	if a_option == OID_ToggleKey
		if a_keyCode == 1 || a_keyCode == 271
			SetKeyMapOptionValue(a_option, -1, false)
			ToggleKey.SetValueInt(-1)
		else
			SetKeyMapOptionValue(a_option, a_keyCode, false)
			ToggleKey.SetValueInt(a_keyCode)
		endif
		player = Game.GetPlayer()
		player.removeperk(ReadTheRoomPerk)
		player.addperk(ReadTheRoomPerk)
	endif
	if a_option == OID_DeleteKey
		if a_keyCode == 1 || a_keyCode == 271
			SetKeyMapOptionValue(a_option, -1, false)
			DeleteKey.SetValueInt(-1)
		else
			SetKeyMapOptionValue(a_option, a_keyCode, false)
			DeleteKey.SetValueInt(a_keyCode)
		endif
		player = Game.GetPlayer()
		player.removeperk(ReadTheRoomPerk)
		player.addperk(ReadTheRoomPerk)
	endif
	if a_option == OID_EnableKey
		if a_keyCode == 1 || a_keyCode == 271
			SetKeyMapOptionValue(a_option, -1, false)
			EnableKey.SetValueInt(-1)
		else
			SetKeyMapOptionValue(a_option, a_keyCode, false)
			EnableKey.SetValueInt(a_keyCode)
		endif
		player = Game.GetPlayer()
		player.removeperk(ReadTheRoomPerk)
		player.addperk(ReadTheRoomPerk)
	endif
EndEvent

Event OnOptionMenuOpen(int a_option)
	if a_option ==  OID_EquipWhenSafe
		SetMenuDialogStartIndex(CurrentEquipWhenSafe)
		SetMenuDialogDefaultIndex(0)
		SetMenuDialogOptions(EquipOptions)
	endif
	if a_option ==  OID_UnequipWhenUnsafe
		SetMenuDialogStartIndex(CurrentUnequipWhenUnsafe)
		SetMenuDialogDefaultIndex(0)
		SetMenuDialogOptions(UnequipOptions)
	endif

	; Remaster options
	if a_option == OID_Notify
		SetMenuDialogStartIndex(CurrentNotify)
		SetMenuDialogDefaultIndex(0)
		SetMenuDialogOptions(NotifyOptions)
	endif
EndEvent

Event OnOptionMenuAccept(int a_option, int a_index)
	if a_option ==  OID_EquipWhenSafe
		CurrentEquipWhenSafe = a_index
		SetMenuOptionValue(a_option, EquipOptions[CurrentEquipWhenSafe])
		EquipWhenSafe.SetValueInt(CurrentEquipWhenSafe)
	endif
	if a_option ==  OID_UnequipWhenUnsafe
		CurrentUnequipWhenUnsafe = a_index
		SetMenuOptionValue(a_option, UnequipOptions[CurrentUnequipWhenUnsafe])
		UnequipWhenUnsafe.SetValueInt(CurrentUnequipWhenUnsafe)
	endif

	; Remaster Options
	if a_option ==  OID_Notify
		CurrentNotify = a_index
		SetMenuOptionValue(a_option, NotifyOptions[CurrentNotify])
		if CurrentNotify == 0
			NotifyOnLocation.SetValueInt(1)
			NotifyOnCombat.SetValueInt(1)
		elseif CurrentNotify == 1
			NotifyOnLocation.SetValueInt(1)
			NotifyOnCombat.SetValueInt(0)
		elseif CurrentNotify == 2
			NotifyOnLocation.SetValueInt(0)
			NotifyOnCombat.SetValueInt(1)
		elseif CurrentNotify == 3
			NotifyOnLocation.SetValueInt(0)
			NotifyOnCombat.SetValueInt(0)
		endif
	endif
EndEvent

Event OnOptionSelect(int a_option)
	if a_option == OID_RemovePerk
		player = game.getplayer()
		player.removeperk(ReadTheRoomPerk)
		SetTextOptionValue(a_option, "Perk removed")
	endif
	if a_option == OID_AddPerk
		player = game.getplayer()
		player.addperk(ReadTheRoomPerk)
		SetTextOptionValue(a_option, "Perk added")
	endif
	if a_option == OID_DeleteAll
		DeleteAll(plugin)
		SetTextOptionValue(a_option, "Objects deleted")
	endif
	if a_option == OID_ManageFollowers
		ManageFollowersVal = !ManageFollowersVal
		SetToggleOptionValue(a_option, ManageFollowersVal)
		if ManageFollowers.GetValue() == 1
			ManageFollowers.SetValueInt(0)
		else
			ManageFollowers.SetValueInt(1)
		endif
	endif
	if a_option == OID_CombatEquip
		CombatEquipVal = !CombatEquipVal
		SetToggleOptionValue(a_option, CombatEquipVal)
		if CombatEquip.GetValue() == 1
			CombatEquip.SetValueInt(0)
		else
			CombatEquip.SetValueInt(1)
		endif
	endif
	if a_option == OID_CombatEquipAnimation
		CombatEquipAnimationVal = !CombatEquipAnimationVal
		SetToggleOptionValue(a_option, CombatEquipAnimationVal)
		if CombatEquipAnimation.GetValue() == 1
			CombatEquipAnimation.SetValueInt(0)
		else
			CombatEquipAnimation.SetValueInt(1)
		endif
	endif
	if a_option == OID_ManageCirclets
		ManageCircletsVal = !ManageCircletsVal
		SetToggleOptionValue(a_option, ManageCircletsVal)
		if ManageCirclets.GetValue() == 1
			ManageCirclets.SetValueInt(0)
		else
			ManageCirclets.SetValueInt(1)
		endif
	endif
	if a_option == OID_RemoveHelmetWithoutArmor
		RemoveHelmetWithoutArmorVal = !RemoveHelmetWithoutArmorVal
		SetToggleOptionValue(a_option, RemoveHelmetWithoutArmorVal)
		if RemoveHelmetWithoutArmor.GetValue() == 1
			RemoveHelmetWithoutArmor.SetValueInt(0)
		else
			RemoveHelmetWithoutArmor.SetValueInt(1)
		endif
	endif

	; Remaster Options
	if a_option == OID_SheathWeaponsForAnimation
		SheathWeaponsForAnimationVal = !SheathWeaponsForAnimationVal
		SetToggleOptionValue(a_option, SheathWeaponsForAnimationVal)
		if SheathWeaponsForAnimation.GetValue() == 1
			SheathWeaponsForAnimation.SetValueInt(0)
		else
			SheathWeaponsForAnimation.SetValueInt(1)
		endif
	endif
EndEvent

Event OnOptionHighlight(Int Option)
	if Option == OID_ManageFollowers
		SetInfoText("Toggles whether followers will also have their headgear managed")
	endif
	if Option == OID_EquipWhenSafe
		SetInfoText("Toggles if helmet is equipped when entering an unsafe area or when leaving a safe area")
	endif
	if Option == OID_UnequipWhenUnsafe
		SetInfoText("Toggles if helmet is unequipped when entering a safe area or when leaving an unsafe area")
	endif
	if Option == OID_AddPerk
		SetInfoText("For troubleshooting. Re-adds perk that allows mod functionality")
	endif
	if Option == OID_RemovePerk
		SetInfoText("For troubleshooting/uninstall. Removes perk that allows mod functionality")
	endif
	if Option == OID_CombatEquip
		SetInfoText("Helmet will automatically equip when entering combat")
	endif
	if Option == OID_CombatEquipAnimation
		SetInfoText("Combat equip will use animation - player only")
	endif
	if Option == OID_ManageCirclets
		SetInfoText("Circlets will equip/unequip like helmets - toggle will always work for circlets")
	endif
	if Option == OID_RemoveHelmetWithoutArmor
		SetInfoText("Helmet will only appear on hip if a torso piece is equipped")
	endif

	; Remaster Options
	if Option == OID_SheathWeaponsForAnimation
		SetInfoText("Toggles weapon sheathing for animations. If disabled helmets will be equipped immediately and not animated while weapons are out")
	endif
	if Option == OID_Notify
		SetInfoText("Toggles RTR notifications for location changes and combat")
	endif
EndEvent
