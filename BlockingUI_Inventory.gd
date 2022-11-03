extends "res://BlockingUI.gd"

onready var UpgradesHeader = $HSplitContainer/UpgradeGrid/UpgradesHeader
onready var Anchor = $HSplitContainer/UpgradeGrid/Anchor
onready var FlamingSkull = $HSplitContainer/UpgradeGrid/FlamingSkull
onready var Cargo = $HSplitContainer/UpgradeGrid/Cargo
onready var Cannon = $HSplitContainer/UpgradeGrid/Cannon
onready var Compass = $HSplitContainer/UpgradeGrid/Compass
onready var BigHook = $HSplitContainer/UpgradeGrid/BigHook
onready var Detector = $HSplitContainer/UpgradeGrid/Detector
onready var Eye = $HSplitContainer/UpgradeGrid/Eye

onready var ChumUncommon = $HSplitContainer/SuppliesGrid/ChumUncommon
onready var OrbUncommon = $HSplitContainer/SuppliesGrid/OrbUncommon
onready var Narcolepsy = $HSplitContainer/SuppliesGrid/Narcolepsy
onready var Willpower = $HSplitContainer/SuppliesGrid/Willpower
onready var ChumRare = $HSplitContainer/SuppliesGrid/ChumRare
onready var OrbRare = $HSplitContainer/SuppliesGrid/OrbRare
onready var LineRare = $HSplitContainer/SuppliesGrid/LineRare
onready var Crown = $HSplitContainer/SuppliesGrid/Crown
onready var ChumMythic = $HSplitContainer/SuppliesGrid/ChumMythic
onready var OrbMythic = $HSplitContainer/SuppliesGrid/OrbMythic
onready var LineMythic = $HSplitContainer/SuppliesGrid/LineMythic
onready var SuppliesHeader = $HSplitContainer/SuppliesGrid/SuppliesHeader

onready var ItemName = $ItemName
onready var Description = $Description
onready var CargoWeight = $CargoWeight

var highlighted = null
var gridMap = {} #populate on ready

func _ready():
	ItemName.text = ''
	Description.text = ''
	UpdateCargoText()
	PopulateGridMap()
	EvaluateItems()
	HighlightFirstItem()

func UpdateCargoText():
	var output = 'Cargohold: %.1fkg' % P.GetCargoWeight()
	if P.IsCargoFull():
		output = "%s (FULL!)" % output
	CargoWeight.text = output
	
func PopulateGridMap():
	gridMap = {
		Vector2(0, 0) : UpgradesHeader,
		Vector2(1, 0) : Anchor,
		Vector2(2, 0) : FlamingSkull,
		Vector2(3, 0) : ChumUncommon,
		Vector2(4, 0) : OrbUncommon,
		Vector2(5, 0) : Narcolepsy,
		Vector2(6, 0) : Willpower,
		Vector2(0, 1) : Cargo,
		Vector2(1, 1) : Cannon,
		Vector2(2, 1) : Compass,
		Vector2(3, 1) : ChumRare,
		Vector2(4, 1) : OrbRare,
		Vector2(5, 1) : LineRare,
		Vector2(6, 1) : Crown,
		Vector2(0, 2) : BigHook,
		Vector2(1, 2) : Detector,
		Vector2(2, 2) : Eye,
		Vector2(3, 2) : ChumMythic,
		Vector2(4, 2) : OrbMythic,
		Vector2(5, 2) : LineMythic,
		Vector2(6, 2) : SuppliesHeader,
	}

func _unhandled_input(event):
	if I.is_event_action(event, "pause") and I.is_action_just_pressed("pause"):
		get_tree().set_input_as_handled()
		Audio.PlaySFX(Audio.SFX.UI_BACK)
		Events.emit_signal("blocking_ui_exit")
	
	elif I.is_event_action(event, "item_left") and I.is_action_just_pressed("item_left"):
		get_tree().set_input_as_handled()
		Navigate(-1, 0)
	elif I.is_event_action(event, "item_right") and I.is_action_just_pressed("item_right"):
		get_tree().set_input_as_handled()
		Navigate(1, 0)
	elif I.is_event_action(event, "item_up") and I.is_action_just_pressed("item_up"):
		get_tree().set_input_as_handled()
		Navigate(0, -1)
	elif I.is_event_action(event, "item_down") and I.is_action_just_pressed("item_down"):
		get_tree().set_input_as_handled()
		Navigate(0, 1)

func Navigate(h, v):
	if highlighted == null:
		return
	
	var startPos = highlighted.gridPos
	var newPos = startPos
	var newPosFound = false
	while !newPosFound:
		if h != 0:
			newPos.x = wrapi(newPos.x+h, 0, 7)
		else:
			newPos.y = wrapi(newPos.y+v, 0, 3)
			if gridMap[newPos].highlightable:
				newPosFound = true
			var newNewPos = newPos
			while !newPosFound:
				newPos.x = wrapi(newPos.x+1, 0, 7)
				if newPos == newNewPos:
					break
				if gridMap[newPos].highlightable:
					newPosFound = true
		if newPos == startPos:
			return
		var newItem = gridMap[newPos]
		if newItem.highlightable:
			Audio.PlaySFX(Audio.SFX.UI_SCROLL)
			UpdateHightedItem(newItem)
			newPosFound = true

