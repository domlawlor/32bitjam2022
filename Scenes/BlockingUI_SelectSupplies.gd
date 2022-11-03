extends "res://Scenes/BlockingUI.gd"

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

var highlighted = null
var gridMap = {} #populate on ready

func _ready():
	ItemName.text = ''
	Description.text = ''
	PopulateGridMap()
	EvaluateItems()
	HighlightFirstItem()

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
		if highlighted.ToggleSelected():
			Audio.PlaySFX(Audio.SFX.UI_SELECT)
		else:
			Audio.PlaySFX(Audio.SFX.UI_BACK)
	elif I.is_event_action(event, "exit_shop") and I.is_action_just_pressed("exit_shop"):
		get_tree().set_input_as_handled()
		Audio.PlaySFX(Audio.SFX.UI_BACK)
		ResumeFishing(true)
	elif I.is_event_action(event, "supplies_select_finished") and I.is_action_just_pressed("supplies_select_finished"):
		get_tree().set_input_as_handled()
		Audio.PlaySFX(Audio.SFX.UI_SELECT)
		SetSelectedSupplies()
		ResumeFishing(false)

func Navigate(h, v):
	if highlighted == null:
		return
		
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
	if P.supplies[G.Supplies.CHUM_UNCOMMON] > 0:
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
	else:
		print("nothing to select, abandon this screen")
		ResumeFishing(false)

func UpdateHightedItem(item):
	if item == null:
		return
	highlighted = item
	ItemName.text = G.SuppliesNameMap[highlighted.itemEnum]
	Description.text = highlighted.Highlight()

func SetSelectedSupplies():
	for supply in gridMap.values():
		P.activeSupplies[supply.itemEnum] = supply.selected
		if supply.selected:
			assert(P.supplies[supply.itemEnum] > 0)
			P.supplies[supply.itemEnum] -= 1

func ResumeFishing(aborted):
	Events.emit_signal("post_supplies_select", aborted)
	Events.emit_signal("blocking_ui_exit")
