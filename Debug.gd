extends Control

onready var ActiveLabel = $ActiveLabel

const DEBUG_FADE = 0.3

func _ready():
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), !G.AUDIO_ENABLED)

func _process(_delta):	
	# toggle debug mode
	if (Input.is_action_just_pressed("debug_f9") and Input.is_action_pressed("debug_f12")) or \
			(Input.is_action_just_pressed("debug_f12") and Input.is_action_pressed("debug_f9")):
		G.debugActive = !G.debugActive
		ActiveLabel.visible = G.debugActive
		
	if !G.debugActive:
		return
	
	# enable / disable audio
	if Input.is_action_just_pressed("debug_f11"):
		G.AUDIO_ENABLED = !G.AUDIO_ENABLED
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), !G.AUDIO_ENABLED)
		
	# activate gameplay scene
	elif Input.is_action_just_pressed("debug_f1"):
		Events.emit_signal("transition", self, G.Screens.GAMEPLAY, '', '', DEBUG_FADE, DEBUG_FADE)
	
	# activate title scene
	elif Input.is_action_just_pressed("debug_f2"):
		Events.emit_signal("transition", self, G.Screens.TITLE, '', '', DEBUG_FADE, DEBUG_FADE)
		
	# activate shop scene
	elif Input.is_action_just_pressed("debug_f3"):
		Events.emit_signal("transition", self, G.Screens.SHOP, '', '', DEBUG_FADE, DEBUG_FADE)
	
	# activate logbook scene
	elif Input.is_action_just_pressed("debug_f4"):
		Events.emit_signal("create_blocking_ui", G.BlockingUITypes.LOGBOOK)
	
	# put fish in cargohold
	elif Input.is_action_just_pressed("debug_f5"):
		if Input.is_action_pressed("debug_left_shift"):
			FishVariants.SelectRandomFishType()
		else:
			var fishType = randi() % 9
			P.AddFishTypeToCargo(fishType)
	
	# force progression
	elif Input.is_action_just_pressed("debug_f6"):
		if G.progression < 3:
			G.MakeProgress()
			print("progression tier: %d" % G.progression)
	
	# obtain current quest item
	elif Input.is_action_just_pressed("debug_f7"):
		if G.progression < 3:
			P.quest[G.progression] = true
			print("quest item gained for progression tier: %d" % G.progression)
