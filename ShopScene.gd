extends Spatial

onready var CameraNavigation = $CameraNavigation
onready var CameraUpgrades = $CameraUpgrades
onready var CameraShopkeeper = $CameraShopkeeper
onready var CameraSupplies = $CameraSupplies
onready var NavigationIcon = $"2D/NavigationIcon"
onready var SpeechAlert = $"2D/SpeechAlert"

onready var ShopKeeperSection = $"2D/ShopKeeperSection"
onready var UpgradesSection = $"2D/UpgradesSection"
onready var SuppliesSection = $"2D/SuppliesSection"

enum Section {
	SHOPKEEPER
	SUPPLIES
	UPGRADES
	NAVIGATION
}
var sectionMap = {}
var sectionCameraMap = {}

var activeSection = Section.NAVIGATION
var highlightedSection = Section.SHOPKEEPER
var capsized = false

func _ready():
	Events.connect("activate_screen", self, "_on_activate_screen")
	Events.connect("activate_camera", self, "_on_activate_camera")
	Events.connect("capsize_triggered", self, "_on_capsize_triggered")
	
	PopulateSectionMap()
	Input_Navigation(0)

func _exit():
	Events.disconnect("activate_screen", self, "_on_activate_screen")
	Events.disconnect("activate_camera", self, "_on_activate_camera")
	Events.disconnect("capsize_triggered", self, "_on_capsize_triggered")

func PopulateSectionMap():
	sectionMap = {
		Section.SHOPKEEPER : ShopKeeperSection,
		Section.UPGRADES : UpgradesSection,
		Section.SUPPLIES : SuppliesSection,
	}
	sectionCameraMap = {
		Section.SHOPKEEPER : CameraShopkeeper,
		Section.UPGRADES : CameraUpgrades,
		Section.SUPPLIES : CameraSupplies,
	}

func _unhandled_input(event):
	if G.transitionActive or G.activeScreen != G.Screens.SHOP:
		return
	
	if activeSection == Section.NAVIGATION:
		if I.is_event_action(event, "exit_shop") and I.is_action_just_pressed("exit_shop"):
			get_tree().set_input_as_handled()
			Audio.PlaySFX(Audio.SFX.UI_BACK)
			Events.emit_signal("spawn_chest")
			var FADETIME = 0.5
			Events.emit_signal("transition", G, G.Screens.GAMEPLAY, 'ResetGameplay', '', FADETIME, FADETIME)
		elif I.is_event_action(event, "item_left") and I.is_action_just_pressed("item_left"):
			get_tree().set_input_as_handled()
			Input_Navigation(-1)
			Audio.PlaySFX(Audio.SFX.UI_SCROLLSWOOSH)
		elif I.is_event_action(event, "item_right") and I.is_action_just_pressed("item_right"):
			get_tree().set_input_as_handled()
			Input_Navigation(1)
			Audio.PlaySFX(Audio.SFX.UI_SCROLLSWOOSH)
		elif I.is_event_action(event, "shopsection_select") and I.is_action_just_pressed("shopsection_select"):
			get_tree().set_input_as_handled()
			ActivateShopSection(highlightedSection)
			Audio.PlaySFX(Audio.SFX.UI_SELECT)
	else:
		if I.is_event_action(event, "exit_shop") and I.is_action_just_pressed("exit_shop"):
			get_tree().set_input_as_handled()
			CameraNavigation.make_current()
			var section = sectionMap[activeSection]
			section.visible = false
			section.active = false
			NavigationIcon.visible = true
			SpeechAlert.visible = ShopKeeperSection.IsNewSpeech()
			activeSection = Section.NAVIGATION
			Audio.PlaySFX(Audio.SFX.UI_BACK)

func Input_Navigation(val):
	highlightedSection = wrapi(highlightedSection+val, 0, 3)
	NavigationIcon.position = sectionMap[highlightedSection].GetCursorPos()

func ActivateShopSection(highlightedSection):
	activeSection = highlightedSection
	sectionCameraMap[activeSection].make_current()
	var section = sectionMap[activeSection]
	if activeSection == Section.SHOPKEEPER:
		section.SetSpeech()
	else:
		section.EvaluateItems()
		section.HighlightFirstItem()
	
	section.active = true
	section.visible = true
	NavigationIcon.visible = false
	SpeechAlert.visible = false

func _on_activate_screen(screenKey):
	if screenKey == G.Screens.SHOP:
		SpeechAlert.visible = ShopKeeperSection.IsNewSpeech()
		P.PrintCargo()
		if self.capsized:
			P.ClearCargo()
			print("your cargo was lost!")
			self.capsized = false
	
func _on_activate_camera(screenKey):
	if screenKey == G.Screens.SHOP:
		CameraNavigation.make_current()

func _on_capsize_triggered():
	self.capsized = true
