extends Control

onready var CursorPos = $CursorPos

onready var UpgradesHeader = $UpgradeGrid/UpgradesHeader
onready var Anchor = $UpgradeGrid/Anchor
onready var FlamingSkull = $UpgradeGrid/FlamingSkull
onready var Cargo = $UpgradeGrid/Cargo
onready var Cannon = $UpgradeGrid/Cannon
onready var Compass = $UpgradeGrid/Compass
onready var BigHook = $UpgradeGrid/BigHook
onready var Detector = $UpgradeGrid/Detector
onready var Eye = $UpgradeGrid/Eye

onready var ItemName = $ItemName
onready var Description = $Description

var active = false

func GetCursorPos():
	return CursorPos.position

var highlighted = null
var gridMap = {} #populate on ready

func _ready():
	PopulateGridMap()

func PopulateGridMap():
	gridMap = {
		Vector2(0, 0) : UpgradesHeader,
		Vector2(1, 0) : Anchor,
		Vector2(2, 0) : FlamingSkull,
		Vector2(0, 1) : Cargo,
		Vector2(1, 1) : Cannon,
		Vector2(2, 1) : Compass,
		Vector2(0, 2) : BigHook,
		Vector2(1, 2) : Detector,
		Vector2(2, 2) : Eye,
	}

func _unhandled_input(event):
	if !active:
		return
	
	if I.is_event_action(event, "item_left") and I.is_action_just_pressed("item_left"):
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
	elif I.is_event_action(event, "purchase_item") and I.is_action_just_pressed("purchase_item"):
		get_tree().set_input_as_handled()
		if P.upgrades[highlighted.itemEnum]:
			print("already owned")
			Audio.PlaySFX(Audio.SFX.UI_INVALID)
		elif P.money >= highlighted.price:
			print("purchase success")
			Audio.PlaySFX(Audio.SFX.UI_PURCHASE)
			P.money -= highlighted.price
			P.upgrades[highlighted.itemEnum] = true
			highlighted.SetHighlightableUpgrades(P.upgrades[highlighted.itemEnum])
			if highlighted.itemEnum == G.Upgrades.FLAMINGSKULL:
				Events.emit_signal("flaming_skull_purchsed")
			elif highlighted.itemEnum == G.Upgrades.CANNON:
				Events.emit_signal("cannon_purchased")
			elif highlighted.itemEnum == G.Upgrades.EYE:
				Events.emit_signal("eye_purchased")
		else:
			print("cant afford it")
			Audio.PlaySFX(Audio.SFX.UI_INVALID)
			Events.emit_signal("cant_afford")

func Navigate(h, v):
	var startPos = highlighted.gridPos
	var newPos = startPos
	var newPosFound = false
	while !newPosFound:
		if h != 0:
			newPos.x = wrapi(newPos.x+h, 0, 3)
		else:
			newPos.y = wrapi(newPos.y+v, 0, 3)
			if gridMap[newPos].highlightable:
				newPosFound = true
			var newNewPos = newPos
			while !newPosFound:
				newPos.x = wrapi(newPos.x+1, 0, 3)
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
	Anchor.SetHighlightableUpgrades(P.upgrades[G.Upgrades.ANCHOR])
	FlamingSkull.SetHighlightableUpgrades(P.upgrades[G.Upgrades.FLAMINGSKULL])
	Cargo.SetHighlightableUpgrades(P.upgrades[G.Upgrades.CARGO])
	Cannon.SetHighlightableUpgrades(P.upgrades[G.Upgrades.CANNON])
	Compass.SetHighlightableUpgrades(P.upgrades[G.Upgrades.COMPASS])
	BigHook.SetHighlightableUpgrades(P.upgrades[G.Upgrades.BIGHOOK])
	Detector.SetHighlightableUpgrades(P.upgrades[G.Upgrades.DETECTOR])
	Eye.SetHighlightableUpgrades(P.upgrades[G.Upgrades.EYE])

func HighlightFirstItem():
	UpdateHightedItem(Anchor)

func UpdateHightedItem(item):
	if item == null:
		return
	highlighted = item
	ItemName.text = G.UpgradesNameMap[highlighted.itemEnum]
	Description.text = highlighted.Highlight()
