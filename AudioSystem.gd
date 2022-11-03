extends Control

onready var Ambience = $Ambience

onready var MainTheme = $MainTheme
onready var CreepyWaters = $CreepyWaters
onready var FishingTheme = $FishingTheme
onready var ShopTheme = $ShopTheme
onready var MusicCrossfadeTimer = $MusicCrossfadeTimer

onready var BoatIdle = $BoatIdle
onready var BoatMove = $BoatMove
onready var HookDrop = $HookDrop
onready var ReelIn = $ReelIn
onready var Capsize = $Capsize
onready var FishingLoop = $FishingLoop
onready var QTESuccess = $QTESuccess
onready var QTEFail = $QTEFail
onready var Splash1 = $Splash1
onready var Splash2 = $Splash2
onready var Splash3 = $Splash3
onready var Splash4 = $Splash4
onready var PokeballShrink = $PokeballShrink
onready var BoatFadeTimer = $BoatMove/BoatFadeTimer

onready var CannonBlast = $CannonBlast
onready var RocksBreak = $RocksBreak
onready var RocksBreakTimer = $RocksBreakTimer

onready var GameStart = $GameStart
onready var UI_Select = $UI_Select
onready var UI_Purchase = $UI_Purchase
onready var UI_Invalid = $UI_Invalid
onready var UI_Scroll = $UI_Scroll
onready var UI_ScrollSwoosh = $UI_ScrollSwoosh
onready var UI_Back = $UI_Back

onready var ChestPickup = $ChestPickup
onready var QuestPickup = $QuestPickup

const SILENT_DB = -100
const STARTMIN_DB = -20
var MAINTHEME_MAX_DB = 0
var CREEPYWATERS_MAX_DB = 0
var FISHINGTHEME_MAX_DB = 0
var SHOPTHEME_MAX_DB = 0

var BOATIDLE_MAX_DB = -10
var BOATMOVE_MAX_DB = -12

enum MusicTrack {
	MAIN_THEME
	CREEPY_WATERS
	FISHING_THEME
	SHOP_THEME
}
var MusicTrackMap = {} # populate on ready
var MusicVolumeMap = {}

var gameMusicStarted = false
var currentTrack
var prevTrack

func _ready():
	Events.connect("activate_screen", self, "_on_activate_screen")
	Init()
	MainTheme.play()

func _exit():
	Events.disconnect("activate_screen", self, "_on_activate_screen")

func Init():
	MAINTHEME_MAX_DB = MainTheme.volume_db
	CREEPYWATERS_MAX_DB = CreepyWaters.volume_db
	FISHINGTHEME_MAX_DB = FishingTheme.volume_db
	SHOPTHEME_MAX_DB = ShopTheme.volume_db
	BOATIDLE_MAX_DB = BoatIdle.volume_db
	BOATMOVE_MAX_DB = BoatMove.volume_db
	
	MusicTrackMap = {
		MusicTrack.MAIN_THEME : MainTheme,
		MusicTrack.CREEPY_WATERS : CreepyWaters,
		MusicTrack.FISHING_THEME : FishingTheme,
		MusicTrack.SHOP_THEME : ShopTheme,
	}
	MusicVolumeMap = {
		MainTheme : MAINTHEME_MAX_DB,
		CreepyWaters : CREEPYWATERS_MAX_DB,
		FishingTheme : FISHINGTHEME_MAX_DB,
		ShopTheme : SHOPTHEME_MAX_DB,
	}
	
func StartGameMusic():
	if !gameMusicStarted:
		CreepyWaters.volume_db = SILENT_DB
		CreepyWaters.play()
		FishingTheme.volume_db = SILENT_DB
		FishingTheme.play()
		ShopTheme.volume_db = SHOPTHEME_MAX_DB
		ShopTheme.play()
		currentTrack = ShopTheme
		prevTrack = CreepyWaters
		gameMusicStarted = true

func PlayMusic(track):
	var trackAlreadyPlaying = MusicTrackMap[track].volume_db > MusicVolumeMap[currentTrack] - 0.1
	if !MusicCrossfadeTimer.is_stopped() or trackAlreadyPlaying:
		return
	prevTrack = currentTrack
	currentTrack = MusicTrackMap[track]
	MusicCrossfadeTimer.start()

func PlayPrevMusic():
	var temp = currentTrack
	currentTrack = prevTrack
	prevTrack = temp
	MusicCrossfadeTimer.start()

func StopAllMusic():
	MainTheme.stop()
	CreepyWaters.stop()
	FishingTheme.stop()
	ShopTheme.stop()

