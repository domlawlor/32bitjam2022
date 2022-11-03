extends KinematicBody

export(float) var boatAcceleration = 2.5
export(float) var boatRotationDegreesPerSec = 65

export(float) var waterDragPerSec = 0.5

export(float) var tipOverBoatDegrees = 60
export(float) var tippingInputAnglePerSec = 10
export(float) var tippingItemReduceAnglePerSec = 2
export(float) var lowestTippingDegreesAllowed = -15

export(float) var boatLeanOnTurnDegrees := 8.0
export(float) var boatMaxLeanAtVelocity := 5.0
export(float) var timeBeforeMaxTurnLeanSec := 6.0

export(float) var maxSpeedBeforeBlockingFishing = 5.0 # max speed allowed before blocking transition into fishing state
export(float) var hookUnderWaterYPos = -2.5
export(float) var timeToLowerRaiseHook = 1.5

export(float) var minWaitForFishTime := 1.5
export(float) var maxWaitForFishTime := 2.0

export(float) var fishingLineLengthAtMaxReelInTime = 8.0

export(float) var successQTEStopFishPullTime := 0.5

export(Curve) var correctInputCurve
export(Curve) var incorrectInputCurve

var boatState = G.BoatState.CRUISING
var fishingState = G.FishingState.NOT_FISHING

var velocity : float = 0.0

var boatInitialTransform : Transform
var craneInitialTransform : Transform
var hookInitialTransform : Transform
var boatMeshInitialTransform : Transform

var currentBoatYRotation : float # turning
var currentCraneYRotation : float

# leaning boat (from turning) 
var currentBoatXRotation : float
var targetBoatXRotation : float
var timeHeldTurn := 0.0
var lastRotateInput := 0.0

var currentCapsizedAngle := 0.0

var timeUntilHookFish := 0.0

var fishPullTemporaryStopTime := 0.0

var currentCapsizeRotationTime = 0.0
var targetCapsizedAngle = 0.0
var lastCapsizedAngle = 0.0

enum CaughtFishState {
	INACTIVE = 0,
	PLAYING_CAUGHT_TWEEN,
	WAITING_FOR_INPUT,
	PLAYING_HIDE_TWEEN,
}
var caughtFishState = CaughtFishState.INACTIVE

var activeTween : SceneTreeTween

var caughtFishTweenLength = 2.0

var hookBackToDefaultTweenLength = 1.5

var hideFishTweenLength = 1.5
var hideFishTweenToScale = Vector3(0.1, 0.1, 0.1)

# seperate of the above
var raisingOrLoweringHook := false
var raiseLowerHookTween : SceneTreeTween

var positionFishingBegun : Vector3
var fixCloseToWallsTween

enum PreHookState {
	BEFORE = 0,
	DURING,
	AFTER,
}
var preHookState = PreHookState.BEFORE

var timeBeforePreHookQTE := 0.0
var timeAfterPreHookQTE := 0.0

var preHookQTECurrentTime := 0.0
var preHookQTETotalTime := 0.0

var preHookQTEButton = G.QTE_Button.NONE


var preHookTiming = G.PreHookTiming.MISSED

onready var CaughtFishDisplayPos : Position3D = $CaughtFishDisplayPos

onready var BoatMesh : MeshInstance = $Boat
onready var Crane : MeshInstance = $Boat/Crane
onready var Hook : MeshInstance = $Boat/Crane/Hook
onready var Fish : Spatial = $Fish

onready var PostCapsizeTimer = $PostCapsizeTimer

onready var NoFishingZone : Area = $NoFishingArea

func GetBoatFowardVector():
	return -transform.basis.x # boat is setup to face -x axis
func GetBoatLeftVector():
	return transform.basis.z

func GetCraneDirectionVector():
	return -Crane.transform.basis.x # crane initially face -x axis without rotation
func GetCraneInitialDirectionVector():
	return GetBoatLeftVector()
	
