ScriptName ReadTheRoomMonitor extends ActiveMagicEffect

; ReadTheRoomMonitor script
; Monitors the player's location, combat state, 
; key toggles, and other events to trigger Read The Room headgear 
; management for both the player and followers.

Import IED ; Immersive Equipment Display
Import MiscUtil ; PapyrusUtil SE
Import PO3_Events_Alias ; powerofthree's Papyrus Extender

Import ReadTheRoomUtil

; Player reference and script application perk
Actor property PlayerRef auto
Perk property ReadTheRoomPerk auto

; KeyBindings
GlobalVariable property ToggleKey auto
GlobalVariable property DeleteKey auto
GlobalVariable property EnableKey auto

; IED Hip/Hand Anchors
GlobalVariable[] property MaleHandAnchor auto
GlobalVariable[] property MaleHipAnchor auto
GlobalVariable[] property FemaleHandAnchor auto
GlobalVariable[] property FemaleHipAnchor auto

; Equip Scenario Settings
GlobalVariable property CombatEquip auto
GlobalVariable property CombatEquipAnimation auto
GlobalVariable property EquipWhenSafe auto
GlobalVariable property UnequipWhenUnsafe auto
GlobalVariable property RemoveHelmetWithoutArmor auto

; Management Settings
GlobalVariable property ManageCirclets auto
GlobalVariable property ManageFollowers auto
FormList property ManagedFollowers auto

; Location Identification Settings
FormList property SafeKeywords auto
FormList property HostileKeywords auto

; Lowerable Hood Configuration
FormList property LowerableHoods auto
FormList property LoweredHoods auto

; ReadTheRoom dedicated keywords
Keyword property RTR_Follower auto

; Local Script Variables
String MostRecentLocationAction = "None"
String HelmetOnHip = "HelmetOnHip"
String HelmetOnHand = "HelmetOnHand"
String HipNode = "NPC Pelvis [Pelv]"
String HandNode = "NPC R Hand [RHnd]"
Float HipScale = 0.9150
Float HandScale = 1.05

Event OnInit()
	RegisterForKey(ToggleKey.GetValueInt())
	RegisterForKey(DeleteKey.GetValueInt())
	RegisterForKey(EnableKey.GetValueInt())
EndEvent

;;;; Event Handlers ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; OnKeyDown Event Handler
; Processes Key Events for configured keybindings
;
; EnableKey: Read the Room enable/disable
; ToggleKey: Toggle Headgear
; DeleteKey: Force Clear Attachment Nodes
Event OnKeyDown(Int KeyCode)
	; Prevent keypresses from being registered if in menu or text-input mode
	if Utility.IsInMenuMode() || ui.IsTextInputEnabled()
		return
	endif

	; Toggle Read the Room on/off
	if KeyCode == EnableKey.GetValueInt()
		if PlayerRef.hasperk(ReadTheRoomPerk)
			PlayerRef.removeperk(ReadTheRoomPerk)
		else
			PlayerRef.addperk(ReadTheRoomPerk)
		endif
	endif

	; Manually Toggle Head Gear
	if KeyCode == ToggleKey.GetValueInt()
		Form equipped = RTR_GetEquipped(PlayerRef, ManageCirclets.getValueInt() == 1)
		Bool is_valid = RTR_IsValidHeadWear(PlayerRef, equipped, LoweredHoods)

		UpdateManagedFollowersList()
		
		if is_valid
			UnequipActorHeadgear(PlayerRef, equipped)
		else
			Form last_equipped = RTR_GetLastEquipped(PlayerRef)
			EquipActorHeadgear(PlayerRef, last_equipped)
		endif

		; Make Absolutely sure we've cleared our hand node
		RTR_Detatch(PlayerRef, HelmetOnHand)
	endif

	; Force clear attachment nodes
	if KeyCode == DeleteKey.GetValueInt()
		RTR_DetatchAll()
	endif
EndEvent

