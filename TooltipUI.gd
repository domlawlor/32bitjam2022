extends Control

onready var EnterShop = $EnterShop
onready var Fishing = $Fishing
onready var HowToFishOneOff = $HowToFishOneOff
onready var HowToFishOneOffTimer = $HowToFishOneOff/Timer

var showFishingTooltip := false
var hideAll := false
var howToFishOneOffShown := false

func _ready():
	Events.connect("device_type_changed", self, "_on_device_type_changed")
	Events.connect("create_blocking_ui", self, "_on_create_blocking_ui")
	Events.connect("blocking_ui_exit", self, "_on_blocking_ui_exit")
	Events.connect("post_supplies_select", self, "_on_post_supplies_select")
	Events.connect("ui_first_time_fish", self, "_on_ui_first_time_fish")

func _exit():
	Events.disconnect("device_type_changed", self, "_on_device_type_changed")
	Events.disconnect("create_blocking_ui", self, "_on_create_blocking_ui")
	Events.disconnect("blocking_ui_exit", self, "_on_blocking_ui_exit")
	Events.disconnect("post_supplies_select", self, "_on_post_supplies_select")
	Events.disconnect("ui_first_time_fish", self, "_on_ui_first_time_fish")
	
func _process(delta):
	if hideAll:
		EnterShop.visible = false
		Fishing.visible = false
		HowToFishOneOff.visible = false
	else:
		if G.shopEntryInputActive:
			EnterShop.visible = true
			Fishing.visible = false
			HowToFishOneOff.visible = false
		elif showFishingTooltip:
			EnterShop.visible = false
			Fishing.visible = true
			HowToFishOneOff.visible = false
		elif !HowToFishOneOffTimer.is_stopped():
			HowToFishOneOff.visible = true
			EnterShop.visible = false
			Fishing.visible = false
		else:
			EnterShop.visible = false
			Fishing.visible = false
			HowToFishOneOff.visible = false

func _on_device_type_changed(deviceType):
	$EnterShop/GP.visible = deviceType == I.DeviceType.PAD
	$Fishing/GP.visible = deviceType == I.DeviceType.PAD
	$HowToFishOneOff/GP.visible = deviceType == I.DeviceType.PAD
	$EnterShop/GP_PS.visible = deviceType == I.DeviceType.DUAL_SHOCK
	$Fishing/GP_PS.visible = deviceType == I.DeviceType.DUAL_SHOCK
	$HowToFishOneOff/GP_PS.visible = deviceType == I.DeviceType.DUAL_SHOCK
	$EnterShop/KB.visible = deviceType == I.DeviceType.KEYBOARD
	$Fishing/KB.visible = deviceType == I.DeviceType.KEYBOARD
	$HowToFishOneOff/KB.visible = deviceType == I.DeviceType.KEYBOARD
		
func _on_create_blocking_ui(uiType, params):
	if uiType == G.BlockingUITypes.SELECT_SUPPLIES:
		showFishingTooltip = true
	elif uiType == G.BlockingUITypes.LOGBOOK:
		hideAll = true
	
func _on_blocking_ui_exit():
	hideAll = false
	
func _on_post_supplies_select(aborted):
	showFishingTooltip = false

func _on_ui_first_time_fish():
	howToFishOneOffShown = true
	HowToFishOneOffTimer.stop()

func _on_HowToFishTrigger_body_exited(body):
	if body.is_in_group("boat"):
		if !howToFishOneOffShown:
			howToFishOneOffShown = true
			HowToFishOneOffTimer.start()