func GetCraneAngle():
	var directionVector = GetCraneDirectionVector()
	var angleRadians = directionVector.signed_angle_to(GetCraneInitialDirectionVector(), G.Y_AXIS)
	return angleRadians
	
func _ready():
	Events.connect("reset_boat", self, "_on_reset_boat")
	Events.connect("caught_fish", self, "_on_caught_fish")
	Events.connect("hooked_QTE_success", self, "_on_hooked_QTE_success")
	Events.connect("post_supplies_select", self, "_on_post_supplies_select")
	Events.connect("cannon_purchased", self, "_on_cannon_purchased")
	Events.connect("eye_purchased", self, "_on_eye_purchased")
	Events.connect("prehook_timing", self, "_on_prehook_timing")
	
	boatInitialTransform = transform
	craneInitialTransform = Crane.transform
	hookInitialTransform = Hook.transform
	boatMeshInitialTransform = BoatMesh.transform

	ResetBoat()

func _exit():
	Events.disconnect("reset_boat", self, "_on_reset_boat")
	Events.disconnect("caught_fish", self, "_on_caught_fish")
	Events.disconnect("hooked_QTE_success", self, "_on_hooked_QTE_success")
	Events.disconnext("post_supplies_select", self, "_on_post_supplies_select")
	Events.disconnect("cannon_purchased", self, "_on_cannon_purchased")
	Events.disconnect("eye_purchased", self, "_on_eye_purchased")
	Events.disconnect("prehook_timing", self, "_on_prehook_timing")

var lastPreHookTimingFromGUI = G.PreHookTiming.POOR
func _on_prehook_timing(timing):
	lastPreHookTimingFromGUI = timing

func ResetBoat():
	SetBoatState(G.BoatState.CRUISING)
	SetFishingState(G.FishingState.NOT_FISHING)
	
	Fish.ResetFish()
	Fish.scale = Vector3.ONE
	Fish.visible = false
	
	currentBoatYRotation = 0.0
	currentCraneYRotation = 0.0
	
	currentBoatXRotation = 0.0
	targetBoatXRotation = 0.0
	
	currentCapsizedAngle = 0.0
	
	velocity = 0.0
	
	transform = boatInitialTransform
	Crane.transform = craneInitialTransform
	Hook.transform = hookInitialTransform
	BoatMesh.transform = boatMeshInitialTransform
	
	Events.emit_signal("ui_capsized_change", false)

func _physics_process(delta):
	if G.activeScreen != G.Screens.GAMEPLAY:
		return
	if boatState == G.BoatState.CRUISING:
		BoatCruisingUpdate(delta)
	if boatState == G.BoatState.WAITING_FOR_SUPPLIES_SELECT:
		pass # wait to see if player aborts fishing
	if boatState == G.BoatState.CRUISING_TO_FISHING:
		BoatCruisingToFishingUpdate(delta)
	elif boatState == G.BoatState.FISHING:
		BoatFishingUpdate(delta)
	elif boatState == G.BoatState.FISHING_TO_CRUISING:
		BoatFishingToCruisingUpdate(delta)
	elif boatState == G.BoatState.CAUGHT_FISH:		
		BoatCaughtFishUpdate(delta)
	elif boatState == G.BoatState.CAPSIZING:
		BoatCapsizingUpdate(delta)
		
	# translation update
	if !is_equal_approx(velocity, 0.0):
		var velocityVec = GetBoatFowardVector() * velocity
		move_and_slide(velocityVec, G.Y_AXIS)

	## ROTATION UPDATES
	transform.basis = boatInitialTransform.basis
	
	rotate_y(currentBoatYRotation) # left right turning
	
	# leaning(when turning)
	rotate(GetBoatFowardVector(), -currentBoatXRotation)
	
	Crane.transform.basis = craneInitialTransform.basis
	Crane.rotate_y(currentCraneYRotation)
	
	BoatMesh.transform.basis = boatMeshInitialTransform.basis
	var craneTangentVec := Crane.transform.basis.z
	BoatMesh.rotate(craneTangentVec, currentCapsizedAngle)

