extends Control

onready var MoneyText = $MoneyText
onready var RedTimer = $RedTimer

var prevMoneyVal : int = 0

func _ready():
	Events.connect("cant_afford", self, "_on_cant_afford")

func _exit():
	Events.disconnect("cant_afford", self, "_on_cant_afford")
	
func _process(delta):
	var currentMoney = P.money
	if currentMoney != prevMoneyVal:
		MoneyText.text = "$%d" % currentMoney
		prevMoneyVal = currentMoney
	
	if !RedTimer.is_stopped():
		MoneyText.set_self_modulate(Color(1, 0, 0, 1))
	else:
		MoneyText.set_self_modulate(Color(1, 1, 1, 1))

func _on_cant_afford():
	RedTimer.start()
