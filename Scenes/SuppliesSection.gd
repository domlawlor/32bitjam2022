extends Control

onready var CursorPos = $CursorPos

onready var ChumUncommon = $SuppliesGrid/ChumUncommon
onready var OrbUncommon = $SuppliesGrid/OrbUncommon
onready var Narcolepsy = $SuppliesGrid/Narcolepsy
onready var Willpower = $SuppliesGrid/Willpower
onready var ChumRare = $SuppliesGrid/ChumRare
onready var OrbRare = $SuppliesGrid/OrbRare
onready var LineRare = $SuppliesGrid/LineRare
onready var Crown = $SuppliesGrid/Crown
onready var ChumMythic = $SuppliesGrid/ChumMythic
onready var OrbMythic = $SuppliesGrid/OrbMythic
onready var LineMythic = $SuppliesGrid/LineMythic
onready var SuppliesHeader = $SuppliesGrid/SuppliesHeader

onready var ItemName = $ItemName
onready var Description = $Description

var active = false
var highlighted = null
var gridMap = {} #populate on ready

func _ready():
	PopulateGridMap()

func GetCursorPos():
	return CursorPos.position

func PopulateGridMap():
	gridMap = {
		Vector2(3, 0) : ChumUncommon,
		Vector2(4, 0) : OrbUncommon,
		Vector2(5, 0) : Narcolepsy,
		Vector2(6, 0) : Willpower,
		Vector2(3, 1) : ChumRare,
		Vector2(4, 1) : OrbRare,
		Vector2(5, 1) : LineRare,
		Vector2(6, 1) : Crown,
		Vector2(3, 2) : ChumMythic,
		Vector2(4, 2) : OrbMythic,
		Vector2(5, 2) : LineMythic,
		Vector2(6, 2) : SuppliesHeader,
	}

func _unhandled_input(event):
	if !active:
		return
		
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
	elif I.is_event_action(event, "purchase_item") and I.is_action_just_pressed("purchase_item"):
		get_tree().set_input_as_handled()
		if P.money >= highlighted.price:
			print("purchase success")
			Audio.PlaySFX(Audio.SFX.UI_PURCHASE)
			P.money -= highlighted.price
			P.supplies[highlighted.itemEnum] += 1
			highlighted.SetHighlightableSupplies(P.supplies[highlighted.itemEnum])
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
			newPos.x = wrapi(newPos.x+h, 3, 7)
		else:
			newPos.y = wrapi(newPos.y+v, 0, 3)
			if gridMap[newPos].highlightable:
				newPosFound = true
			var newNewPos = newPos
			while !newPosFound:
				newPos.x = wrapi(newPos.x+1, 3, 7)
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
	ChumUncommon.SetHighlightableSupplies(P.supplies[G.Supplies.CHUM_UNCOMMON])
	OrbUncommon.SetHighlightableSupplies(P.supplies[G.Supplies.ORB_UNCOMMON])
	Narcolepsy.SetHighlightableSupplies(P.supplies[G.Supplies.NARCOLEPSY])
	Willpower.SetHighlightableSupplies(P.supplies[G.Supplies.WILLPOWER])
	ChumRare.SetHighlightableSupplies(P.supplies[G.Supplies.CHUM_RARE])
	OrbRare.SetHighlightableSupplies(P.supplies[G.Supplies.ORB_RARE])
	LineRare.SetHighlightableSupplies(P.supplies[G.Supplies.LINE_RARE])
	Crown.SetHighlightableSupplies(P.supplies[G.Supplies.CROWN])
	ChumMythic.SetHighlightableSupplies(P.supplies[G.Supplies.CHUM_MYTHIC])
	OrbMythic.SetHighlightableSupplies(P.supplies[G.Supplies.ORB_MYTHIC])
	LineMythic.SetHighlightableSupplies(P.supplies[G.Supplies.LINE_MYTHIC])

func HighlightFirstItem():
	UpdateHightedItem(ChumUncommon)

func UpdateHightedItem(item):
	if item == null:
		return
	highlighted = item
	ItemName.text = G.SuppliesNameMap[highlighted.itemEnum]
	Description.text = highlighted.Highlight()
