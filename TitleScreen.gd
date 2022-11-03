extends Spatial

onready var Camera = $Camera

func _ready():
	Events.connect("activate_camera", self, "_on_activate_camera")

func _exit():
	Events.disconnect("activate_camera", self, "_on_activate_camera")
	
func _process(_delta):
	if G.activeScreen != G.Screens.TITLE:
		return
	
	if I.is_action_just_pressed("exit_title"):
		Audio.StopAllMusic()
		Audio.PlaySFX(Audio.SFX.GAME_START)
		Events.emit_signal("transition", self, G.Screens.GAMEPLAY)

func _on_activate_camera(screen):
	if screen == G.Screens.TITLE:
		Camera.make_current()