func EvaluateItems():
	Anchor.SetHighlightableInventory(P.upgrades[G.Upgrades.ANCHOR], 0)
	FlamingSkull.SetHighlightableInventory(P.upgrades[G.Upgrades.FLAMINGSKULL], 0)
	Cargo.SetHighlightableInventory(P.upgrades[G.Upgrades.CARGO], 0)
	Cannon.SetHighlightableInventory(P.upgrades[G.Upgrades.CANNON], 0)
	Compass.SetHighlightableInventory(P.upgrades[G.Upgrades.COMPASS], 0)
	BigHook.SetHighlightableInventory(P.upgrades[G.Upgrades.BIGHOOK], 0)
	Detector.SetHighlightableInventory(P.upgrades[G.Upgrades.DETECTOR], 0)
	Eye.SetHighlightableInventory(P.upgrades[G.Upgrades.EYE], 0)
	ChumUncommon.SetHighlightableInventory(P.supplies[G.Supplies.CHUM_UNCOMMON] > 0, P.supplies[G.Supplies.CHUM_UNCOMMON])
	OrbUncommon.SetHighlightableInventory(P.supplies[G.Supplies.ORB_UNCOMMON] > 0, P.supplies[G.Supplies.ORB_UNCOMMON])
	Narcolepsy.SetHighlightableInventory(P.supplies[G.Supplies.NARCOLEPSY] > 0, P.supplies[G.Supplies.NARCOLEPSY])
	Willpower.SetHighlightableInventory(P.supplies[G.Supplies.WILLPOWER] > 0, P.supplies[G.Supplies.WILLPOWER])
	ChumRare.SetHighlightableInventory(P.supplies[G.Supplies.CHUM_RARE] > 0, P.supplies[G.Supplies.CHUM_RARE])
	OrbRare.SetHighlightableInventory(P.supplies[G.Supplies.ORB_RARE] > 0, P.supplies[G.Supplies.ORB_RARE] > 0)
	LineRare.SetHighlightableInventory(P.supplies[G.Supplies.LINE_RARE] > 0, P.supplies[G.Supplies.LINE_RARE])
	Crown.SetHighlightableInventory(P.supplies[G.Supplies.CROWN] > 0, P.supplies[G.Supplies.CROWN])
	ChumMythic.SetHighlightableInventory(P.supplies[G.Supplies.CHUM_MYTHIC] > 0, P.supplies[G.Supplies.CHUM_MYTHIC])
	OrbMythic.SetHighlightableInventory(P.supplies[G.Supplies.ORB_MYTHIC] > 0, P.supplies[G.Supplies.ORB_MYTHIC])
	LineMythic.SetHighlightableInventory(P.supplies[G.Supplies.LINE_MYTHIC] > 0, P.supplies[G.Supplies.LINE_MYTHIC])

func HighlightFirstItem():
	if P.upgrades[G.Upgrades.ANCHOR]:
		UpdateHightedItem(Anchor)
	elif P.upgrades[G.Upgrades.FLAMINGSKULL]:
		UpdateHightedItem(FlamingSkull)
	elif P.supplies[G.Supplies.CHUM_UNCOMMON] > 0:
		UpdateHightedItem(ChumUncommon)
	elif P.supplies[G.Supplies.ORB_UNCOMMON] > 0:
		UpdateHightedItem(OrbUncommon)
	elif P.supplies[G.Supplies.NARCOLEPSY] > 0:
		UpdateHightedItem(Narcolepsy)
	elif P.supplies[G.Supplies.WILLPOWER] > 0:
		UpdateHightedItem(Willpower)
	elif P.supplies[G.Supplies.CHUM_RARE] > 0:
		UpdateHightedItem(ChumRare)
	elif P.supplies[G.Supplies.ORB_RARE] > 0:
		UpdateHightedItem(OrbRare)
	elif P.supplies[G.Supplies.LINE_RARE] > 0:
		UpdateHightedItem(LineRare)
	elif P.supplies[G.Supplies.CROWN] > 0:
		UpdateHightedItem(Crown)
	elif P.supplies[G.Supplies.CHUM_MYTHIC] > 0:
		UpdateHightedItem(ChumMythic)
	elif P.supplies[G.Supplies.ORB_MYTHIC] > 0:
		UpdateHightedItem(OrbMythic)
	elif P.supplies[G.Supplies.LINE_MYTHIC] > 0:
		UpdateHightedItem(LineMythic)

func UpdateHightedItem(item):
	if item == null:
		return
	highlighted = item
	if item.suppliesType:
		ItemName.text = G.SuppliesNameMap[highlighted.itemEnum]
	else:
		ItemName.text = G.UpgradesNameMap[highlighted.itemEnum]
	Description.text = highlighted.Highlight()
