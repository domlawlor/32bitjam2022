extends Control

onready var CargoWarning = $CargoWarning
onready var CargoWarningTimer = $CargoWarning/CargoTimer

onready var TooCloseToWallsWarning = $TooCloseToWallsWarning
onready var TooCloseToWallsWarningTimer = $TooCloseToWallsWarning/TooCloseToWallsTimer

func _ready():
	Events.connect("ui_alert_cargofull", self, "_on_ui_alert_cargofull")
	Events.connect("ui_alert_wallsToClose", self, "_on_ui_alert_wallsToClose")

func _exit():
	Events.disconnect("ui_alert_cargofull", self, "_on_ui_alert_cargofull")
	Events.disconnect("ui_alert_wallsToClose", self, "_on_ui_alert_wallsToClose")

func _on_activate_screen(screenKey):
	if screenKey == G.Screens.SHOP:
		CargoWarning.visible = false

func _on_ui_alert_cargofull():
	CargoWarning.visible = true
	CargoWarningTimer.start()

func _on_CargoTimer_timeout():
	CargoWarning.visible = false

func _on_ui_alert_wallsToClose():
	TooCloseToWallsWarning.visible = true
	TooCloseToWallsWarningTimer.start()

func _on_TooCloseToWallsTimer_timeout():
	TooCloseToWallsWarning.visible = false
