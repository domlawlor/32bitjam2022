extends Node

onready var Cargo = $Cargo

const normalCargoLimit = 50
const extraCargoLimit = 200

# Stats / Inventory
var money = 0

# Upgrades
var upgrades = {
	G.Upgrades.ANCHOR : false,
	G.Upgrades.FLAMINGSKULL : false,
	G.Upgrades.CARGO : false,
	G.Upgrades.CANNON : false,
	G.Upgrades.COMPASS : false,
	G.Upgrades.BIGHOOK : false,
	G.Upgrades.DETECTOR : false,
	G.Upgrades.EYE : false,
}

# Supplies
var supplies = {
	G.Supplies.CHUM_UNCOMMON : 0,
	G.Supplies.ORB_UNCOMMON : 0,
	G.Supplies.NARCOLEPSY : 0,
	G.Supplies.WILLPOWER : 0,
	G.Supplies.CHUM_RARE : 0,
	G.Supplies.ORB_RARE : 0,
	G.Supplies.LINE_RARE : 0,
	G.Supplies.CROWN : 0,
	G.Supplies.CHUM_MYTHIC : 0,
	G.Supplies.ORB_MYTHIC : 0,
	G.Supplies.LINE_MYTHIC : 0,
}

# Quest
var quest = [
	false, # 0
	false, # 1
	false, # 2
]

# Active supplies (chosen for the following fishing encounter)
var activeSupplies = {}
func ResetActiveSupplies():
	activeSupplies = {
		G.Supplies.CHUM_UNCOMMON : false,
		G.Supplies.ORB_UNCOMMON : false,
		G.Supplies.NARCOLEPSY : false,
		G.Supplies.WILLPOWER : false,
		G.Supplies.CHUM_RARE : false,
		G.Supplies.ORB_RARE : false,
		G.Supplies.LINE_RARE : false,
		G.Supplies.CROWN : false,
		G.Supplies.CHUM_MYTHIC : false,
		G.Supplies.ORB_MYTHIC : false,
		G.Supplies.LINE_MYTHIC : false,
	}

func _ready():
	Events.connect("ui_show_caught_fish", self, "_on_ui_show_caught_fish")
	ResetActiveSupplies()

func _exit():
	Events.disconnect("ui_show_caught_fish", self, "_on_ui_show_caught_fish")

func HaveNoSupplies():
	return P.supplies[G.Supplies.CHUM_UNCOMMON] == 0 and \
		P.supplies[G.Supplies.ORB_UNCOMMON] == 0 and \
		 P.supplies[G.Supplies.NARCOLEPSY] == 0 and \
		 P.supplies[G.Supplies.WILLPOWER] == 0 and \
		 P.supplies[G.Supplies.CHUM_RARE] == 0 and \
		 P.supplies[G.Supplies.ORB_RARE] == 0 and \
		 P.supplies[G.Supplies.LINE_RARE] == 0 and \
		 P.supplies[G.Supplies.CROWN] == 0 and \
		 P.supplies[G.Supplies.CHUM_MYTHIC] == 0 and \
		 P.supplies[G.Supplies.ORB_MYTHIC] == 0 and \
		 P.supplies[G.Supplies.LINE_MYTHIC] == 0

# Fish cargo
func AddFishToCargo(fishInstance):
	var weight = fishInstance.weight
	var price = fishInstance.price
	var fishInst = fishInstance.duplicate()
	Cargo.add_child(fishInst)
	fishInst.weight = weight
	fishInst.price = price
	var totalCargoWeight = GetCargoWeight()
	print('fish caught! weight=%f  cargoWeight=%f' % [fishInst.weight, totalCargoWeight])
	if totalCargoWeight >= GetCargoLimit():
		print("cargo limit reached!!")

func AddFishTypeToCargo(fishType):
	var fishInst = FishVariants.GetFishNodeInstance(fishType)
	AddFishToCargo(fishInst)

func GetCargoLimit():
	if upgrades[G.Upgrades.CARGO]:
		return extraCargoLimit
	else:
		return normalCargoLimit

func GetCargoWeight():
	var totalWeight: float = 0
	for child in Cargo.get_children():
		totalWeight += child.weight
	return totalWeight

func IsCargoFull():
	return GetCargoWeight() >= GetCargoLimit()

func PrintCargo():
	var count = 1
	print("Cargo contents:\n---")
	for fish in Cargo.get_children():
		print("%d: %s - Weight: %.1fkg, Value: $%.2f" % [count, fish.descriptiveName, fish.weight, fish.price])
		count += 1

func SellCargo():
	var params = { "fish" : [] }
	var cargoValue: float = 0
	for fish in Cargo.get_children():
		cargoValue += fish.price
		Cargo.remove_child(fish)
		params.fish.push_back(fish)
	
	if params.fish.size() > 0:
		Events.emit_signal("create_blocking_ui", G.BlockingUITypes.FISH_SELL, params)
		ChangeMoney(cargoValue)
		print("money: $%.2f" % money)

func ClearCargo():
	for fish in Cargo.get_children():
		Cargo.remove_child(fish)
		fish.queue_free()
	
func ChangeMoney(amount):
	money += amount

# fish stats
var fishStats = {
	FishVariants.FishType.COMMON_1 : {
		"caught" : 0,
		"pb" : 0.0,
	},
	FishVariants.FishType.COMMON_2 : {
		"caught" : 0,
		"pb" : 0.0,
	},
	FishVariants.FishType.COMMON_3 : {
		"caught" : 0,
		"pb" : 0.0,
	},
	FishVariants.FishType.COMMON_4 : {
		"caught" : 0,
		"pb" : 0.0,
	},
	FishVariants.FishType.COMMON_5 : {
		"caught" : 0,
		"pb" : 0.0,
	},
	FishVariants.FishType.UNCOMMON_1 : {
		"caught" : 0,
		"pb" : 0.0,
	},
	FishVariants.FishType.UNCOMMON_2 : {
		"caught" : 0,
		"pb" : 0.0,
	},
	FishVariants.FishType.UNCOMMON_3 : {
		"caught" : 0,
		"pb" : 0.0,
	},
	FishVariants.FishType.UNCOMMON_4 : {
		"caught" : 0,
		"pb" : 0.0,
	},
	FishVariants.FishType.RARE_1 : {
		"caught" : 0,
		"pb" : 0.0,
	},
	FishVariants.FishType.RARE_2 : {
		"caught" : 0,
		"pb" : 0.0,
	},
	FishVariants.FishType.RARE_3 : {
		"caught" : 0,
		"pb" : 0.0,
	},
	FishVariants.FishType.MYTHIC_1 : {
		"caught" : 0,
		"pb" : 0.0,
	},
	FishVariants.FishType.MYTHIC_2 : {
		"caught" : 0,
		"pb" : 0.0,
	},
}

func _on_ui_show_caught_fish(fishNode):
	var fishInst = fishNode.fishClassInstance
	var stat = fishStats[fishInst.id]
	stat.caught += 1
	if stat.pb < fishInst.weight:
		stat.pb = fishInst.weight
	if fishInst.id == FishVariants.FishType.MYTHIC_1: #the quest fish has been caught!
		P.quest[2] = true
