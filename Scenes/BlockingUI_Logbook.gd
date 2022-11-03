extends "res://Scenes/BlockingUI.gd"

const ROTATE_MAX = 150

onready var FishModelViewport = $FishModelViewport
onready var Model = $FishModelViewport/Model
onready var FishCamera = $FishModelViewport/Model/Camera

onready var FishName = $FishName
onready var Description = $Description
onready var CaughtValue = $CaughtValue
onready var WeightValue = $WeightValue

var fishClassInstance = null
var fishClassInstanceModel = null
var currentIndex = FishVariants.FishType.COMMON_1

var startRotateY : float = 180
var startRotateX : float = 0

func _ready():
	ScrollFish()
	
func _unhandled_input(event):
	if I.is_event_action(event, "toggle_logbook") and I.is_action_just_pressed("toggle_logbook") \
			or I.is_event_action(event, "exit_shop") and I.is_action_just_pressed("exit_shop"):
		get_tree().set_input_as_handled()
		Audio.PlaySFX(Audio.SFX.UI_BACK)
		Events.emit_signal("blocking_ui_exit")
	
	if fishClassInstance == null:
		return
		
	if I.is_event_action(event, "modelreset") and I.is_action_just_pressed("modelreset"):
		get_tree().set_input_as_handled()
		fishClassInstanceModel.rotation_degrees.y = startRotateY
		fishClassInstanceModel.rotation_degrees.x = startRotateX
		
	elif I.is_event_action(event, "logbook_left") and I.is_action_just_pressed("logbook_left"):
		get_tree().set_input_as_handled()
		ScrollFish(-1)
	elif I.is_event_action(event, "logbook_right") and I.is_action_just_pressed("logbook_right"):
		get_tree().set_input_as_handled()
		ScrollFish(1)

func _process(delta):
	if fishClassInstance == null:
		return
	
	var rotateY = 0
	var rotateX = 0
	var rotationAngleY = I.get_axis("modelrotate_left", "modelrotate_right")
	rotateY = ROTATE_MAX * rotationAngleY
	
	var rotationAngleX = -I.get_axis("modelrotate_up", "modelrotate_down")
	rotateX = ROTATE_MAX * rotationAngleX
	
	fishClassInstanceModel.rotation_degrees.y += rotateY * delta
	fishClassInstanceModel.rotation_degrees.x += rotateX * delta
	
func ScrollFish(dir=0):
	if fishClassInstance == null:
		currentIndex = FishVariants.FishType.COMMON_1
	else:
		fishClassInstance.queue_free()
		fishClassInstanceModel.queue_free()
		currentIndex = wrapi(currentIndex+dir, 0, 14)
	fishClassInstance = FishVariants.GetFishNodeInstance(currentIndex)
	FishModelViewport.add_child(fishClassInstance)
	
	fishClassInstanceModel = fishClassInstance.meshPackedScene.instance()
	Model.add_child(fishClassInstanceModel)
	
	fishClassInstanceModel.rotation_degrees.y = startRotateY
	fishClassInstanceModel.rotation_degrees.x = startRotateX
	
	var stats = P.fishStats[currentIndex]
	if stats.caught > 0:
		FishName.text = fishClassInstance.speciesName
		Description.text = fishClassInstance.speciesDescription
		FishModelViewport.world.environment.ambient_light_color = Color(1,1,1,1)
	else:
		FishName.text = "???"
		Description.text = ""
		FishModelViewport.world.environment.ambient_light_color = Color(0,0,0,1)
	CaughtValue.text = str(stats.caught)
	WeightValue.text = "%.1fkg" % stats.pb
	FishCamera.translation.x = fishClassInstance.logbookCameraX
	
	
