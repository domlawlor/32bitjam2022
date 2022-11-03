extends Control

onready var CursorPos = $CursorPos
onready var Speech = $Speech

const quest1 = "%s If you're brave enough to enter the fog, I lost a key in it somewhere. If you bring it back to me I can put more items out for sale. %s" % ['"', '"']
const quest1complete = "%s Ah you found it, thank you! You can now purchase some of my better wares. %s" % ['"', '"']

const quest2 = "%s Another key was stolen by the bandits that live behind the boulders. If you can find a way past them and find my key, I will let you purchase all of my wares. %s" % ['"', '"']
const quest2complete = "%s Excellent, thank you! You may now purchase all of my wares! %s" % ['"', '"']

const quest3 = "%s I think you're ready to try and catch the fabled Mind Melter! It's rumored to live amongst the bones of it's prey. Good luck to you. %s" % ['"', '"']
const quest3complete = "%s You did it! You caught the Mind Melter!! You will be remembered as a hero... %s" % ['"', '"']

var speechText = [
	{ # 0
		"questDescription" : quest1,
		"questComplete" : quest1complete,
		"descriptionRead" : false,
	},
	{ # 1
		"questDescription" : quest2,
		"questComplete" : quest2complete,
		"descriptionRead" : false,
	},
	{ # 2
		"questDescription" : quest3,
		"questComplete" : quest3complete,
		"descriptionRead" : false,
	},
]

var active = false

var creditsSpeech = [
	"This game was made for the 32bit Jam 2022 by Luka Pavlovich, Dom Lawlor, Tim Day, Jake Archer and Nick Kerr.",
	"It was made using the Godot Engine. All 3D graphics made in Maya.",
	"No fish or underworld monstrosities were harmed in the making of this game...",
]
var creditsIndex = 0

func GetCursorPos():
	return CursorPos.position

func SetSpeech():
	if G.progression < 3:
		var t : String
		var speechDict = speechText[G.progression]
		if P.quest[G.progression]:
			#quest completed
			t = speechDict.questComplete
			G.MakeProgress()
		else:
			t = speechDict.questDescription
			speechDict.descriptionRead = true
		Speech.text = t
	else:
		Speech.text = creditsSpeech[creditsIndex]
		creditsIndex = wrapi(creditsIndex+1, 0, creditsSpeech.size())

func IsNewSpeech():
	if G.progression < 3:
		var speechDict = speechText[G.progression]
		return P.quest[G.progression] or !speechDict.descriptionRead
	return false