func BoatCruisingUpdate(delta):
	var noFishingZoneOverlaps = NoFishingZone.get_overlapping_bodies()
	var toCloseToWalls = noFishingZoneOverlaps.size() != 0
	
	if !G.shopEntryInputActive and I.is_action_just_pressed("boat_toggle_fishing"):
		if P.IsCargoFull():
			Events.emit_signal("ui_alert_cargofull")
		elif toCloseToWalls:
			Events.emit_signal("ui_alert_wallsToClose")
			print("CANT FISH - too close to walls")
		elif velocity <= maxSpeedBeforeBlockingFishing:
			if !P.HaveNoSupplies():
				Events.emit_signal("create_blocking_ui", G.BlockingUITypes.SELECT_SUPPLIES, {})
				SetBoatState(G.BoatState.WAITING_FOR_SUPPLIES_SELECT)
			else:
				Events.emit_signal("ui_first_time_fish")
				positionFishingBegun = global_translation
				SetBoatState(G.BoatState.CRUISING_TO_FISHING)
			return
	
	
	
	## TURNING
	var rotateInput = -I.get_axis("fishing_counter_left", "fishing_counter_right")

	if rotateInput != lastRotateInput:
		timeHeldTurn = 0.0
	else:
		timeHeldTurn += delta
	lastRotateInput = rotateInput
	
	# update our rotation angle, actual rotation happens last
	if !is_equal_approx(rotateInput, 0.0):	
		var radiansToRotateBy = rotateInput * deg2rad(boatRotationDegreesPerSec) * delta
		currentBoatYRotation += radiansToRotateBy
		currentBoatYRotation = wrapf(currentBoatYRotation, -PI, PI)
	
	var leanByVelocityPercent = min(velocity / boatMaxLeanAtVelocity, 1.0);
	
	targetBoatXRotation = -rotateInput * leanByVelocityPercent * deg2rad(boatLeanOnTurnDegrees)
	
	# lerp the boat leaning while turning
	if currentBoatXRotation != targetBoatXRotation:
		var leanPercent = min(timeHeldTurn / timeBeforeMaxTurnLeanSec, 1.0)
		currentBoatXRotation = lerp_angle(currentBoatXRotation, targetBoatXRotation, leanPercent)
		
	## FORWARD - REVERSING
	var forwardBackInput := 0.0
	if I.is_action_pressed("boat_forward"):
		Audio.PlayBoatEngine(Audio.BoatEngine.MOVE)
		forwardBackInput += 1.0
	elif I.is_action_pressed("boat_reverse"):
		Audio.PlayBoatEngine(Audio.BoatEngine.MOVE)
		forwardBackInput -= 1.0
	else:
		Audio.PlayBoatEngine(Audio.BoatEngine.IDLE)
	
	if !is_equal_approx(forwardBackInput, 0.0):
		var velocityToAdd = forwardBackInput * boatAcceleration * delta
		velocity += velocityToAdd
	
	velocity *= 1.0 - (waterDragPerSec * delta)

