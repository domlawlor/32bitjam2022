extends Camera

export var moveSpeedCurve : Curve
export var maxSpeedDistance = 2.0

onready var Boat : KinematicBody = get_parent()
onready var CameraTargetPos : Position3D = get_node("../CameraPivot/SpringArm/CameraTargetPos")

var targetPos : Vector3

func _ready():
	set_as_toplevel(true)
	assert(moveSpeedCurve)
	assert(CameraTargetPos)

func _physics_process(delta):
	
	var newTargetPos = CameraTargetPos.global_translation
	if targetPos != newTargetPos:
		targetPos = newTargetPos
	
	var currentPos = global_translation
	
	if !currentPos.is_equal_approx(targetPos):
		var distance = currentPos.distance_to(targetPos)
		var moveSpeedPercent = min(distance / maxSpeedDistance, 1.0)
		var speed = moveSpeedCurve.interpolate(moveSpeedPercent)
		
		global_translation = currentPos.linear_interpolate(targetPos, speed)

	# where ever the camera is, we still point it towards the boat
	look_at(Boat.translation, Vector3.UP)

func SetCameraPosition(position):
	translation = position
	targetPos = position
