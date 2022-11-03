extends Control

onready var FishingUI : Control = $FishingUI
onready var FishingReelInProgressBar : ProgressBar = $FishingUI/FishReelIn/ProgressBar
onready var FishingStateString : Control = $FishingStateString

onready var CaughtFishUI : Control = $CaughtFishUI
onready var FishName : Label = $CaughtFishUI/FishName
onready var FishWeight : Label = $CaughtFishUI/FishWeight

onready var CapsizedLabel : Label = $Capsized
onready var FogWarning = $FogWarning

onready var PadQTE : Control = $PadQTE
onready var DualShockQTE : Control = $DualShockQTE
onready var KeyboardQTE : Control = $KeyboardQTE

onready var PreHookQTE : Control = $PreHookQTE
onready var PreHookQTEText : Label = $PreHookQTE/PreHookText
onready var PreHookPadQTE : Control = $PreHookQTE/PadPreHookQTE
onready var PreHookDualShockQTE : Control = $PreHookQTE/DualShockPreHookQTE
onready var PreHookKeyboardQTE : Control = $PreHookQTE/KeyboardPreHookQTE

onready var PreHookTimingBar : Control = $PreHookQTE/TimingBar
onready var PreHookTimingBarProgress : Sprite = $PreHookQTE/TimingBar/Progress

func _ready():
	Events.connect("ui_fishing_state_change", self, "_on_ui_fishing_state_change")
	Events.connect("ui_capsized_change", self, "_on_ui_capsized_change")
	
	Events.connect("ui_show_caught_fish", self, "_on_ui_show_caught_fish")
	Events.connect("ui_hide_caught_fish", self, "_on_ui_hide_caught_fish")

	Events.connect("device_type_changed", self, "_on_device_type_changed")

	Events.connect("show_hooked_QTE", self, "_on_show_hooked_QTE")
	Events.connect("hide_hooked_QTE", self, "_on_hide_hooked_QTE")
	
	Events.connect("show_pre_hook_QTE", self, "_on_show_pre_hook_QTE")
	Events.connect("hide_pre_hook_QTE", self, "_on_hide_pre_hook_QTE")
	Events.connect("update_pre_hook_QTE", self, "_on_update_pre_hook_QTE")
	Events.connect("show_pre_hook_QTE_text", self, "_on_show_pre_hook_QTE_text")
	Events.connect("hide_pre_hook_QTE_text", self, "_on_hide_pre_hook_QTE_text")
	
	Events.connect("ui_fog_warning_change", self, "_on_ui_fog_warning_change")
	
	ResetToDefaults()




func _exit():
	Events.disconnect("ui_fishing_state_change", self, "_on_ui_fishing_state_change")
	Events.disconnect("ui_capsized_change", self, "_on_ui_capsized_change")
	Events.disconnect("ui_show_caught_fish", self, "_on_ui_show_caught_fish")
	Events.disconnect("ui_hide_caught_fish", self, "_on_ui_hide_caught_fish")
	
	Events.disconnect("device_type_changed", self, "_on_device_type_changed")
	
	Events.disconnect("show_hooked_QTE", self, "_on_show_hooked_QTE")
	Events.disconnect("hide_hooked_QTE", self, "_on_hide_hooked_QTE")
	
	Events.disconnect("show_pre_hook_QTE", self, "_on_show_pre_hook_QTE")
	Events.disconnect("hide_pre_hook_QTE", self, "_on_hide_pre_hook_QTE")
	Events.disconnect("show_pre_hook_QTE_text", self, "_on_show_pre_hook_QTE_text")
	Events.disconnect("hide_pre_hook_QTE_text", self, "_on_hide_pre_hook_QTE_text")
	
	Events.disconnect("ui_fog_warning_change", self, "_on_ui_fog_warning_change")

func _process(delta):
	if FishingUI.visible:
		#bad debug code, don't judge tim pls
		var fish = get_node("../../Boat/Fish")
		var reelInPercent = clamp(fish.currentTimeToReelIn / fish.totalTimeToReelIn, 0.0, 1.0)
		FishingReelInProgressBar.value = reelInPercent
	

func ResetToDefaults():
	FishingStateString.visible = false
	FishingUI.visible = false
	CapsizedLabel.visible = false
	CaughtFishUI.visible = false
	PreHookQTE.visible = false
	FogWarning.visible = false

func GetFishingStateString(newFishingState):
	match(newFishingState):
		G.FishingState.NOT_FISHING:
			return "NOT FISHING"
		G.FishingState.WAITING_FOR_FISH:
			return "WAITING FOR FISH"
		G.FishingState.PRE_HOOK_QTE:
			return "PRE HOOK QTE"
		G.FishingState.FISH_ON_HOOK:
			return "FISH ON HOOK"
		_:
			assert(false)


