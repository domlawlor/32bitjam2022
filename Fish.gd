extends Spatial

export(float) var justHookTimeToTarget = 1.5

export(float) var fishCaughtLineLength = 2.0
export(float) var reelInPercentReducedOnHittingQTE = 0.1

export(float) var totalTimeReelSpeedOnQTESuccess = 0.5

export(float) var jiggleAngleMinMax = 15.0
export(float) var jiggleAnglePerSec = 25.0

enum FishState {
	NOT_HOOKED = 0,
	JUST_HOOKED,
	HOOKED_IN_SPOT,
	HOOKED_MOVING,
	CAUGHT,
}
var fishState = FishState.NOT_HOOKED

var currentTimeToReelIn := 0.0
var totalTimeToReelIn := 0.0

var fishTimeLeftInSpot := 0.0

var currentPosAngle := 0.0
var jiggleAngle := 0.0
var targetPosAngle := 0.0
var lastTargetPosAngle := 0.0

var finalPosAngle := 0.0

var jiggleGoingUp = false

var currentTimeToTargetPosAngle := 0.0
var totalTimeToTargetPosAngle := 0.0

var currentLineLength := 0.0
var fishingLineTotalLength := 0.0

var fishIsPulling := true

var QTEActive := false
var activeQTEButton = G.QTE_Button.NONE
var timeUntilNextQTE := 0.0
var activeQTETimeLeft := 0.0

var QTESuccessReelSpeedUpTimeLeft = 0.0

# holds the fishClass
var fishClassInstance : Spatial = null

# parent boat
onready var Boat : KinematicBody = get_parent()

# Initial hook, we should lerp fish from hook spot to position first
# then hold a spot for a time before moving
# moving is capped by an angle amount. no more than 180 degrees
# it doesn't always have to be at the max line length either. This will add some variety in the angle of the line in the water 

func _ready():
	ResetFish()

func ResetFish():
	fishState = FishState.NOT_HOOKED
	currentTimeToReelIn = 0.0
	
	fishTimeLeftInSpot = 0.0
	currentPosAngle = 0.0
	targetPosAngle = 0.0
	lastTargetPosAngle = 0.0
	currentTimeToTargetPosAngle = 0.0
	totalTimeToTargetPosAngle = 0.0
	
	finalPosAngle = 0.0
	
	currentLineLength = 0.0
	fishingLineTotalLength = 0.0
	
	#fishIsPulling = false
	
	QTESuccessReelSpeedUpTimeLeft = 0.0
	
	QTEActive = false
	activeQTEButton = G.QTE_Button.NONE
	timeUntilNextQTE = 0.0
	activeQTETimeLeft = 0.0

	fishClassInstance = null # also a child, so cleaned up below
	
	ResetQTE()
	
	# first remove all existing children
	for childNode in get_children():
		childNode.queue_free()

func _physics_process(delta):
	if fishState == FishState.JUST_HOOKED:
		JustHookedUpdate(delta)
	elif fishState == FishState.HOOKED_IN_SPOT or fishState == FishState.HOOKED_MOVING:
		OnHookUpdate(delta)

func GetFishUnitVector():
	var vector = Boat.craneInitialBasis.x.rotated(G.Y_AXIS, finalPosAngle)
	return vector

func JustHookedUpdate(delta):
	var lerpPercent = min(currentTimeToTargetPosAngle / totalTimeToTargetPosAngle, 1.0)
	currentTimeToTargetPosAngle += delta
	
	# lerp the fishingLineDistance and angle
	currentLineLength = lerp(fishCaughtLineLength, fishingLineTotalLength, lerpPercent)
	currentPosAngle = lerp_angle(lastTargetPosAngle, targetPosAngle, lerpPercent)
	
	finalPosAngle = currentPosAngle # no jiggle on just hooked state
	
	# calculate fish position and update
	var initialVec = Boat.GetCraneInitialDirectionVector()
	var rotatedVec = initialVec.rotated(G.Y_AXIS, finalPosAngle)
	var fishVector = rotatedVec * currentLineLength
	fishVector.y = Boat.hookUnderWaterYPos
	
	global_translation = Boat.global_translation + fishVector
	
	if lerpPercent == 1.0:
		fishState = FishState.HOOKED_IN_SPOT
		Audio.PlayFishingLoop()

func ResetQTE():
	QTEActive = false
	activeQTEButton = G.QTE_Button.NONE
	Events.emit_signal("hide_hooked_QTE")

