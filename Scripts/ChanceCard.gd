extends Sprite3D

# Declare member variables here. Examples:
var currentState = state_idle

enum { 
	state_idle, 
	state_draw,
	state_shuffle,
	# More can be made as they're needed
	}
	
var cardNum = 0
signal chance_drawn
	
# Called when the node enters the scene tree for the first time.
func _ready():
	currentState = state_idle
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (currentState == state_draw):
		transform.origin += Vector3(0, 3, 0) * delta
		if (transform.origin.y >= 5):
			currentState = state_idle
			transform.origin.y = 5
			shuffleCard()
	elif(currentState == state_shuffle):
		transform.origin -= Vector3(0, 6, 0) * delta
		if (transform.origin.y <= 0):
			currentState = state_idle
			transform.origin.y = 0
	pass

func drawCard(num: int):
	currentState = state_draw
	transform.origin.y = 0
	cardNum = num

func shuffleCard():
	yield(get_tree().create_timer(2.0), "timeout")
	emit_signal("chance_drawn", cardNum)
	currentState = state_shuffle
