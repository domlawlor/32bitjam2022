extends Spatial

onready var Black = $Black

const GAME_START_FADETIME = 1.5
const DEFAULT_FADETIME = 1.0

enum State {
	IDLE
	FADEOUT # towards black
	FADEIN  # towards transparent
}
var state = State.FADEOUT

var currentTransitionTime : float = GAME_START_FADETIME
var targetTransitionTime : float = GAME_START_FADETIME
var targetFadeinTime : float = GAME_START_FADETIME

var requester
var newScreen = G.Screens.TITLE
var fadeoutCallback = ''
var fadeinCallback = ''

func _ready():
	Events.connect("transition", self, "_on_transition")

func _exit():
	Events.disconnect("transition", self, "_on_transition")
	
func _process(delta):
	var norm
	var done = false
	if state != State.IDLE:
		currentTransitionTime = min(currentTransitionTime + delta, targetTransitionTime)
		norm = G.NormalizeLerp(0.0, targetTransitionTime, currentTransitionTime)
		done = currentTransitionTime == targetTransitionTime
	
	if state == State.FADEOUT:
		Black.modulate.a = norm
		if done:
			if fadeoutCallback != '':
				requester.call(fadeoutCallback)
			Events.emit_signal("activate_screen", newScreen)
			currentTransitionTime = 0.0
			targetTransitionTime = targetFadeinTime
			state = State.FADEIN
	elif state == State.FADEIN:
		Black.modulate.a = 1 - norm
		if done:
			if fadeinCallback != '':
				requester.call(fadeinCallback)
			currentTransitionTime = 0.0
			state = State.IDLE
			G.transitionActive = false
	
	if currentTransitionTime == targetTransitionTime:
		state = State.IDLE

func _on_transition(requester, newScreen, fadeoutCallback='', fadeinCallback='', fadeoutTime=DEFAULT_FADETIME, fadeinTime=DEFAULT_FADETIME):
	self.requester = requester
	self.newScreen = newScreen
	self.currentTransitionTime = 0.0
	self.targetTransitionTime = fadeoutTime
	self.targetFadeinTime = fadeinTime
	self.fadeoutCallback = fadeoutCallback
	self.fadeinCallback = fadeinCallback
	self.state = State.FADEOUT
	G.transitionActive = true