; OnLocationChange Event Handler
; Updates locational triggers/actions
;
; Records Most Recent Location Action
; Equips/Unequips based off of Config Settings
; @todo Test to see if we need "debounce" logic for when rapidly changing Locations
Event OnLocationChange(Location akOldLoc, Location akNewLoc)
	Form equipped = RTR_GetEquipped(PlayerRef, ManageCirclets.getValueInt() == 1)
	Bool is_valid = RTR_IsValidHeadWear(PlayerRef, equipped, LoweredHoods)
	Bool equip_when_safe = EquipWhenSafe.getValueInt() == 1
	Bool unequip_when_unsafe = UnequipWhenUnsafe.getValueInt() == 1
	
	; Update the MostRecentLocationAction
	MostRecentLocationAction = RTR_GetLocationAction(akNewLoc, is_valid, equip_when_safe, unequip_when_unsafe, SafeKeywords, HostileKeywords)
	UpdateManagedFollowersList()

	if MostRecentLocationAction == "Equip"
		Form last_equipped = RTR_GetLastEquipped(PlayerRef)
		EquipActorHeadgear(PlayerRef, last_equipped)
	elseif MostRecentLocationAction == "Unequip"
		UnequipActorHeadgear(PlayerRef, equipped)
	endif
EndEvent

; OnAnimationEvent Event Handler
; Toggles Headgear based off Players Combat State
Event OnCombatStateChanged(Actor akTarget, int aeCombatState)
	if akTarget == PlayerRef && CombatEquip.GetValueInt() == 1
		if aeCombatState == 1
			; Player entered combat
			Form last_equipped = RTR_GetLastEquipped(PlayerRef)
			EquipActorHeadgear(PlayerRef, last_equipped)
		elseif aeCombatState == 0
			; Player left combat
			if MostRecentLocationAction == "Unequip"
				Form equipped = RTR_GetEquipped(PlayerRef, ManageCirclets.getValueInt() == 1)
				UnequipActorHeadgear(PlayerRef, equipped)
			endif
		endIf
	endIf

	if CombatEquip.GetValueInt() == 1 && aeCombatState == 2
		; Someone is looking for the player
		; @todo Implement
	endif
endEvent

; OnAnimationEvent Event Handler
; Applys IED node attachments and head gear equipping for RTR annotated animations
Event OnAnimationEvent(ObjectReference akSource, string asEventName)
	MiscUtil.PrintConsole("OnAnimationEvent: " + asEventName)
	Actor target_actor = akSource as Actor
	Form last_equipped = RTR_GetLastEquipped(target_actor)

	if !RTR_IsValidHeadWear(target_actor, last_equipped, LoweredHoods)
		MiscUtil.PrintConsole("OnAnimationEvent: Invalid Headwear")
		return ; Exit early if last_equipped isn't a valid Helmet, Hood, or Circlet
	endif

	String last_equipped_type = RTR_InferItemType(last_equipped, LowerableHoods)
	MiscUtil.PrintConsole("OnAnimationEvent: last_equipped_type" + last_equipped_type)
	if last_equipped_type == "None"
		return ; Exit early if we can't infer the item type
	endif

	Bool is_female = target_actor.GetActorBase().GetSex() == 1
	GlobalVariable[] hip_anchor = HipAnchor(is_female)
	GlobalVariable[] hand_anchor = HandAnchor(is_female)

	; Prevent follower re-equip
	Bool prevent_equip = target_actor != PlayerRef

	; Helmet/Circlet
	if asEventName == "PIE.RTR_EQUIP_START"
		RTR_Detatch(target_actor, HelmetOnHip)
		RTR_Attach(target_actor, HelmetOnHand, last_equipped, last_equipped_type, HandScale, HandNode, is_female, hand_anchor)
	elseif asEventName == "PIE.RTR_EQUIP_ATTACH"
		target_actor.EquipItem(last_equipped, false, true)
		RTR_Detatch(target_actor, HelmetOnHand)
	elseif asEventName == "PIE.RTR_EQUIP_END"
		Debug.sendAnimationEvent(target_actor, "OffsetStop")
	endif

	if asEventName == "PIE.RTR_UNEQUIP_START"
		RTR_Attach(target_actor, HelmetOnHand, last_equipped, last_equipped_type, HandScale, HandNode, is_female, hand_anchor)
		target_actor.UnequipItem(last_equipped, prevent_equip, true)
	elseif asEventName == "PIE.RTR_UNEQUIP_ATTACH"
		RTR_Attach(target_actor, HelmetOnHip, last_equipped, last_equipped_type, HipScale, HipNode, is_female, hip_anchor)
		RTR_Detatch(target_actor, HelmetOnHand)
	elseif asEventName == "PIE.RTR_UNEQUIP_END"
		Debug.sendAnimationEvent(target_actor, "OffsetStop")
	endif

	; Lowerable Hoods
	; @todo Should be switched to IED attach/detatch lowered hood Form instead physically eqiupping the item
	if asEventName == "PIE.RTR_HOOD_EQUIP_START"
		if LowerableHoods.HasForm(last_equipped) 
			Form lowered_hood = LoweredHoods.GetAt(LowerableHoods.Find(last_equipped))
			target_actor.UnequipItem(lowered_hood, false, true)
			target_actor.RemoveItem(lowered_hood, 1, true)
		endif
		target_actor.EquipItem(last_equipped, false, true)
	elseif asEventName == "PIE.RTR_HOOD_EQUIP_END"
		Debug.sendAnimationEvent(target_actor, "OffsetStop")
	endif

	if asEventName == "PIE.RTR_HOOD_UNEQUIP_START"
		if LowerableHoods.HasForm(last_equipped)
			Form lowered_hood = LoweredHoods.GetAt(LowerableHoods.Find(last_equipped))
			target_actor.UnequipItem(last_equipped, false, true)
			target_actor.EquipItem(lowered_hood, prevent_equip, true)
		Else
			target_actor.UnequipItem(last_equipped, prevent_equip, true)
		endif
	elseif asEventName == "PIE.RTR_HOOD_UNEQUIP_END"
		Debug.sendAnimationEvent(target_actor, "OffsetStop")
	endif
