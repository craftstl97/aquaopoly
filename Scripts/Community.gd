extends Spatial

# Called whenever a community chest card is drawn
#signal card_drawn(card)

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var rng = RandomNumberGenerator.new()

#loads the paths of all images so they can be loaded as a texture when needed
var c1 = preload("res://Assets/Textures/CommunityChestGetOutOfBermuda.jpg")
var c2 = preload("res://Assets/Textures/CommunityChestGoToBermudaTriangle.jpg")
var c3 = preload("res://Assets/Textures/DoctorsFee.jpg")
var c4 = preload("res://Assets/Textures/IncomeTaxRefund.jpg")
var c5 = preload("res://Assets/Textures/PayHospital.jpg")
var c6 = preload("res://Assets/Textures/BankErrorInYourFavor.jpg")

#chance object: image changes when rng number is chosen
onready var card = get_node("CommunityCard")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


#call this function to draw a community card out of chest.
func drawCommunityCard():
	print("Drawing Community Chest Card")
	rng.randomize()
	var randNum = rng.randi_range(0, 5)
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
	
	card.drawCard(randNum)
	#emit_signal("card_drawn", randNum)
	pass
