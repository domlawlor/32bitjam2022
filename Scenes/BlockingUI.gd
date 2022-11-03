extends Control

onready var DelayExitTimer = $DelayExitTimer

var params = {}

func _ready():
	Events.connect("blocking_ui_exit", self, "_on_blocking_ui_exit")
	
	get_tree().paused = true

func _exit():
	Events.disconnect("blocking_ui_exit", self, "_on_blocking_ui_exit")

func _on_blocking_ui_exit():
	DelayExitTimer.start()

func _on_DelayExitTimer_timeout():
	get_tree().paused = false
	queue_free()
