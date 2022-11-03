extends "res://Scenes/BlockingUI.gd"

var fishSprite = preload("res://Art/Icons/Bait01.png")

onready var CargoGrid = $CenterContainer/CargoGrid
onready var Description = $Description

onready var InitTimer = $InitTimer

func _ready():
	Description.text = ''
	InitTimer.start()

func _unhandled_input(event):
	if I.is_event_action(event, "exit_chestrewards") and I.is_action_just_pressed("exit_chestrewards"):
		get_tree().set_input_as_handled()
		Events.emit_signal("blocking_ui_exit")


func _on_InitTimer_timeout():
	var fish = params.fish
	var totalMoney:float = 0
	for f in fish:
		totalMoney += f.price
		var spr = TextureRect.new()
		spr.texture = fishSprite
		var spriteSize = 50
		spr.rect_min_size.x = spriteSize
		spr.rect_min_size.y = spriteSize
		spr.rect_size.x = spriteSize
		spr.rect_size.y = spriteSize
		spr.expand = true
		CargoGrid.add_child(spr)
		f.queue_free()
	
	var numFish = fish.size()
	Description.text = "You sold %d fish for $%.0f!" % [numFish, totalMoney]