func BoatCruisingToFishingUpdate(delta):
	var hasVelocity = !is_equal_approx(velocity, 0.0)
	var isLeaning = !is_equal_approx(currentBoatXRotation, 0.0)
	
	#first off we need to slow down to a complete stop and revert any leaning/xrotation
	if hasVelocity or isLeaning:
		if hasVelocity:
			velocity -= boatAcceleration * delta
			velocity = max(velocity, 0.0)
			
		if isLeaning:
			var leanChange = deg2rad(8) * delta
			if currentBoatXRotation < 0.0:
				currentBoatXRotation = min(currentBoatXRotation + leanChange, 0.0)
			else:
				currentBoatXRotation = max(currentBoatXRotation - leanChange, 0.0)	
		return
	
	var noFishingZoneOverlaps = NoFishingZone.get_overlapping_bodies()
	var toCloseToWalls = noFishingZoneOverlaps.size() != 0
	if toCloseToWalls:
		fixCloseToWallsTween = create_tween().set_trans(Tween.TRANS_LINEAR)
		fixCloseToWallsTween.tween_property(self, "global_translation", positionFishingBegun, 1.0)
	
	if !raisingOrLoweringHook:
		Audio.PlaySFX(Audio.SFX.HOOK_DROP)
		var targetTranslation = hookInitialTransform.origin
		targetTranslation.y += hookUnderWaterYPos

		raiseLowerHookTween = create_tween().set_trans(Tween.TRANS_LINEAR)
		raiseLowerHookTween.tween_property(Hook, "translation", targetTranslation, timeToLowerRaiseHook)
		raisingOrLoweringHook = true
	else:
		assert(raiseLowerHookTween)
		if !raiseLowerHookTween.is_running(): # if finished tween
			if fixCloseToWallsTween and fixCloseToWallsTween.is_running():
				fixCloseToWallsTween = null
				return
			
			raiseLowerHookTween = null
			raisingOrLoweringHook = false
			Audio.PlayMusic(Audio.MusicTrack.FISHING_THEME)
			SetBoatState(G.BoatState.FISHING)

func BoatFishingUpdate(delta):
#	var noFishOnTheLine = (fishingState == G.FishingState.NOT_FISHING or fishingState == G.FishingState.WAITING_FOR_FISH)
#	if noFishOnTheLine and I.is_action_just_pressed("boat_toggle_fishing"):
#		SetBoatState(G.BoatState.FISHING_TO_CRUISING)
#		return
	
	# start fishing
	if fishingState == G.FishingState.NOT_FISHING:
		timeUntilHookFish = rand_range(minWaitForFishTime, maxWaitForFishTime)
		SetFishingState(G.FishingState.WAITING_FOR_FISH)
	
	elif fishingState == G.FishingState.WAITING_FOR_FISH:
		if timeUntilHookFish <= 0:
			var boatWorldPos = global_translation
			var hookWorldPos = Hook.global_translation
			Fish.OnPreHook(boatWorldPos, hookWorldPos)

			SetupPreHookQTE()
			
			SetFishingState(G.FishingState.PRE_HOOK_QTE)
		else:
			timeUntilHookFish -= delta
	
	elif fishingState == G.FishingState.PRE_HOOK_QTE:
		FishPreHookQTEUpdate(delta)
	elif fishingState == G.FishingState.FISH_ON_HOOK:
		FishOnHookUpdate(delta)

