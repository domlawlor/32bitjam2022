extends Spatial

export var questIndex = 0 # 0=chest, 1=quest1, 2=quest2
export var inFog = false

func _on_PickupArea_body_entered(body):
	if body.is_in_group("boat"):
		var collected = false
		if !inFog or P.upgrades[G.Upgrades.FLAMINGSKULL]:
			if questIndex == 1:
				print("quest item 1 collected")
				collected = true
				P.quest[0] = true
				Audio.PlaySFX(Audio.SFX.QUESTPICKUP)
			elif questIndex == 2:
				if P.upgrades[G.Upgrades.CANNON]:
					print("quest item 2 collected")
					collected = true
					P.quest[1] = true
					Audio.PlaySFX(Audio.SFX.QUESTPICKUP)
				else:
					print("can't collect quest item2, should have been blocked by rocks (no cannon)")
			else:
				var rewards = GetChestRewards()
				Events.emit_signal("create_blocking_ui", G.BlockingUITypes.CHEST_REWARD, rewards)
				collected = true
				Audio.PlaySFX(Audio.SFX.CHESTPICKUP)
			if collected:
				self.queue_free()
		else:
			print("can't collect cause this is considered to be in the fog and you don't have the flaming skull")

func GetChestRewards():
	var rewards = {
		"money" : 0,
		"supplies" : [],
	}
	var chestMoney : int
	var numSupplies
	var maxIndex = 11
	if G.progression == 1:
		maxIndex = 8
	elif G.progression == 0:
		maxIndex = 4
	var randPercent = randi() % 100
	if randPercent < 10:
		print("rare chest collected!")
		chestMoney = (randi() % 21) + 20 # 20-40 (100-200)
		numSupplies = 3
	elif randPercent < 35:
		print("uncommon chest collected!")
		chestMoney = (randi() % 11) + 10 # 10-20 (50-100)
		numSupplies = 2
	else:
		print("common chest collected!")
		chestMoney = (randi() % 6) + 5 # 5-10 (25-50)
		numSupplies = 1
		
	chestMoney *= 5
	P.money += chestMoney
	rewards.money = chestMoney
	print("you found $%d" % chestMoney)
	
	for x in numSupplies:
		var randIndex = randi() % maxIndex
		rewards.supplies.append(randIndex)
		P.supplies[randIndex] += 1
		print("you found a %s" % G.SuppliesNameMap[randIndex])
	
	return rewards
