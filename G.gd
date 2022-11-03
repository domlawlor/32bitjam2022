extends Node

var AUDIO_ENABLED = true

func _ready():
	randomize()
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), -6)

enum BlockingUITypes {
	INVENTORY
	LOGBOOK
	SELECT_SUPPLIES
	CHEST_REWARD
	FISH_SELL
}
var BlockingScreen_Inventory = preload("res://BlockingUI_Inventory.tscn")
var BlockingScreen_Logbook = preload("res://BlockingUI_Logbook.tscn")
var BlockingScreen_SelectSupplies = preload("res://BlockingUI_SelectSupplies.tscn")
var BlockingScreen_ChestReward = preload("res://BlockingUI_ChestReward.tscn")
var BlockingScreen_FishSell = preload("res://BlockingUI_FishSell.tscn")

# Godot uses UP LEFT RIGHT ect, bit confusing. This helps
const X_AXIS = Vector3(1,0,0)
const Y_AXIS = Vector3(0,1,0)
const Z_AXIS = Vector3(0,0,1)

const LOGICAL_RES = Vector2(320, 240)
var SCALE = 1

enum Screens {
	GAMEPLAY
	TITLE
	SHOP
}
var activeScreen = Screens.TITLE
var transitionActive = false
var shopEntryInputActive = true

func ResetGameplay():
	Events.emit_signal("reset_boat")

var progression = 0
func MakeProgress():
	progression += 1
	assert(progression <= 3)
	Events.emit_signal("progress_made", progression)

enum FishRarity { #also exists in FishClass, still thinking of a nicer solution
	COMMON
	UNCOMMON
	RARE
	MYTHIC
}

enum Upgrades {
	ANCHOR = 0
	FLAMINGSKULL = 1
	CARGO = 2
	CANNON = 3
	COMPASS = 4
	BIGHOOK = 5
	DETECTOR = 6
	EYE = 7
}

var UpgradesNameMap = {
	Upgrades.ANCHOR : "Heavy Anchor",
	Upgrades.FLAMINGSKULL : "Flaming Skull",
	Upgrades.CARGO : "Extra Cargo",
	Upgrades.CANNON : "Construction Cannon",
	Upgrades.COMPASS : "Compass of Greed",
	Upgrades.BIGHOOK : "Mega Hook",
	Upgrades.DETECTOR : "Pendant",
	Upgrades.EYE : "All-Seeing Eye",
}

enum Supplies {
	CHUM_UNCOMMON = 0
	ORB_UNCOMMON = 1
	NARCOLEPSY = 2
	WILLPOWER = 3
	CHUM_RARE = 4
	ORB_RARE = 5
	LINE_RARE = 6
	CROWN = 7
	CHUM_MYTHIC = 8
	ORB_MYTHIC = 9
	LINE_MYTHIC = 10
}

var SuppliesNameMap = {
	Supplies.CHUM_UNCOMMON : "Sacrificial Chum",
	Supplies.ORB_UNCOMMON : "Orb of Draining",
	Supplies.NARCOLEPSY : "Potion of Narcolepsy",
	Supplies.WILLPOWER : "Bottle of Willpower",
	Supplies.CHUM_RARE : "Vile Sacrifical Chum",
	Supplies.ORB_RARE : "Strong Orb of Draining",
	Supplies.LINE_RARE : "Strong Fishing Line",
	Supplies.CROWN : "Royal Skull",
	Supplies.CHUM_MYTHIC : "Putrid Sacrificial Chum",
	Supplies.ORB_MYTHIC : "Powerful Orb of Draining",
	Supplies.LINE_MYTHIC : "Impervious Fishing Line",
}

enum FishingZone {
	COMMON
	UNCOMMON
	RARE
	MYTHIC_QUEST
}
var activeFishingZone = FishingZone.COMMON

# Helper Functions
func NormalizeLerp(start, end, current):
	var totalTime = abs(start - end)
	var unscaledProgress
	if start > end:
		unscaledProgress = current - end
	else:
		unscaledProgress = current - start
	return unscaledProgress / totalTime
	
var debugActive := false


enum BoatState {
	FROZEN = 0,
	CRUISING,
	WAITING_FOR_SUPPLIES_SELECT,
	CRUISING_TO_FISHING,
	FISHING,
	CAUGHT_FISH,
	FISHING_TO_CRUISING,
	CAPSIZING
	CAPSIZED,
}

enum FishingState {
	NOT_FISHING = 0,
	WAITING_FOR_FISH,
	PRE_HOOK_QTE,
	FISH_ON_HOOK,
}

enum QTE_Button {
	NONE = 0
	CROSS = 1,
	CIRCLE = 2,
	SQUARE = 3,
	TRIANGLE = 4,
}

enum PreHookTiming {
	MISSED = 0,
	POOR,
	OKAY,
	GOOD,
	PERFECT
}

var rarietyToQTEButtons = {
	FishRarity.COMMON : [QTE_Button.CROSS, QTE_Button.CIRCLE],
	FishRarity.UNCOMMON : [QTE_Button.CROSS, QTE_Button.CIRCLE, QTE_Button.SQUARE],
	FishRarity.RARE : [QTE_Button.CROSS, QTE_Button.CIRCLE, QTE_Button.SQUARE, QTE_Button.TRIANGLE],
	FishRarity.MYTHIC : [QTE_Button.CROSS, QTE_Button.CIRCLE, QTE_Button.SQUARE, QTE_Button.TRIANGLE],
}

func CentreGameWindow():
	OS.set_window_position(
			OS.get_screen_position(OS.get_current_screen()) + 
			OS.get_screen_size()*0.5 - OS.get_window_size()*0.5)