EndEvent

; OnObjectEquipped Event Handler
; Detatching last equipped head gear from hip and hand
Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
	Actor target_actor = akReference as Actor
	if RTR_IsValidHeadWear(target_actor, akBaseObject, LoweredHoods)
		RTR_Detatch(target_actor, HelmetOnHip)
	endif
	RTR_Detatch(target_actor, HelmetOnHand)
EndEvent

; OnObjectUnequipped Event Handler
Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
	Actor target_actor = akReference as Actor
	if (RemoveHelmetWithoutArmor.GetValueInt() == 1 && !RTR_IsTorsoEquipped(target_actor))
		RTR_DetatchAllActor(target_actor)
	endif
	RTR_Detatch(target_actor, HelmetOnHand)
EndEvent 

; OnRaceSwitchComplete Event Handler
Event OnRaceSwitchComplete()
	RTR_DetatchAllActor(PlayerRef)
EndEvent

;;;; Action functions ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; EquipActorHeadgear
; Triggers equipping head gear to an actor
; 
; @param Actor target_actor
; @param Form last_equipped
Function EquipActorHeadgear(Actor target_actor, Form last_equipped)
	if target_actor.GetAnimationVariableInt("RTR_Active") == 1
		MiscUtil.PrintConsole("EquipActorHeadgear: RTR_Active")
		return
	endif

	; Exit early if the actor is already wearing the item
	if target_actor.IsEquipped(last_equipped)
		RTR_DetatchAllActor(target_actor)
		return
	endif

	; Combat State Unequip
	if target_actor.GetCombatState() == 1
		if CombatEquip.GetValueInt() == 0
			return
		endif

		; Equip with no animation
		if CombatEquipAnimation.getValueInt() == 0
			EquipWithNoAnimation(target_actor, last_equipped)
			return
		endif
	endif

	; Check Actor status for any conditions that would prevent animation
	if target_actor.GetSitState() || \
		target_actor.IsSwimming() || \
		target_actor.GetAnimationVariableInt("bInJumpState") == 1 || \
		target_actor.GetAnimationVariableInt("IsEquipping") == 1 || \
		target_actor.GetAnimationVariableInt("IsUnequipping") == 1
		
		; Force equip with no animation
		EquipWithNoAnimation(target_actor, last_equipped)
		return
	endif

	; Animated Equip
	RegisterForAnnotationEvents(target_actor)
	String animation = "RTREquip"
	Float animation_time = 3.3

	; Switch animation if equipping a lowerable hood
	if LowerableHoods.hasForm(last_equipped)
		animation = "RTREquipHood"
		animation_time = 1.0
	endif

	Bool was_drawn = RTR_SheathWeapon(target_actor)
	Bool was_first_person = RTR_ForceThirdPerson(target_actor)

	RTR_PlayAnimation(target_actor, target_actor == PlayerRef, animation, animation_time, was_drawn, was_first_person)

	; Check attachment node accuracy...
	; Just in case the animation was interrupted
	RTR_Detatch(target_actor, HelmetOnHand)
	if RTR_IsAttached(target_actor, HelmetOnHip, target_actor.GetActorBase().getSex())
		EquipWithNoAnimation(target_actor, last_equipped)
	endif

	; [Experimental] Will not do anything unless follower support is enabled
	EquipFollowerHeadgear()
