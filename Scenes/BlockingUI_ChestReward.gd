extends "res://Scenes/BlockingUI.gd"

var InventoryIcon_ChumUncommon = preload("res://ItemIcons/ItemIcon_ChumUncommon.tscn")
var InventoryIcon_OrbUncommon = preload("res://ItemIcons/ItemIcon_OrbUncommon.tscn")
var InventoryIcon_Narcolepsy = preload("res://ItemIcons/ItemIcon_Narcolepsy.tscn")
var InventoryIcon_Willpower = preload("res://ItemIcons/ItemIcon_Willpower.tscn")
var InventoryIcon_ChumRare = preload("res://ItemIcons/ItemIcon_ChumRare.tscn")
var InventoryIcon_OrbRare = preload("res://ItemIcons/ItemIcon_OrbRare.tscn")
var InventoryIcon_LineRare = preload("res://ItemIcons/ItemIcon_LineRare.tscn")
var InventoryIcon_Crown = preload("res://ItemIcons/ItemIcon_Crown.tscn")
var InventoryIcon_ChumMythic = preload("res://ItemIcons/ItemIcon_ChumMythic.tscn")
var InventoryIcon_OrbMythic = preload("res://ItemIcons/ItemIcon_OrbMythic.tscn")
var InventoryIcon_LineMythic = preload("res://ItemIcons/ItemIcon_LineMythic.tscn")

onready var InitTimer = $InitTimer
onready var SuppliesGrid = $CenterContainer/SuppliesGrid
onready var Description = $Description

func _ready():
	Description.text = ''
	InitTimer.start()

func _unhandled_input(event):
	if I.is_event_action(event, "exit_chestrewards") and I.is_action_just_pressed("exit_chestrewards"):
		get_tree().set_input_as_handled()
		Audio.PlaySFX(Audio.SFX.UI_BACK)
		Events.emit_signal("blocking_ui_exit")

func _on_InitTimer_timeout():
	var supplies = params.supplies
	var iconInst
	for supplyIndex in supplies:
		if supplyIndex == G.Supplies.CHUM_UNCOMMON:
			iconInst = InventoryIcon_ChumUncommon.instance()
		elif supplyIndex == G.Supplies.ORB_UNCOMMON:
			iconInst = InventoryIcon_OrbUncommon.instance()
		elif supplyIndex == G.Supplies.NARCOLEPSY:
			iconInst = InventoryIcon_Narcolepsy.instance()
		elif supplyIndex == G.Supplies.WILLPOWER:
			iconInst = InventoryIcon_Willpower.instance()
		elif supplyIndex == G.Supplies.CHUM_RARE:
			iconInst = InventoryIcon_ChumRare.instance()
		elif supplyIndex == G.Supplies.ORB_RARE:
			iconInst = InventoryIcon_OrbRare.instance()
		elif supplyIndex == G.Supplies.LINE_RARE:
			iconInst = InventoryIcon_LineRare.instance()
		elif supplyIndex == G.Supplies.CROWN:
			iconInst = InventoryIcon_Crown.instance()
		elif supplyIndex == G.Supplies.CHUM_MYTHIC:
			iconInst = InventoryIcon_ChumMythic.instance()
		elif supplyIndex == G.Supplies.ORB_MYTHIC:
			iconInst = InventoryIcon_OrbMythic.instance()
		elif supplyIndex == G.Supplies.LINE_MYTHIC:
			iconInst = InventoryIcon_LineMythic.instance()
		SuppliesGrid.add_child(iconInst)
		iconInst.DoubleSize()
	var rarityStr = "a common"
	var rarity = supplies.size()
	if rarity == 2:
		rarityStr = "an uncommon"
	elif rarity == 3:
		rarityStr = "a rare"
	Description.text = "You found %s \ntreasure chest!!\n It contained $%d and the following supplies!" % [rarityStr, params.money]