func BoatCaughtFishUpdate(delta):
	#revert any leaning/xrotation
	if !is_equal_approx(currentBoatXRotation, 0.0):
		var leanChange = deg2rad(50) * delta
		if currentBoatXRotation < 0.0:
			currentBoatXRotation = min(currentBoatXRotation + leanChange, 0.0)
		else:
			currentBoatXRotation = max(currentBoatXRotation - leanChange, 0.0)	
	
	#revert any capsizing
	if !is_equal_approx(currentCapsizedAngle, 0.0):
		var capsizeChange = deg2rad(50) * delta
		if currentCapsizedAngle < 0.0:
			currentCapsizedAngle = min(currentCapsizedAngle + capsizeChange, 0.0)
		else:
			currentCapsizedAngle = max(currentCapsizedAngle - capsizeChange, 0.0)	
	
	# move crane to default angle
	if !is_equal_approx(currentCraneYRotation, 0.0):
		var craneRotateSpeed = deg2rad(100) * delta
		
		if currentCraneYRotation < 0.0:
			currentCraneYRotation = min(currentCraneYRotation + craneRotateSpeed, 0.0)
		else:
			currentCraneYRotation = max(currentCraneYRotation - craneRotateSpeed, 0.0)
		currentCraneYRotation = wrapf(currentCraneYRotation, -PI, PI)
	
	var advanceBoatState = true
	
	# raise hook tween 
	if !raisingOrLoweringHook and Hook.translation != hookInitialTransform.origin:
		RaiseHookTween()

	if caughtFishState == CaughtFishState.INACTIVE:
		# just entered. Play caught fish tween
		activeTween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
		activeTween.tween_property(Fish, "global_translation", CaughtFishDisplayPos.global_translation, caughtFishTweenLength)
		
		caughtFishState = CaughtFishState.PLAYING_CAUGHT_TWEEN
		
	elif caughtFishState == CaughtFishState.PLAYING_CAUGHT_TWEEN:
		if !activeTween.is_running(): # wait until tween is done
			Events.emit_signal("ui_show_caught_fish", Fish)
			caughtFishState = CaughtFishState.WAITING_FOR_INPUT
			
	elif caughtFishState == CaughtFishState.WAITING_FOR_INPUT:
		if I.is_action_just_pressed("caught_fish_proceed"):
			Events.emit_signal("ui_hide_caught_fish")	
			
			activeTween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
			activeTween.tween_property(Fish, "global_translation", global_translation, hideFishTweenLength)
			activeTween.parallel().tween_property(Fish, "scale", hideFishTweenToScale, hideFishTweenLength).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
			
			P.AddFishToCargo(Fish.fishClassInstance)
			
			caughtFishState = CaughtFishState.PLAYING_HIDE_TWEEN
			Audio.PlaySFX(Audio.SFX.POKEBALL)
			
	elif caughtFishState == CaughtFishState.PLAYING_HIDE_TWEEN:
		if !activeTween.is_running(): # wait until tween is done
			caughtFishState = CaughtFishState.INACTIVE
			
			if !raisingOrLoweringHook or !raiseLowerHookTween.is_running():
				raiseLowerHookTween = null
				raisingOrLoweringHook = false
				
				SetBoatState(G.BoatState.FISHING_TO_CRUISING)
				Fish.visible = false
				Fish.scale = Vector3.ONE

# returns true if complete 
func RaiseHookTween():
	assert(!raiseLowerHookTween)
	raiseLowerHookTween = create_tween().set_trans(Tween.TRANS_LINEAR)
	raiseLowerHookTween.tween_property(Hook, "translation", hookInitialTransform.origin, 0.75)
	raisingOrLoweringHook = true
	
func BoatFishingToCruisingUpdate(delta):
	if !raisingOrLoweringHook and Hook.translation != hookInitialTransform.origin:
		RaiseHookTween()
	else:
		raiseLowerHookTween = null
		raisingOrLoweringHook = false
		SetBoatState(G.BoatState.CRUISING) # move to next state

func BoatCapsizingUpdate(delta):
	# just entered this state
	if currentCapsizeRotationTime == 0.0:
		Audio.PlaySFX(Audio.SFX.CAPSIZE)
		lastCapsizedAngle = currentCapsizedAngle
		targetCapsizedAngle = deg2rad(180) # full turned over
	
	var timeToFullyCapsize = 2.5
	var lerpPercent = currentCapsizeRotationTime / timeToFullyCapsize
	lerpPercent = min(lerpPercent, 1.0)
	
	currentCapsizeRotationTime += delta # do this after lerping
	
	currentCapsizedAngle = lerp_angle(lastCapsizedAngle, targetCapsizedAngle, lerpPercent)
	
	if lerpPercent == 1.0:
		print("Fully Capsized - GameOver")
		Events.emit_signal("ui_capsized_change", true)
		Events.emit_signal("capsize_triggered")
		SetBoatState(G.BoatState.CAPSIZED)
		PostCapsizeTimer.start()
		return

func SetupPreHookQTE():
	preHookState = PreHookState.BEFORE
	
	timeBeforePreHookQTE = 0.5
	timeAfterPreHookQTE = 1
	
	preHookQTECurrentTime = 0.0
	preHookQTETotalTime = Fish.fishClassInstance.preHookQTETimeLength
	
	# PRE HOOK EFFECTS
	# rare line gives more reaction time for pre hook bite event
	var rareLineUsed = P.activeSupplies[G.Supplies.LINE_RARE]
	var mythicLineUsed = P.activeSupplies[G.Supplies.LINE_MYTHIC]
	
	if rareLineUsed:
		preHookQTETotalTime += Fish.fishClassInstance.preHookQTETimeLength / 8.0
	if mythicLineUsed:
		preHookQTETotalTime += Fish.fishClassInstance.preHookQTETimeLength / 4.0
	
	var possibleButtons = G.rarietyToQTEButtons[Fish.fishClassInstance.rarity]		
	preHookQTEButton = possibleButtons[randi() % possibleButtons.size()]

	preHookTiming = G.PreHookTiming.MISSED