func _on_ui_fishing_state_change(newFishingState):
	var fishingStateString = GetFishingStateString(newFishingState)
	
	FishingStateString.text = fishingStateString
	FishingStateString.visible = false #newFishingState != G.FishingState.NOT_FISHING
	
	if newFishingState == G.FishingState.FISH_ON_HOOK:
		#FishingUI.visible = true
		pass
	else:
		FishingUI.visible = false

func _on_ui_capsized_change(capsized):
	CapsizedLabel.visible = capsized

func _on_ui_show_caught_fish(fishNode):
	FishName.text = fishNode.fishClassInstance.descriptiveName
	FishWeight.text = "Weight: %.1fkg" % fishNode.fishClassInstance.weight
	CaughtFishUI.visible = true

func _on_ui_hide_caught_fish():
	CaughtFishUI.visible = false

func _on_device_type_changed(deviceType):
	if deviceType == I.DeviceType.DUAL_SHOCK:
		PadQTE.visible = false
		PreHookPadQTE.visible = false
		DualShockQTE.visible = true
		PreHookDualShockQTE.visible = true
		KeyboardQTE.visible = false
		PreHookKeyboardQTE.visible = false
	elif deviceType == I.DeviceType.PAD:
		PadQTE.visible = true
		PreHookPadQTE.visible = true
		DualShockQTE.visible = false
		PreHookDualShockQTE.visible = false
		KeyboardQTE.visible = false
		PreHookKeyboardQTE.visible = false
	elif deviceType == I.DeviceType.KEYBOARD:
		PadQTE.visible = false
		PreHookPadQTE.visible = false
		DualShockQTE.visible = false
		PreHookDualShockQTE.visible = false
		KeyboardQTE.visible = true
		PreHookKeyboardQTE.visible = true

func _on_show_hooked_QTE(button):
	if DualShockQTE.visible:
		DualShockQTE.ShowButton(button)
	elif PadQTE.visible:
		PadQTE.ShowButton(button)
	else:
		KeyboardQTE.ShowButton(button)

func _on_hide_hooked_QTE():
	PadQTE.HideAll()
	DualShockQTE.HideAll()
	KeyboardQTE.HideAll()

func _on_show_pre_hook_QTE(button):
	PreHookTimingBarProgress.position.x = 0.0
	
	if PreHookDualShockQTE.visible:
		PreHookDualShockQTE.ShowButton(button)
	elif PreHookPadQTE.visible:
		PreHookPadQTE.ShowButton(button)
	else:
		PreHookKeyboardQTE.ShowButton(button)
	
	PreHookQTE.visible = true

func _on_hide_pre_hook_QTE():
	PreHookQTE.visible = false
	PreHookPadQTE.HideAll()
	PreHookDualShockQTE.HideAll()
	PreHookKeyboardQTE.HideAll()

func _on_update_pre_hook_QTE(percentThroughQTE):
	var endXPosition = 122.0
	var newXPos = lerp(0.0, endXPosition, percentThroughQTE)
	PreHookTimingBarProgress.position.x = newXPos
	
	var timing = G.PreHookTiming.POOR
	
	if newXPos >= 74 and newXPos <= 82:
		timing = G.PreHookTiming.PERFECT
	elif newXPos >= 63 and newXPos <= 93:
		timing = G.PreHookTiming.GOOD
	elif newXPos >= 48 and newXPos <= 107:
		timing = G.PreHookTiming.OKAY
	
	Events.emit_signal("prehook_timing", timing)

func _on_show_pre_hook_QTE_text(preHookTiming):
	PreHookPadQTE.HideAll()
	PreHookDualShockQTE.HideAll()
	PreHookKeyboardQTE.HideAll()
	
	if preHookTiming == G.PreHookTiming.PERFECT:
		PreHookQTEText.text = "Perfect!"
	elif preHookTiming == G.PreHookTiming.GOOD:
		PreHookQTEText.text = "Good!"
	elif preHookTiming == G.PreHookTiming.OKAY:
		PreHookQTEText.text = "Okay!"
	elif preHookTiming == G.PreHookTiming.POOR:
		PreHookQTEText.text = "Poor!"
	elif preHookTiming == G.PreHookTiming.MISSED:
		PreHookQTEText.text = "Missed!"
	
	PreHookQTEText.visible = true

func _on_hide_pre_hook_QTE_text():
	PreHookQTEText.visible = false
	PreHookQTEText.text = ""

func _on_ui_fog_warning_change(inFog):
	FogWarning.visible = inFog
