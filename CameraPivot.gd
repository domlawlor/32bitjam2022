extends Spatial

export var crusingAngleZ : float = 25
export var fishingAngleZ : float = 55

export var caughtFishAngleY : float = 180
export var caughtFishAngleZ : float = 21

var currentAngleY : float = 0.0
var currentAngleZ : float = 0.0

const ROTATE_SPEED := 1
var inFishingState = false

var debugRotateY := 0.0
var debugRotateZ := 0.0

var leftMouseDown := false
var lastMousePosition := Vector2.ZERO

var moveTween : SceneTreeTween
var moveTweenLength := 0.5

var rightStickYAngle := 0.0
var rightStickZAngle := 0.0

var maxRightStickYAngle := 90.0
var maxRightStickZAngle := 45.0

var rightStickYMoveAnglePerSec := 80
var rightStickZMoveAnglePerSec := 60

var revertRightStickYAnglePerSec := rightStickYMoveAnglePerSec / 1.5
var revertRightStickZAnglePerSec := rightStickZMoveAnglePerSec / 2.5

func _ready():
	Events.connect("boat_state_changed", self, "_on_boat_state_changed")
	
	currentAngleY = 0.0
	currentAngleZ = crusingAngleZ
	
func _exit():
	Events.disconnect("boat_state_changed", self, "_on_boat_state_changed")

func _on_boat_state_changed(boatState):
	if(boatState == G.BoatState.FISHING or
		boatState == G.BoatState.CRUISING_TO_FISHING or
		boatState == G.BoatState.FISHING_TO_CRUISING):
		#currentAngleY = 0.0
		#currentAngleZ = fishingAngleZ
		
		moveTween = create_tween().set_trans(Tween.TRANS_LINEAR)
		moveTween.tween_property(self, "currentAngleY", 0.0, moveTweenLength)
		moveTween.parallel().tween_property(self, "currentAngleZ", fishingAngleZ, moveTweenLength)
		
	elif boatState == G.BoatState.CAUGHT_FISH:
		#currentAngleY = caughtFishAngleY
		#currentAngleZ = caughtFishAngleZ
		
		moveTween = create_tween().set_trans(Tween.TRANS_LINEAR)
		moveTween.tween_property(self, "currentAngleY", caughtFishAngleY, moveTweenLength)
		moveTween.parallel().tween_property(self, "currentAngleZ", caughtFishAngleZ, moveTweenLength)
	else:
		#currentAngleY = 0.0
		#currentAngleZ = crusingAngleZ
		
		moveTween = create_tween().set_trans(Tween.TRANS_LINEAR)
		moveTween.tween_property(self, "currentAngleY", 0.0, moveTweenLength)
		moveTween.parallel().tween_property(self, "currentAngleZ", crusingAngleZ, moveTweenLength)

func _physics_process(delta):
	var rotateY := deg2rad(currentAngleY)
	var rotateZ := deg2rad(currentAngleZ)
	
	# Right stick camera movement
	var upDownInput = I.get_axis("modelrotate_down", "modelrotate_up")
	var leftRightInput = I.get_axis("modelrotate_left", "modelrotate_right")
		
	
	if G.debugActive:
		if Input.is_mouse_button_pressed(BUTTON_LEFT):
			var prevDown = leftMouseDown
			leftMouseDown = true
			
			var mousePos = get_viewport().get_mouse_position()
			
			if !prevDown:
				lastMousePosition = mousePos
				debugRotateZ = rotateZ
			
			var mouseDelta = mousePos - lastMousePosition
			
			debugRotateY -= mouseDelta.x * ROTATE_SPEED * delta
			debugRotateZ += mouseDelta.y * ROTATE_SPEED * delta
			
			
			lastMousePosition = mousePos
		else:
			leftMouseDown = false 
		
		rotateY = debugRotateY
		rotateZ = debugRotateZ
	elif upDownInput != 0.0 or leftRightInput != 0:
		
		rightStickYAngle += leftRightInput * rightStickYMoveAnglePerSec * delta
		rightStickYAngle = clamp(rightStickYAngle, -maxRightStickYAngle, maxRightStickYAngle)
		
		rightStickZAngle += upDownInput * rightStickZMoveAnglePerSec * delta
		rightStickZAngle = clamp(rightStickZAngle, -maxRightStickZAngle, maxRightStickZAngle)
	
	elif rightStickYAngle != 0 or rightStickZAngle != 0:
		
		if rightStickYAngle != 0.0:
			var yNegative = rightStickYAngle < 0
			if yNegative:
				rightStickYAngle += revertRightStickYAnglePerSec * delta
			else:
				rightStickYAngle -= revertRightStickYAnglePerSec * delta
			
			if rightStickYAngle > 0 and yNegative or rightStickYAngle < 0 and !yNegative:
				rightStickYAngle = 0.0
				
		if rightStickZAngle != 0.0:
			var zNegative = rightStickZAngle < 0
			if zNegative:
				rightStickZAngle += revertRightStickZAnglePerSec * delta
			else:
				rightStickZAngle -= revertRightStickZAnglePerSec * delta
			
			if rightStickZAngle > 0 and zNegative or rightStickZAngle < 0 and !zNegative:
				rightStickZAngle = 0.0
			
		
	
	rotateY += deg2rad(rightStickYAngle)
	rotateZ += deg2rad(rightStickZAngle)
	
	rotateZ = clamp(rotateZ, 0.0, deg2rad(179))
	

	transform.basis = Basis() # reset rotation
	rotate_object_local(Vector3(0, 1, 0), rotateY)
	rotate_object_local(Vector3(0, 0, 1), rotateZ)
