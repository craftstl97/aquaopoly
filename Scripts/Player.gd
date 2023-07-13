extends Spatial
class_name Player

export var moveSpeed = 2.0

var money = 1500
var currentState = PLAYERSTATE.idle
var currentSpace : Spatial
var	spaceOffset : Vector3 = Vector3.ZERO
var currentSpaceNum = 0
var compControlled = false
var numGetOutOfJailFree = 0
var turnsInJail = 0

enum PLAYERSTATE { 
	idle, 
	move,
	choose,
	jail,
	bankrupt
	# More can be made as they're needed
	}

# Called when this player finishes their turn
signal player_turn_finished

# Called when this player goes bankrupt
# If we allow selling properties or trading to stay in the game,
# that should be done as a result of this call
signal player_bankrupt

signal moving

signal notMoving
# Called when the node enters the scene tree for the first time.
# func _ready():
# 	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (currentState == PLAYERSTATE.move):
		var movement = (currentSpace.transform.origin + spaceOffset) - transform.origin
		look_at(Vector3(currentSpace.global_transform.origin.x + spaceOffset.x, global_transform.origin.y, currentSpace.global_transform.origin.z +  + spaceOffset.z), Vector3.UP)
		if (movement.length() <= moveSpeed * delta):
			transform.origin = currentSpace.transform.origin + spaceOffset
			currentState = PLAYERSTATE.idle
			emit_signal("player_turn_finished")
			# I think changing state to jail should be done in another script
		else:
			movement = movement.normalized() * moveSpeed * delta
			transform.origin += movement
	pass

# Intended to be called by either player input or AI immediately after rolling dice
# Moves this piece from it's current space to another one
# Inputs -- space = the space where you want the player to move to
func MoveToSpace(var space : Spatial, var num : int):
	currentState = PLAYERSTATE.move
	currentSpace = space
	currentSpaceNum = num

# Intended to be called as a result of landing on a space, drawing a chance card, or trading with another player
# Adds or subtracts an amount of money to this player's wallet and checks whether it is negative
# Inputs -- amount = the amount of money to be added (or subtracted if negative)
func AddMoney(var amount : int):
	money += amount
	if (money < 0):
		print(name, " is bankrupt!")
		currentState = PLAYERSTATE.bankrupt
		emit_signal("player_bankrupt")

# Intended to be called by the Community Chest or Chance drawing functions, or possibly when trading
# Add the provided number to the player's GetOutOfJailFreeCard count (or subtract if negative
# Inputs -- amount = the number of cards to be added (or potentially subtracted)
func GiveGetOutOfJailFreeCard(var number : int):
	numGetOutOfJailFree += number
