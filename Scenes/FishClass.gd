extends Spatial

enum FishRarity {
	COMMON
	UNCOMMON
	RARE
	MYTHIC
}

export(String) var speciesName = "Unnamed"
export(String) var speciesDescription = "It's a fish ok?"
export(FishRarity) var rarity = FishRarity.COMMON
export(int) var id = 0
export(float) var logbookCameraX = 2.0

export(int) var minPrice = 5
export(int) var maxPrice = 10

export(float) var minWeight = 1.0
export(float) var maxWeight = 2.0

export(float) var timeToReelIn = 8

export(float) var minTimeStaysInSpot = 1.0
export(float) var maxTimeStaysInSpot = 2.0

export(float) var minMoveToTargetPosTime = 1
export(float) var maxMoveToTargetPosTime = 2

export(float) var boatTippingAnglePerSec = 8.0

#export(float) var commentedOutVarForFixingVariablesBug = 0.0

export(float) var minDirectionAngleChange = 30
export(float) var maxDirectionAngleChange = 90

export(float) var justHookedTotalTime = 2.0

export(float) var preHookQTETimeLength = 1.5

export(float) var timeToHitQTE = 1.5
export(float) var minTimeBetweenQTE = 1.5
export(float) var maxTimeBetweenQTE = 3

export(PackedScene) var meshPackedScene = preload("res://Art/Fish/Common01.tscn")

var descriptiveName:String
var price:float
var weight:float

func _ready():
	assert(meshPackedScene, "Fish needs a mesh assigned")
	
	descriptiveName = FishVariants.GenerateName(speciesName, rarity)
	weight = rand_range(minWeight, maxWeight)
	price = range_lerp(weight, minWeight, maxWeight, minPrice, maxPrice)