func OnHookQTEUpdate(delta):
	if Boat.boatState != G.BoatState.FISHING:
		return
	
	if QTEActive:
		var qteButtons = I.GetQTEInput()
		var hasQTEInput = qteButtons.size() > 0

		if hasQTEInput or activeQTETimeLeft <= 0.0:
			var singleButtonPressed = qteButtons.size() == 1
			var correctQTE = singleButtonPressed and qteButtons.has(activeQTEButton)
			
			QTEActive = false
			
			timeUntilNextQTE = rand_range(fishClassInstance.minTimeBetweenQTE, fishClassInstance.maxTimeBetweenQTE)
			activeQTEButton = G.QTE_Button.NONE
			
			Events.emit_signal("hide_hooked_QTE")
			
			if correctQTE:
				#currentTimeToReelIn -= reelInPercentReducedOnHittingQTE * fishClassInstance.timeToReelIn
				QTESuccessReelSpeedUpTimeLeft = totalTimeReelSpeedOnQTESuccess
				Audio.PlaySFX(Audio.SFX.QTE_SUCCESS)
				Events.emit_signal("hooked_QTE_success")
			else:
				#Audio.PlaySFX(Audio.SFX.QTE_FAIL)
				pass
		else:
			activeQTETimeLeft -= delta
	else:
		if timeUntilNextQTE <= 0.0:
			# if under this time to reelin value, then don't run a qte
			var blockQTEUnderTimeToReelInPercent = reelInPercentReducedOnHittingQTE * fishClassInstance.timeToReelIn
			var reelInPerecent = min(currentTimeToReelIn / fishClassInstance.timeToReelIn, 1.0)
			
			if reelInPerecent <= blockQTEUnderTimeToReelInPercent:
				var possibleButtons = G.rarietyToQTEButtons[fishClassInstance.rarity]
				
				activeQTEButton = possibleButtons[randi() % possibleButtons.size()]
				
				activeQTETimeLeft = fishClassInstance.timeToHitQTE
				QTEActive = true
				Events.emit_signal("show_hooked_QTE", activeQTEButton)
		else:
			timeUntilNextQTE -= delta

func OnHookUpdate(delta):
	currentTimeToReelIn -= delta
	
	if QTESuccessReelSpeedUpTimeLeft > 0.0:
		QTESuccessReelSpeedUpTimeLeft = max(QTESuccessReelSpeedUpTimeLeft - delta, 0.0)
		currentTimeToReelIn -= delta # double speed by applying again
	
	if currentTimeToReelIn <= 0.0:
		currentTimeToReelIn = 0.0
		fishState = FishState.CAUGHT
		
		ResetQTE()
		Events.emit_signal("caught_fish")
		
		return
	
	OnHookQTEUpdate(delta)
	
	# moving and staying in one spot is seperate of the minigame to bring in the fish
	if fishState == FishState.HOOKED_MOVING:
		var percentToTarget = min(currentTimeToTargetPosAngle / totalTimeToTargetPosAngle, 1.0)
		currentTimeToTargetPosAngle += delta # advance time after getting the lerp weight
		
		# update angle here
		currentPosAngle = lerp_angle(lastTargetPosAngle, targetPosAngle, percentToTarget)
	
		if percentToTarget == 1.0:
			var minTimeStayInSpot = fishClassInstance.minTimeStaysInSpot
			var maxTimeStayInSpot = fishClassInstance.maxTimeStaysInSpot
			
			var narcolepsyPotionUsed = P.activeSupplies[G.Supplies.NARCOLEPSY]
			if narcolepsyPotionUsed:
				# push the time up by a proportional amount
				var timeDifference = maxTimeStayInSpot - minTimeStayInSpot
				var timeToChange = timeDifference / 8
				minTimeStayInSpot += timeToChange
				maxTimeStayInSpot += timeToChange
			
			fishTimeLeftInSpot = rand_range(minTimeStayInSpot, maxTimeStayInSpot)
			fishState = FishState.HOOKED_IN_SPOT
			
	elif fishState == FishState.HOOKED_IN_SPOT:
		if fishTimeLeftInSpot < 0:
			FindNewSpotToMoveTo()
			fishState = FishState.HOOKED_MOVING
		else:
			fishTimeLeftInSpot -= delta

	if jiggleGoingUp:
		jiggleAngle += jiggleAnglePerSec * delta
		if jiggleAngle >= jiggleAngleMinMax:
			jiggleGoingUp = false
	else:
		jiggleAngle -= jiggleAnglePerSec * delta
		if jiggleAngle <= -jiggleAngleMinMax:
			jiggleGoingUp = true
	
	finalPosAngle =  currentPosAngle + deg2rad(jiggleAngle)
	
	var timeLeftPercent = currentTimeToReelIn / fishClassInstance.timeToReelIn
	var lineLength = lerp(fishCaughtLineLength, fishingLineTotalLength, timeLeftPercent)
	
	
	
	# calculate fish position and update
	var initialVec = Boat.GetCraneInitialDirectionVector()
	var rotatedVec = initialVec.rotated(G.Y_AXIS, finalPosAngle)
	var fishVector = rotatedVec * lineLength
	fishVector.y = Boat.hookUnderWaterYPos
	
	global_translation = Boat.global_translation + fishVector