EndFunction

; EquipWithNoAnimation
; Equips an item to an actor without playing an animation
;
; @param Actor target_actor
; @param Form last_equipped
Function EquipWithNoAnimation(Actor target_actor, Form last_equipped)
	String last_equipped_type = RTR_InferItemType(last_equipped, LowerableHoods)

	if last_equipped_type == "Hood"
		Form lowered_hood = LoweredHoods.GetAt(LowerableHoods.Find(last_equipped))
		target_actor.UnequipItem(lowered_hood, false, true)
		target_actor.EquipItem(last_equipped, false, true)
	else
		target_actor.EquipItem(last_equipped, false, true)
		RTR_DetatchAllActor(target_actor)
	endif
endFunction

; UnequipActorHeadgear
; Triggers unequipping head gear from an actor
;
; @param Actor target_actor
; @param Form equipped
Function UnequipActorHeadgear(Actor target_actor, Form equipped)
	if target_actor.GetAnimationVariableInt("RTR_Active") == 1
		MiscUtil.PrintConsole("UnequipActorHeadgear: RTR_Active")
		return
	endif

	; Exit early if the actor is not wearing the item
	if !target_actor.IsEquipped(equipped)
		RTR_Detatch(target_actor, HelmetOnHand)
		return
	endif

	; Combat State Unequip
	if target_actor.GetCombatState() == 1
		if CombatEquip.GetValueInt() == 0
			return
		endif

		; Unequip with no animation
		if CombatEquipAnimation.getValueInt() == 0
			UnequipWithNoAnimation(target_actor, equipped)
			return
		endif
	endif

	; Check Actor status for any conditions that would prevent animation
	if target_actor.GetSitState() || \
		target_actor.IsSwimming() || \
		target_actor.GetAnimationVariableInt("bInJumpState") == 1 || \
		target_actor.GetAnimationVariableInt("IsEquipping") == 1 || \
		target_actor.GetAnimationVariableInt("IsUnequipping") == 1
		
		; Force unequip with no animation
		UnequipWithNoAnimation(target_actor, equipped)
		return
	endif

	; Animated Unequip
	RegisterForAnnotationEvents(target_actor)
	String animation = "RTRUnequip"
	Float animation_time = 3.25

	; Switch animation if equipping a lowerable hood
	if LowerableHoods.hasForm(equipped)
		animation = "RTRHoodUnequip"
		animation_time = 1.0
	endif

	Bool was_drawn = RTR_SheathWeapon(target_actor)
	Bool was_first_person = RTR_ForceThirdPerson(target_actor)

	RTR_PlayAnimation(target_actor, target_actor == PlayerRef, animation, animation_time, was_drawn, was_first_person)

	; Check attachment node accuracy...
	; Just in case the animation was interrupted
	RTR_Detatch(target_actor, HelmetOnHand)
	if !RTR_IsAttached(target_actor, HelmetOnHip, target_actor.GetActorBase().getSex())
		UnequipWithNoAnimation(target_actor, equipped)
	endif

	; [Experimental] Will not do anything unless follower support is enabled
	UnequipFollowerHeadgear()
EndFunction

; UnequipWithNoAnimation
; Unequips an item from an actor without playing an animation
;
; @param Actor target_actor
; @param Form equipped
Function UnequipWithNoAnimation(Actor target_actor, Form equipped)
	; Prevent follower re-equip
	Bool prevent_equip = target_actor != PlayerRef
	String equipped_type = RTR_InferItemType(equipped, LowerableHoods)

	if equipped_type == "Hood"
		Form lowered_hood = LoweredHoods.GetAt(LowerableHoods.Find(equipped))
		target_actor.UnequipItem(equipped, false, true)
		target_actor.EquipItem(lowered_hood, prevent_equip, true)
	else
		String last_equipped_type = RTR_InferItemType(equipped, LowerableHoods)
		Bool is_female = target_actor.GetActorBase().getSex() == 1
		GlobalVariable[] hip_anchor = HipAnchor(is_female)
		
		target_actor.UnequipItem(equipped, prevent_equip, true)
		RTR_Detatch(target_actor, HelmetOnHand)
		RTR_Attach(target_actor, HelmetOnHip, equipped, last_equipped_type, HipScale, HipNode, is_female, hip_anchor)
	endif
