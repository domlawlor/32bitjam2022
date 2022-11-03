extends Spatial

onready var GameplayUI = $GameplayScene/GameplayLayer
onready var TitleScene3D = $TitleScene
onready var TitleScene2D = $"TitleScene/2D"
onready var ShopScene3D = $ShopScene
onready var ShopScene2D = $"ShopScene/2D"
onready var BlockingUILayer = $BlockingUILayer
onready var TransitionLayer = $TransitionLayer

var layerMap = {} #populate in the ready function

func _ready():
	Events.connect("activate_screen", self, "_on_activate_screen")
	Events.connect("create_blocking_ui", self, "_on_create_blocking_ui")
	
	TransitionLayer.visible = true
	PopulateLayerMap()
	SetResolution()

func _exit():
	Events.disconnect("activate_screen", self, "_on_activate_screen")
	Events.disconnect("create_blocking_ui", self, "_on_create_blocking_ui")

func PopulateLayerMap():
	layerMap[G.Screens.TITLE] = { "3D" : TitleScene3D, "2D" : TitleScene2D }
	layerMap[G.Screens.SHOP] = { "3D" : ShopScene3D, "2D" : ShopScene2D }
	
func SetResolution():
	var native_screen = OS.get_screen_size()
	var max_scale_x = floor(native_screen.x / G.LOGICAL_RES.x)
	var max_scale_y = floor(native_screen.y / G.LOGICAL_RES.y)
	G.SCALE = 3

	var scaled_window = Vector2(G.LOGICAL_RES.x * G.SCALE, G.LOGICAL_RES.y * G.SCALE)
	OS.set_window_size(scaled_window)
	
	G.CentreGameWindow()

func SetScreenVisible(screenKey, show:bool):
	if screenKey == G.Screens.GAMEPLAY:
		GameplayUI.visible = show # never hide the gamplay 3D scene, only the UI layer
	else:
		var screenDict = layerMap[screenKey]
		screenDict["3D"].visible = show
		screenDict["2D"].visible = show
	
func ShowOneScreen(screenKey):
	var show = screenKey == G.Screens.GAMEPLAY
	SetScreenVisible(G.Screens.GAMEPLAY, show)
	if show:
		Audio.PlayBoatEngine(Audio.BoatEngine.IDLE)
	else:
		Audio.PlayBoatEngine(Audio.BoatEngine.STOP)
	
	show = screenKey == G.Screens.TITLE
	SetScreenVisible(G.Screens.TITLE, show)
	
	show = screenKey == G.Screens.SHOP
	SetScreenVisible(G.Screens.SHOP, show)

func _on_activate_screen(screenKey):
	ShowOneScreen(screenKey)
	Events.emit_signal("activate_camera", screenKey)
	G.activeScreen = screenKey

func _on_create_blocking_ui(uiType, params):
	var blockScreen
	if uiType == G.BlockingUITypes.SELECT_SUPPLIES:
		blockScreen = G.BlockingScreen_SelectSupplies.instance()
	elif uiType == G.BlockingUITypes.INVENTORY:
		blockScreen = G.BlockingScreen_Inventory.instance()
	elif uiType == G.BlockingUITypes.LOGBOOK:
		blockScreen = G.BlockingScreen_Logbook.instance()
	elif uiType == G.BlockingUITypes.CHEST_REWARD:
		blockScreen = G.BlockingScreen_ChestReward.instance()
	elif uiType == G.BlockingUITypes.FISH_SELL:
		blockScreen = G.BlockingScreen_FishSell.instance()
	BlockingUILayer.add_child(blockScreen)
	blockScreen.params = params
