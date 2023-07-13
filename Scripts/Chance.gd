extends Spatial

# Called whenever a chance card is drawn
#signal card_drawn(card)

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var rng = RandomNumberGenerator.new()

#loads the paths of all images so they can be loaded as a texture when needed
var c1 = preload("res://Assets/Textures/AdvanceToAtlantis.jpg")
var c2 = preload("res://Assets/Textures/AdvanceToSwim.jpg")
var c3 = preload("res://Assets/Textures/AdvanceToCapeHorn.jpg")
var c4 = preload("res://Assets/Textures/AdvanceToPatuxent.jpg")
var c5 = preload("res://Assets/Textures/BankPaysYouDividend.png")
var c6 = preload("res://Assets/Textures/GetOutOfBermuda.jpg")
var c7 = preload("res://Assets/Textures/GoBack3.jpg")
var c8 = preload("res://Assets/Textures/GoToBermuda.jpg")
var c9 = preload("res://Assets/Textures/PoorTax.jpg")
var c10 = preload("res://Assets/Textures/YourBuildingMatures.jpg")

#chance object: image changes when rng number is chosen
onready var card = get_node("ChanceCard")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

#call this function to draw a chance card out of chest.
func drawChanceCard():
	print("Drawing Chance Card")
	rng.randomize()
	var randNum = rng.randi_range(0, 9)
	if (randNum == 0):
		card.set_texture(c1)
	elif(randNum == 1):
		card.set_texture(c2)
	elif(randNum == 2):
		card.set_texture(c3)
	elif(randNum == 3):
		card.set_texture(c4)
	elif(randNum == 4):
		card.set_texture(c5)
	elif(randNum == 5):
		card.set_texture(c6)
	elif(randNum == 6):
		card.set_texture(c7)
	elif(randNum == 7):
		card.set_texture(c8)
	elif(randNum == 8):
		card.set_texture(c9)
	elif(randNum == 9):
		card.set_texture(c10)
	
	card.drawCard(randNum)
	#emit_signal("card_drawn", randNum)
	pass
