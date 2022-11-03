extends Control

onready var CompassArrow = $CompassArrow
onready var Boat = $"../../Boat"
onready var ChestInstanceParent = $"../../WorldCollectableSpawns/ChestInstanceParent"

func _ready():
	self.visible = false

func _process(delta):
	if !P.upgrades[G.Upgrades.COMPASS]:
		return
	
	var chest = ChestInstanceParent.get_child(0)
	if chest != null:
		self.visible = true
		var boatVec = Boat.GetBoatFowardVector()
		var boatToChest = Boat.global_transform.origin - chest.global_transform.origin
		var diffVec = boatVec - boatToChest
		var compassVec = boatVec.signed_angle_to(diffVec, G.Y_AXIS)
		CompassArrow.rotation_degrees = -rad2deg(compassVec)
	else:
		self.visible = false
