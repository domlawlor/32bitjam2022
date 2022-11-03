extends Spatial

enum FishType {
	COMMON_1
	COMMON_2
	COMMON_3
	COMMON_4
	COMMON_5
	UNCOMMON_1
	UNCOMMON_2
	UNCOMMON_3
	UNCOMMON_4
	RARE_1
	RARE_2
	RARE_3
	MYTHIC_1
	MYTHIC_2
}

var fishByRariety = {
	G.FishRarity.COMMON: [],
	G.FishRarity.UNCOMMON: [],
	G.FishRarity.RARE: [],
	G.FishRarity.MYTHIC: [],
}

func _ready():
	for fishType in FishType.values():
		var fishClass = get_child(fishType)
		var rariety = fishClass.rarity
		fishByRariety[rariety].push_back(fishType)

func GetFishNodeInstance(fishType):
	return get_child(fishType).duplicate()

func GenerateName(speciesName, rarity):
	var prefix
	match (rarity):
		G.FishRarity.COMMON:
			prefix = "A common "
		G.FishRarity.UNCOMMON:
			prefix = "An uncommon "
		G.FishRarity.RARE:
			prefix = "A rare "
		G.FishRarity.MYTHIC:
			prefix = "A one of a kind "
	
	return prefix + speciesName

var zoneChances = {
	G.FishingZone.COMMON : {
		"noBigHook" : {
			"common" : 0.7,
			"uncommon" : 0.25,
			"rare" : 0.05,
			"mythic" : 0.0,
		},
		"bigHook" : {
			"common" : 0.55,
			"uncommon" : 0.3,
			"rare" : 0.10,
			"mythic" : 0.05,
		},
	},
	G.FishingZone.UNCOMMON : {
		"noBigHook" : {
			"common" : 0.45,
			"uncommon" : 0.5,
			"rare" : 0.05,
			"mythic" : 0.0,
		},
		"bigHook" : {
			"common" : 0.35,
			"uncommon" : 0.5,
			"rare" : 0.10,
			"mythic" : 0.05,
		},
	},
	G.FishingZone.RARE : {
		"noBigHook" : {
			"common" : 0.5,
			"uncommon" : 0.25,
			"rare" : 0.25,
			"mythic" : 0.0,
		},
		"bigHook" : {
			"common" : 0.35,
			"uncommon" : 0.3,
			"rare" : 0.3,
			"mythic" : 0.05,
		},
	},
	G.FishingZone.MYTHIC_QUEST : { #same as rare table :)
		"noBigHook" : {
			"common" : 0.5,
			"uncommon" : 0.25,
			"rare" : 0.25,
			"mythic" : 0.0,
		},
		"bigHook" : {
			"common" : 0.35,
			"uncommon" : 0.3,
			"rare" : 0.3,
			"mythic" : 0.05,
		},
	},
}

func SelectRandomFishType():
	var bigHookUnlocked = P.upgrades[G.Upgrades.BIGHOOK]
	
	# taking from the rarieties below it, increase target rariety chance
	var increaseUncommonRarityUsed = P.activeSupplies[G.Supplies.CHUM_UNCOMMON]
	var increaseRareRarityUsed = P.activeSupplies[G.Supplies.CHUM_RARE]
	var increaseMythicRarityUsed = P.activeSupplies[G.Supplies.CHUM_MYTHIC]
	
	var noCommonFishUsed = P.activeSupplies[G.Supplies.CROWN]
	
	# for debugging
	#bigHookUnlocked = true
	
	var commonChance : float
	var uncommonChance : float
	var rareChance : float
	var mythicChance : float
	
	var zoneTable
	if bigHookUnlocked:
		zoneTable = zoneChances[G.activeFishingZone].bigHook
	else:
		zoneTable = zoneChances[G.activeFishingZone].noBigHook
	
	commonChance = zoneTable.common
	uncommonChance = zoneTable.uncommon
	rareChance = zoneTable.rare
	mythicChance = zoneTable.mythic
	
	var thirdOfCommonChance = commonChance / 3.0
	var thirdOfUncommonChance = uncommonChance / 3.0
	var thirdOfRareChance = rareChance / 3.0
	
	if increaseUncommonRarityUsed:
		var toRedistribute = thirdOfCommonChance
		uncommonChance += toRedistribute
		commonChance -= thirdOfCommonChance
	
	if increaseRareRarityUsed:
		var toRedistribute = thirdOfCommonChance + thirdOfUncommonChance
		rareChance += toRedistribute
		
		# each rariety takes a different hit
		commonChance -= thirdOfCommonChance
		uncommonChance -= thirdOfUncommonChance
	
	if increaseMythicRarityUsed and bigHookUnlocked:
		var toRedistribute = thirdOfCommonChance + thirdOfUncommonChance + thirdOfRareChance
		mythicChance += toRedistribute
	
		commonChance -= thirdOfCommonChance
		uncommonChance -= thirdOfUncommonChance
		rareChance -= thirdOfRareChance
	
	print("Active Fishing Zone: %d" % G.activeFishingZone)
	print("Fish chance - common=", commonChance, ", uncommon=", uncommonChance, ", rareChance=", rareChance, ", mythicChance=", mythicChance)
	assert((commonChance + uncommonChance + rareChance + mythicChance) == 1.0)
	
	var randNum = rand_range(0.0, 1.0)
	var fishRarietyPicked = G.FishRarity.COMMON
	
	if randNum <= mythicChance:
		fishRarietyPicked = G.FishRarity.MYTHIC
	elif randNum <= (rareChance + mythicChance):
		fishRarietyPicked = G.FishRarity.RARE
	elif randNum <= (uncommonChance + rareChance + mythicChance):
		fishRarietyPicked = G.FishRarity.UNCOMMON
	else:
		fishRarietyPicked = G.FishRarity.COMMON
	
	# Current implementation of this is to make common just become common. All other chances stay the same
	if noCommonFishUsed and fishRarietyPicked == G.FishRarity.COMMON:
		fishRarietyPicked = G.FishRarity.UNCOMMON
	
	# just guarding against getting mythic without bigHook. Shouldn't be possible, but can't be too careful
	if !bigHookUnlocked and fishRarietyPicked == G.FishRarity.MYTHIC:
		fishRarietyPicked = G.FishRarity.RARE
	
	
	var fishOptions = fishByRariety[fishRarietyPicked]
	var fishType
	if fishRarietyPicked == G.FishRarity.MYTHIC:
		if G.activeFishingZone == G.FishingZone.MYTHIC_QUEST:
			fishType = fishOptions[0] # mythic quest fish
		else:
			fishType = fishOptions[1] # other mythic
	else:
		fishType = fishOptions[randi() % fishOptions.size()]
	
	print("Type - ", fishType, ", FishRariety - ", fishRarietyPicked, ", with rand num - ", randNum)
	
	#fishType = FishType.COMMON_1
	#fishType = FishType.COMMON_2
	#fishType = FishType.COMMON_3
	#fishType = FishType.COMMON_4
	#fishType = FishType.COMMON_5
	#fishType = FishType.UNCOMMON_1
	#fishType = FishType.UNCOMMON_2
	#fishType = FishType.UNCOMMON_3
	#fishType = FishType.UNCOMMON_4
	#fishType = FishType.RARE_1
	#fishType = FishType.RARE_2
	#fishType = FishType.RARE_3
	#fishType = FishType.MYTHIC_1
	#fishType = FishType.MYTHIC_2
	
	return fishType
