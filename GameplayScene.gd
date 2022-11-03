extends Spatial

var ChestScene = preload("res://WorldCollectables/ChestCollectable.tscn")

onready var StaticCamera = $Camera
onready var BoatCamera = $Boat/Camera
onready var TreasureSpawns = $WorldCollectableSpawns/TreasureSpawns
onready var ChestInstanceParent = $WorldCollectableSpawns/ChestInstanceParent

onready var Blocker_Rocks1 = $WorldEnvironment/Blocker_Rocks_01
onready var Blocker_Rocks2 = $WorldEnvironment/Blocker_Rocks_02
onready var Blocker_Eye = $WorldEnvironment/Blocker_AllSeeingEye
onready var Rocks1BreakTimer = $WorldEnvironment/Rocks1BreakTimer
onready var Rocks2BreakTimer = $WorldEnvironment/Rocks2BreakTimer

func _ready():
	Events.connect("activate_screen", self, "_on_activate_screen")
	Events.connect("activate_camera", self, "_on_activate_camera")
	Events.connect("spawn_chest", self, "_on_spawn_chest")
	Events.connect("eye_purchased", self, "_on_eye_purchased")
	Events.emit_signal("spawn_chest")
	
func _exit():
	Events.disconnect("activate_screen", self, "_on_activate_screen")
	Events.disconnect("activate_camera", self, "_on_activate_camera")
	Events.disconnect("spawn_chest", self, "_on_spawn_chest")
	Events.disconnect("eye_purchased", self, "_on_eye_purchased")

func _unhandled_input(event):
	if G.activeScreen != G.Screens.GAMEPLAY:
		return
	
	if G.shopEntryInputActive and I.is_event_action(event, "dock_shop") and I.is_action_just_pressed("dock_shop"):
		get_tree().set_input_as_handled()
		var FADETIME = 0.5
		Events.emit_signal("transition", P, G.Screens.SHOP, '', 'SellCargo', FADETIME, FADETIME)
	
	elif I.is_event_action(event, "pause") and I.is_action_just_pressed("pause"):
		get_tree().set_input_as_handled()
		Audio.PlaySFX(Audio.SFX.UI_BACK)
		Events.emit_signal("create_blocking_ui", G.BlockingUITypes.INVENTORY, {})
	
	elif I.is_event_action(event, "toggle_logbook") and I.is_action_just_pressed("toggle_logbook"):
		get_tree().set_input_as_handled()
		Events.emit_signal("create_blocking_ui", G.BlockingUITypes.LOGBOOK, {})

func _on_activate_screen(screen):
	if screen == G.Screens.GAMEPLAY:
		Audio.StartGameMusic()
	
func _on_activate_camera(screen):
	if screen == G.Screens.GAMEPLAY:
		if G.shopEntryInputActive:
			StaticCamera.make_current()
		else:
			BoatCamera.make_current()

func _on_spawn_chest():
	var chestExists = ChestInstanceParent.get_child_count() > 0
	if chestExists:
		return
	var numSpawnPositions = TreasureSpawns.get_child_count()
	var randomChoice = randi() % numSpawnPositions
	var randomPosition = TreasureSpawns.get_child(randomChoice)
	var chestInst = ChestScene.instance()
	ChestInstanceParent.add_child(chestInst)
	chestInst.global_translation = randomPosition.global_translation

func _on_ShopEntranceTrigger_body_entered(body):
	if G.activeScreen != G.Screens.GAMEPLAY:
		return
	if body.is_in_group("boat"):
		print('show shop entry icon')
		StaticCamera.make_current()
		G.shopEntryInputActive = true

func _on_ShopEntranceTrigger_body_exited(body):
	if G.activeScreen != G.Screens.GAMEPLAY:
		return
	if body.is_in_group("boat"):
		print('hide shop entry icon')
		BoatCamera.make_current()
		G.shopEntryInputActive = false

func _on_CreepyTrigger_body_entered(body):
	if body.is_in_group("boat"):
		Audio.PlayMusic(Audio.MusicTrack.CREEPY_WATERS)

func _on_ShopTrigger_body_entered(body):
	if body.is_in_group("boat"):
		Audio.PlayMusic(Audio.MusicTrack.SHOP_THEME)

func _on_eye_purchased():
	Blocker_Eye.visible = false

func _on_BreakRocksTrigger1_body_entered(body):
	if P.upgrades[G.Upgrades.CANNON] and body.is_in_group("boat"):
		if Blocker_Rocks1.visible:
			Audio.PlayCannon()
			Rocks1BreakTimer.start()

func _on_BreakRocksTrigger2_body_entered(body):
	if P.upgrades[G.Upgrades.CANNON] and body.is_in_group("boat"):
		if Blocker_Rocks2.visible:
			Audio.PlayCannon()
			Rocks2BreakTimer.start()

func _on_QuestMythicArea_body_entered(body):
	if body.is_in_group("boat"):
		print("Fishing Zone Active: MYTHIC_QUEST")
		G.activeFishingZone = G.FishingZone.MYTHIC_QUEST

func _on_FishingZoneArea_body_exited(body):
	if body.is_in_group("boat"):
		print("Fishing Zone Active: COMMON")
		G.activeFishingZone = G.FishingZone.COMMON

func _on_FishingZoneRareArea_body_entered(body):
	if body.is_in_group("boat"):
		print("Fishing Zone Active: RARE")
		G.activeFishingZone = G.FishingZone.RARE

func _on_FishingZoneUncommonArea_body_entered(body):
	if body.is_in_group("boat"):
		print("Fishing Zone Active: UNCOMMON")
		G.activeFishingZone = G.FishingZone.UNCOMMON

func _on_Rocks1BreakTimer_timeout():
	Blocker_Rocks1.visible = false

func _on_Rocks2BreakTimer_timeout():
	Blocker_Rocks2.visible = false
