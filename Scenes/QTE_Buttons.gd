extends Control

onready var FaceDownSprite : Sprite = $FaceDown
onready var FaceRightSprite : Sprite = $FaceRight
onready var FaceUpSprite : Sprite = $FaceUp
onready var FaceLeftSprite : Sprite = $FaceLeft

func _ready():
	HideAll()

func ShowButton(button):
	if button == G.QTE_Button.CROSS:
		FaceDownSprite.visible = true
	elif button == G.QTE_Button.CIRCLE:
		FaceRightSprite.visible = true
	elif button == G.QTE_Button.SQUARE:
		FaceLeftSprite.visible = true
	elif button == G.QTE_Button.TRIANGLE:
		FaceUpSprite.visible = true
	else:
		assert(false, "Should never reach here")

func HideAll():
	FaceDownSprite.visible = false
	FaceRightSprite.visible = false
	FaceUpSprite.visible = false
	FaceLeftSprite.visible = false