func OnPreHook(boatPosition, hookPosition):
	var fishType = FishVariants.SelectRandomFishType()	
	SetupFish(fishType)	
	ApplyItemsToFishStats()
	
func SetHooked(preHookTiming):
	targetPosAngle = rand_range(-PI, PI)
	
	jiggleAngle = 0.0
	jiggleGoingUp = true
	
	currentTimeToTargetPosAngle = 0.0
	totalTimeToTargetPosAngle = justHookTimeToTarget
	
	totalTimeToReelIn = fishClassInstance.timeToReelIn
	
	if preHookTiming == G.PreHookTiming.PERFECT:
		totalTimeToReelIn -= totalTimeToReelIn / 4
	elif preHookTiming == G.PreHookTiming.GOOD:
		totalTimeToReelIn -= totalTimeToReelIn / 6
	elif preHookTiming == G.PreHookTiming.OKAY:
		totalTimeToReelIn -= totalTimeToReelIn / 8
		
	currentTimeToReelIn = totalTimeToReelIn
	
	
	
	fishingLineTotalLength = Boat.fishingLineLengthAtMaxReelInTime
	
	timeUntilNextQTE = rand_range(fishClassInstance.minTimeBetweenQTE, fishClassInstance.maxTimeBetweenQTE)
	
	fishState = FishState.JUST_HOOKED

func SetupFish(fishType):
	ResetFish()
	
	fishClassInstance = FishVariants.GetFishNodeInstance(fishType)
	add_child(fishClassInstance)
	
	# get the mesh first and add as child
	var meshInst = fishClassInstance.meshPackedScene.instance()
	add_child(meshInst)

func ApplyItemsToFishStats():
	# Time to Reel in Changing items
	# draining orb decreasing fish starting reel in time
	var uncommonDrainingOrbUsed = P.activeSupplies[G.Supplies.ORB_UNCOMMON]
	var rareDrainingOrbUsed = P.activeSupplies[G.Supplies.ORB_RARE]
	var mythicDrainingOrbUsed = P.activeSupplies[G.Supplies.ORB_MYTHIC]
	
	# Essentially, each stack of an item will reduce by multiplying 0.75
	# eg. if uncommon totalTimeToReelIn is 15, 1 stack is 11.25, 2 stacks is 8.4375, 3 stacks is 6.328125
	# rare only stacks a max of two times
	# mythic can only have one stack
	if mythicDrainingOrbUsed:
		totalTimeToReelIn -= (totalTimeToReelIn / 4)
	
	if rareDrainingOrbUsed:
		if fishClassInstance.rarity != G.FishRarity.MYTHIC:
			totalTimeToReelIn -= (totalTimeToReelIn / 4)
	
	if uncommonDrainingOrbUsed:
		if fishClassInstance.rarity != G.FishRarity.MYTHIC or fishClassInstance.rarity != G.FishRarity.RARE:
			totalTimeToReelIn -= (totalTimeToReelIn / 4)

func FindNewSpotToMoveTo():
	lastTargetPosAngle = targetPosAngle
	
	var minAngleChange = fishClassInstance.minDirectionAngleChange
	var maxAngleChange = fishClassInstance.maxDirectionAngleChange
	
	var minMoveToTargetTime = fishClassInstance.minMoveToTargetPosTime
	var maxMoveToTargetTime = fishClassInstance.maxMoveToTargetPosTime
	
	var narcolepsyPotionUsed = P.activeSupplies[G.Supplies.NARCOLEPSY]
	if narcolepsyPotionUsed:
		# make the angle varience smaller 
		var angleDifference = maxAngleChange - minAngleChange
		var angleAmountToChange = angleDifference / 8
		minAngleChange += angleAmountToChange
		maxAngleChange -= angleAmountToChange
		
		# push the time up by a proportional amount
		var timeDifference = maxMoveToTargetTime - minMoveToTargetTime
		var timeAmountToChange = timeDifference / 8
		minMoveToTargetTime += timeAmountToChange
		maxMoveToTargetTime += timeAmountToChange
		
	
	var angleChange = rand_range(minAngleChange, maxAngleChange)
	var angleChangeRadians = deg2rad(angleChange)
	var antiClockwise = (randi() % 2) == 0 # 50/50 between clockwise or anticlockwise
	
	if antiClockwise:
		targetPosAngle -= angleChangeRadians
	else:
		targetPosAngle += angleChangeRadians
	
	targetPosAngle = wrapf(targetPosAngle, -PI, PI)
	
	currentTimeToTargetPosAngle = 0.0
	totalTimeToTargetPosAngle = rand_range(minMoveToTargetTime, maxMoveToTargetTime)
	
	#print("-- findNewSpot --")
	#print("lastTargetPosAngle - ", rad2deg(lastTargetPosAngle), ", targetPosAngle - ", rad2deg(targetPosAngle))