func FishPreHookQTEUpdate(delta):
	match(preHookState):
		PreHookState.BEFORE:
			if timeBeforePreHookQTE <= 0.0:
				Events.emit_signal("show_pre_hook_QTE", preHookQTEButton)
				preHookState = PreHookState.DURING
			timeBeforePreHookQTE -= delta
		
		PreHookState.DURING:
			var percentThroughQTE = min(preHookQTECurrentTime / preHookQTETotalTime, 1.0)
			Events.emit_signal("update_pre_hook_QTE", percentThroughQTE)
			
			preHookQTECurrentTime += delta
			
			var qteButtons = I.GetQTEInput()
			var hasQTEInput = qteButtons.size() > 0
			
			if hasQTEInput or preHookQTECurrentTime >= preHookQTETotalTime:
				var singleButtonPressed = qteButtons.size() == 1
				var hookedFish = singleButtonPressed and qteButtons.has(preHookQTEButton)
				
				# no matter what, hitting a button will give you a poor hook if its wrong button or outside timing winow
				if hasQTEInput:
					preHookTiming = G.PreHookTiming.POOR
					
					if !hookedFish:
						Audio.PlaySFX(Audio.SFX.QTE_FAIL)
				
				if hookedFish:
					Audio.PlaySFX(Audio.SFX.REEL_IN)
					preHookTiming = lastPreHookTimingFromGUI
				
				Events.emit_signal("show_pre_hook_QTE_text", preHookTiming)
				
				preHookState = PreHookState.AFTER
			
			
		PreHookState.AFTER:
			if timeAfterPreHookQTE <= 0.0:
				Events.emit_signal("hide_pre_hook_QTE")
				Events.emit_signal("hide_pre_hook_QTE_text")
				preHookState = PreHookState.BEFORE
				
				if preHookTiming != G.PreHookTiming.MISSED:
					Fish.SetHooked(preHookTiming)
					Fish.visible = true
					SetFishingState(G.FishingState.FISH_ON_HOOK)
				else:
					Audio.PlayPrevMusic()
					SetFishingState(G.FishingState.NOT_FISHING)
					SetBoatState(G.BoatState.FISHING_TO_CRUISING)
			
			timeAfterPreHookQTE -= delta