enum SFX {
	GAME_START
	HOOK_DROP
	REEL_IN
	CAPSIZE
	QTE_SUCCESS
	QTE_FAIL
	HOOK_DROP
	SPLASH1
	SPLASH2
	SPLASH3
	SPLASH4
	POKEBALL
	UI_SELECT
	UI_PURCHASE
	UI_INVALID
	UI_SCROLL
	UI_SCROLLSWOOSH
	UI_BACK
	CHESTPICKUP
	QUESTPICKUP
}

func PlaySFX(sfx):
	if (sfx == SFX.GAME_START):
		GameStart.play()
	elif (sfx == SFX.HOOK_DROP):
		HookDrop.play()
	elif (sfx == SFX.REEL_IN):
		ReelIn.play()
	elif (sfx == SFX.CAPSIZE):
		Capsize.play()
	elif (sfx == SFX.QTE_SUCCESS):
		QTESuccess.play()
	elif (sfx == SFX.QTE_FAIL):
		QTEFail.play()
	elif (sfx == SFX.SPLASH1):
		Splash1.play()
	elif (sfx == SFX.SPLASH2):
		Splash2.play()
	elif (sfx == SFX.SPLASH3):
		Splash3.play()
	elif (sfx == SFX.SPLASH4):
		Splash4.play()
	elif (sfx == SFX.POKEBALL):
		PokeballShrink.play()
	elif (sfx == SFX.UI_SELECT):
		UI_Select.play()
	elif (sfx == SFX.UI_PURCHASE):
		UI_Purchase.play()
	elif (sfx == SFX.UI_INVALID):
		UI_Invalid.play()
	elif (sfx == SFX.UI_SCROLL):
		UI_Scroll.play()
	elif (sfx == SFX.UI_SCROLLSWOOSH):
		UI_ScrollSwoosh.play()
	elif (sfx == SFX.UI_BACK):
		UI_Back.play()
	elif (sfx == SFX.CHESTPICKUP):
		ChestPickup.play()
	elif (sfx == SFX.QUESTPICKUP):
		QuestPickup.play()

func PlayFishingLoop():
	if !FishingLoop.playing:
		FishingLoop.play()
	
func StopFishingLoop():
	FishingLoop.stop()

func PlaySplash(fishRarity):
	StopFishingLoop()
	if fishRarity == G.FishRarity.COMMON:
		Splash1.play()
	elif fishRarity == G.FishRarity.UNCOMMON:
		Splash2.play()
	elif fishRarity == G.FishRarity.RARE:
		Splash3.play()
	elif fishRarity == G.FishRarity.MYTHIC:
		Splash4.play()

enum BoatEngine {
	IDLE
	MOVE
	STOP
}

func PlayBoatEngine(state):
	if state == BoatEngine.IDLE and !BoatIdle.playing:
		BoatIdle.play()
	elif (state == BoatEngine.MOVE):
		if !BoatMove.playing:
			BoatMove.play()
		BoatFadeTimer.start()

func PlayCannon():
	CannonBlast.play()
	RocksBreakTimer.start()
	
func _process(delta):
	if !gameMusicStarted:
		return
	
	var currentMaxVol = MusicVolumeMap[currentTrack]
	var prevMaxVol = MusicVolumeMap[prevTrack]
	if MusicCrossfadeTimer.is_stopped():
		currentTrack.volume_db = currentMaxVol
		prevTrack.volume_db = SILENT_DB
	else:
		var percent = MusicCrossfadeTimer.time_left / MusicCrossfadeTimer.wait_time
		var currentLerpAmount = range_lerp(percent, 0, 1, currentMaxVol, STARTMIN_DB)
		currentTrack.volume_db = currentLerpAmount
		var prevLerpAmount = range_lerp(percent, 0, 1, STARTMIN_DB, prevMaxVol)
		prevTrack.volume_db = prevLerpAmount
	
	if BoatFadeTimer.is_stopped():
		BoatMove.volume_db = SILENT_DB
		if G.activeScreen == G.Screens.SHOP:
			BoatIdle.volume_db = SILENT_DB
	else:
		var percent = BoatFadeTimer.time_left / BoatFadeTimer.wait_time
		var lerpAmount = range_lerp(percent, 0, 1, SILENT_DB, BOATMOVE_MAX_DB)
		BoatMove.volume_db = lerpAmount
		
		if G.activeScreen == G.Screens.SHOP:
			lerpAmount = range_lerp(percent, 0, 1, SILENT_DB, BOATIDLE_MAX_DB)
			BoatIdle.volume_db = lerpAmount
		else:
			BoatIdle.volume_db = BOATIDLE_MAX_DB

func _on_activate_screen(screen):
	if screen == G.Screens.GAMEPLAY:
		Ambience.play()
	elif screen == G.Screens.SHOP:
		Ambience.stop()
		BoatIdle.stop()


func _on_RocksBreakTimer_timeout():
	RocksBreak.play()