endFunction

;;;; Local Script Helper Functions ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; RegisterForAnnotationEvents
; Register To Animation Events for RTR annotations
; Annotations trigger IED node attachment and Gear Equipping/Unequipping at specific points during the animation
;
; @param Actor target_actor
function RegisterForAnnotationEvents(Actor target_actor)
	RegisterForAnimationEvent(target_actor, "PIE.@SGVI|RTR_Active|1")

	RegisterForAnimationEvent(target_actor, "PIE.RTR_EQUIP_START")
	RegisterForAnimationEvent(target_actor, "PIE.RTR_EQUIP_ATTACH")
	RegisterForAnimationEvent(target_actor, "PIE.RTR_EQUIP_END")

	RegisterForAnimationEvent(target_actor, "PIE.RTR_HOOD_EQUIP_START")
	RegisterForAnimationEvent(target_actor, "PIE.RTR_HOOD_EQUIP_END")

	RegisterForAnimationEvent(target_actor, "PIE.RTR_UNEQUIP_START")
	RegisterForAnimationEvent(target_actor, "PIE.RTR_UNEQUIP_ATTACH")
	RegisterForAnimationEvent(target_actor, "PIE.RTR_UNEQUIP_END")

	RegisterForAnimationEvent(target_actor, "PIE.RTR_HOOD_UNEQUIP_START")
	RegisterForAnimationEvent(target_actor, "PIE.RTR_HOOD_UNEQUIP_END")
endFunction

; RegisterManagedFollowers
; Registers followers for management that are close to the player
; In the current cell
function UpdateManagedFollowersList()
	if ManageFollowers.GetValueInt() == 0
		return
	endif

	; ManagedFollowers
	Actor[] found_followers = ScanCellNPCs(PlayerRef, 500.0, RTR_Follower)
	
	int i = 0
	int managedFollowerCount = ManagedFollowers.GetSize()
	while (i < managedFollowerCount)
		Actor followerActor = ManagedFollowers.GetAt(i) as Actor
		ManagedFollowers.AddForm(followerActor)
		; @DEBUG Output Current Managed Followers
		string followerActorName = followerActor.GetActorBase().GetName()
		Debug.Notification("RTR Detected Follower: " + followerActorName)
		i += 1
	endwhile
endFunction

function UnequipFollowerHeadgear()
	if ManageFollowers.GetValueInt() == 0
		return
	endif

	int i = 0
	int managedFollowerCount = ManagedFollowers.GetSize()
	while (i < managedFollowerCount)
		Actor follower = ManagedFollowers.GetAt(i) as Actor
		Form equipped = RTR_GetEquipped(follower, ManageCirclets.getValueInt() == 1)
		Bool is_valid = RTR_IsValidHeadWear(follower, equipped, LoweredHoods)
		
		if is_valid
			UnequipActorHeadgear(follower, equipped)
		endif

		; Make Absolutely sure their hand nodes are clear
		RTR_Detatch(follower, HelmetOnHand)
		i += 1 ; NEXT
	endwhile
endFunction

function EquipFollowerHeadgear()
	if ManageFollowers.GetValueInt() == 0
		return
	endif
	
	int i = 0
	int managedFollowerCount = ManagedFollowers.GetSize()
	while (i < managedFollowerCount)
		Actor follower = ManagedFollowers.GetAt(i) as Actor
		Form last_equipped = RTR_GetLastEquipped(follower)
		Bool is_valid = RTR_IsValidHeadWear(follower, last_equipped, LoweredHoods)
		
		if is_valid
			EquipActorHeadgear(follower, last_equipped)
		endif

		; Make Absolutely sure their hand nodes are clear
		RTR_Detatch(follower, HelmetOnHand)
		i += 1 ; NEXT
	endwhile
endFunction

; HipAnchor
; Returns the correct hip anchor for the actor's gender
;
; @param Bool is_female
; @return GlobalVariable[12]
GlobalVariable[] function HipAnchor(Bool is_female)
	if is_female 
		return FemaleHipAnchor
	endif
	return MaleHipAnchor
endFunction

; HandAnchor
; Returns the correct hand anchor for the actor's gender
;
; @param Bool is_female
; @return GlobalVariable[12]
GlobalVariable[] function HandAnchor(Bool is_female)
	if is_female 
		return FemaleHandAnchor
	endif
	return MaleHandAnchor
endFunction