func FishOnHookUpdate(delta):
	# calculate crane angle off boat to fish vector
	currentCraneYRotation = Fish.finalPosAngle
	
	# fish pulling a small amount each frame
	var fishPullTipAmount := 0.0
	
	var tempStoppedFishPull = fishPullTemporaryStopTime > 0.0	
	if Fish.fishIsPulling and !tempStoppedFishPull:
		fishPullTipAmount = Fish.fishClassInstance.boatTippingAnglePerSec * delta
	
	if tempStoppedFishPull:
		fishPullTemporaryStopTime -= delta

	
	#Counter tipping with input
	var inputTipAmount := 0.0
	
	var upDownInput = I.get_axis("fishing_counter_down", "fishing_counter_up")
	var leftRightInput = I.get_axis("fishing_counter_left", "fishing_counter_right")

	var counterCapsizeInputVector = Vector3.ZERO
	counterCapsizeInputVector.x = -upDownInput
	counterCapsizeInputVector.z = -leftRightInput
	counterCapsizeInputVector = counterCapsizeInputVector.normalized()
	
	
	# Analogue input to counter the fish capsizing the boat
	if counterCapsizeInputVector.length() > 0.0:
		var craneDir = -Crane.transform.basis.x
		var counterInputAngle = rad2deg(counterCapsizeInputVector.signed_angle_to(craneDir, G.Y_AXIS))	
		counterInputAngle = abs(counterInputAngle)
		
		# 180 is a perfect counter angle, 90 will count as neutral
		# Map 90 to 180 to 0 to 1
		# 0 to 90 will be negative effect and capsize the boat more
		var inputMul = 0.0
		if counterInputAngle >= 90: # countering.
			var inputVal = range_lerp(counterInputAngle, 90.0, 180.0, 0.0, 1.0)
			inputMul = -correctInputCurve.interpolate(inputVal)
			
		else: # in the direction the fish is pulling. This one is bad for the player
			var inputVal = range_lerp(counterInputAngle, 90.0, 0.0, 0.0, 1.0)
			inputMul = incorrectInputCurve.interpolate(inputVal)
		
		inputTipAmount = inputMul * tippingInputAnglePerSec * delta
	
	# ITEM TO REDUCE TIPPING
	# willpower potion and anchor reduces the amount a fish tips the boat
	var itemTipAmount = 0.0
	
	var willpowerPotionUsed = P.activeSupplies[G.Supplies.WILLPOWER]
	var anchorOwned = P.upgrades[G.Upgrades.ANCHOR]
	if willpowerPotionUsed or anchorOwned:
		var itemCount = (2 if willpowerPotionUsed and anchorOwned else 1)
		itemTipAmount = (tippingItemReduceAnglePerSec * itemCount) * delta
	
	var newCapsizedAngle = currentCapsizedAngle + deg2rad(fishPullTipAmount) + deg2rad(inputTipAmount) - deg2rad(itemTipAmount)
	
	#print("Tipping - currentCapsizedAngle-", currentCapsizedAngle, ", newCapsizedAngle-", newCapsizedAngle)
	#print("fishPullTipAmount-", fishPullTipAmount, ", inputTipAmount-", inputTipAmount, ", itemTipAmount-", itemTipAmount)
	
	newCapsizedAngle = max(newCapsizedAngle, deg2rad(lowestTippingDegreesAllowed))
	
	currentCapsizedAngle = newCapsizedAngle
	
	if currentCapsizedAngle >= deg2rad(tipOverBoatDegrees):
		SetFishingState(G.FishingState.NOT_FISHING)
		
		currentCapsizeRotationTime = 0.0
		SetBoatState(G.BoatState.CAPSIZING)
		Audio.PlayPrevMusic()
		Audio.StopFishingLoop()
		Fish.ResetFish()
		return

	# update hook position
	Hook.global_translation = Fish.global_translation

func SetFishingState(newState):
	fishingState = newState
	Events.emit_signal("ui_fishing_state_change", fishingState)
	
func SetBoatState(newBoatState):
	boatState = newBoatState
	Events.emit_signal("boat_state_changed", newBoatState)
	
func _on_reset_boat():
	ResetBoat()

func _on_caught_fish():
	Audio.PlayPrevMusic()
	var fishRarity = Fish.fishClassInstance.rarity
	Audio.PlaySplash(fishRarity)
	SetFishingState(G.FishingState.NOT_FISHING)
	SetBoatState(G.BoatState.CAUGHT_FISH)

func _on_PostCapsizeTimer_timeout():
	Events.emit_signal("transition", self, G.Screens.SHOP, '', '', 1.0, 1.0)
	SetBoatState(G.BoatState.FROZEN)

func _on_hooked_QTE_success():
	fishPullTemporaryStopTime = successQTEStopFishPullTime

func _on_post_supplies_select(aborted):
	if aborted:
		SetBoatState(G.BoatState.CRUISING)
		SetFishingState(G.FishingState.NOT_FISHING)
	else:
		SetBoatState(G.BoatState.CRUISING_TO_FISHING)

func _on_cannon_purchased():
	print('rock collision removed')
	self.set_collision_mask_bit(1, false)

func _on_eye_purchased():
	print('invisible wall collision removed')
	self.set_collision_mask_bit(2, false)
