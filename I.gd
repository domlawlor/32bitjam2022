extends Node

# A wrapper class for Input that queries both keyboard and gamepad simultaneously whilst hopefully avoiding
# the annoying issue Godot has with kb/gp inputs on a single input map entry

const gp = 'gp_%s'
const kb = 'kb_%s'

enum DeviceType {
	PAD = 0,
	DUAL_SHOCK,
	KEYBOARD
} 
var lastUsedDeviceType = DeviceType.PAD

#Input singleton
func is_action_just_pressed(action):
	return Input.is_action_just_pressed(gp % action) or Input.is_action_just_pressed(kb % action)

func is_action_just_released(action):
	return Input.is_action_just_released(gp % action) or Input.is_action_just_released(kb % action)
	
func is_action_pressed(action):
	return Input.is_action_pressed(gp % action) or Input.is_action_pressed(kb % action)

func get_axis(negativeAction, positiveAction):
	var gpAxis = Input.get_axis(gp % negativeAction, gp % positiveAction)
	var kbAxis = Input.get_axis(kb % negativeAction, kb % positiveAction)
	
	if kbAxis != 0.0:
		return kbAxis
	else:
		return gpAxis

#InputEvent from _input functions
func is_event_action(event, action):
	return event.is_action(gp % action) or event.is_action(kb % action)

func is_event_action_pressed(event, action):
	return event.is_action_pressed(gp % action) or event.is_action_pressed(kb % action)


# purely used to query most recently used controller. Aka Xbox vs playstation gamepad, also keyboard too I guess
func _input(event):
	if event is InputEventJoypadButton:
		var deviceName = Input.get_joy_name(event.device)
		if (deviceName == "PS4 Controller" or deviceName == "PS5 Controller" or 
		 "PS4" in deviceName or "PS5" in deviceName or "DualShock" in deviceName or "Dual Shock" in deviceName or "Sony" in deviceName):
			lastUsedDeviceType = DeviceType.DUAL_SHOCK
		else:
			lastUsedDeviceType = DeviceType.PAD
		
	elif event is InputEventKey:
		lastUsedDeviceType = DeviceType.KEYBOARD
		
	Events.emit_signal("device_type_changed", lastUsedDeviceType)
		

func GetQTEInput():
	var qteButtons = []
	if I.is_action_just_pressed("qte_cross"):
		qteButtons.push_back(G.QTE_Button.CROSS)
	if I.is_action_just_pressed("qte_circle"):
		qteButtons.push_back(G.QTE_Button.CIRCLE)
	if I.is_action_just_pressed("qte_square"):
		qteButtons.push_back(G.QTE_Button.SQUARE)
	if I.is_action_just_pressed("qte_triangle"):
		qteButtons.push_back(G.QTE_Button.TRIANGLE)
	return qteButtons	
