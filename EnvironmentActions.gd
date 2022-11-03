extends WorldEnvironment

const FOG_CLEAR := -1750.0
const FOG_HEAVY := 6.0
const FOG_LIGHT := -400.0

var inFog := false
var fogPercentage : float = 0
var fogRateOfChange := 0.3
var fogTotalUnits : float

func _ready():
	environment.fog_enabled = true
	Events.connect("activate_screen", self, "_on_activate_screen")
	Events.connect("flaming_skull_purchsed", self, "_on_flaming_skull_purchsed")
	fogTotalUnits = abs(FOG_CLEAR - FOG_HEAVY)

func _exit():
	Events.disconnect("activate_screen", self, "_on_activate_screen")
	Events.disconnect("flaming_skull_purchsed", self, "_on_flaming_skull_purchsed")

func _process(delta):
	if inFog:
		fogPercentage = min(1, fogPercentage + (fogRateOfChange * delta))
	else:
		fogPercentage = max(0, fogPercentage - (fogRateOfChange * delta))
	environment.fog_height_max = (fogTotalUnits * fogPercentage) + FOG_CLEAR

func _on_HeavyFog_body_entered(body):
	if body.is_in_group("boat"):
		inFog = true
		if !P.upgrades[G.Upgrades.FLAMINGSKULL]:
			Events.emit_signal("ui_fog_warning_change", inFog)

func _on_HeavyFog_body_exited(body):
	if body.is_in_group("boat"):
		inFog = false
		if !P.upgrades[G.Upgrades.FLAMINGSKULL]:
			Events.emit_signal("ui_fog_warning_change", inFog)

func _on_activate_screen(screenKey):
	inFog = false
	environment.fog_enabled = screenKey != G.Screens.SHOP

func _on_flaming_skull_purchsed():
	fogTotalUnits = abs(FOG_CLEAR - FOG_LIGHT)
