extends Control

export var gridPos : Vector2 = Vector2.ZERO
export var suppliesType : bool = true # false=upgrade
export var unlocked : bool = false
export var unlockProgression : int = 0
export var description : String = "This is an item."
export var price : int = 10
export var itemEnum : int = -1 # hard coded reference to G.enums.. gross, but gotta keep on truckin :)

onready var Highlight = $Highlight
onready var Selected = $Selected
onready var IconGFX = $IconGFX
onready var Quantity = $Quantity
onready var Price = $Price
onready var UpgradeOwned = $UpgradeOwned

var highlightable : bool = false
var selected : bool = false

func _ready():
	Events.connect("dehighlight_all", self, "_on_dehighlight_all")
	Events.connect("progress_made", self, "_on_progress_made")
	Price.text = "$ %d" % price
	unlocked = G.progression >= unlockProgression

func _exit():
	Events.disconnect("dehighlight_all", self, "_on_dehighlight_all")
	Events.disconnect("progress_made", self, "_on_progress_made")

func Highlight():
	Events.emit_signal("dehighlight_all", get_instance_id())
	assert(unlocked and highlightable)
	Highlight.visible = true
	return description

func SetHighlightableUpgrades(owned:bool):
	highlightable = unlocked
	SetHighlightableGraphics()
	UpgradeOwned.visible = unlocked and owned
	Price.visible = unlocked and !owned

func SetHighlightableSupplies(quantity:int):
	highlightable = unlocked
	SetHighlightableGraphics()
	Quantity.text = str(quantity) if unlocked else ''
	Price.visible = unlocked

func SetHighlightableInventory(owned:bool, quantity:int):
	highlightable = owned
	selected = false
	SetHighlightableGraphics()
	if quantity > 0:
		Quantity.text = str(quantity)
	Price.visible = false

func SetHighlightableGraphics():
	var c = 1 if highlightable else 0.2
	var a = 1 if highlightable else 0.2
	IconGFX.set_self_modulate(Color(c, c, c, a)) # using the self_modulate property didn't work here?!?!
	Selected.visible = selected

func ToggleSelected():
	selected = !selected
	SetHighlightableGraphics()
	return selected

func DoubleSize():
	rect_min_size = Vector2(60, 60)
	rect_size = Vector2(60, 60)
	IconGFX.rect_min_size = Vector2(60, 60)
	IconGFX.rect_size = Vector2(60, 60)
	
func _on_dehighlight_all(selfId):
	if get_instance_id() != selfId:
		Highlight.visible = false

func _on_progress_made(tier):
	if gridPos.y == tier:
		unlocked = true
