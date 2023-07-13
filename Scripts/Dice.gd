extends Spatial
onready var dice1 = $Dice1
onready var dice2 = $Dice2
signal diceResult(result)

var torqueMult = 3
var impulseMult = 5

var areDiceThrown = false
#var isFirstFrame = true
var isResultSent = false

var dice1Result = null
var dice2Result = null

#func _ready():
	#throwDice()

func _physics_process(delta):
	#Find out when Dice have stopped moving
	#print(dice1.linear_velocity)
	if dice1.linear_velocity.length() <= 0.1 and areDiceThrown:
		#print(getTheFaceUpValue(dice1))
		dice1Result = getTheFaceUpValue(dice1)
	if dice2.linear_velocity.length() <= 0.1 and areDiceThrown:
		#print(getTheFaceUpValue(dice2))
		dice2Result = getTheFaceUpValue(dice2)
	
	if dice1Result != null and dice2Result != null and !isResultSent:
		print("Dice Result: ", str(dice1Result + dice2Result))
		emit_signal("diceResult", dice1Result + dice2Result, dice1Result == dice2Result)
		#emit_signal("diceResult", 36, dice1Result == dice2Result)
		isResultSent = true
		areDiceThrown = false
	
	#isFirstFrame = false

func getTheFaceUpValue(dice):
	#print(dice.find_node("RC1"))
	if dice.find_node("RC1").is_colliding():
		return 6
	elif dice.find_node("RC2").is_colliding():
		return 5
	elif dice.find_node("RC3").is_colliding():
		return 4
	elif dice.find_node("RC4").is_colliding():
		return 3
	elif dice.find_node("RC5").is_colliding():
		return 2
	elif dice.find_node("RC6").is_colliding():
		return 1
	

func throwDice():
	isResultSent = false
	
	var rand = RandomNumberGenerator.new()
	rand.randomize()
	dice1.transform.origin = Vector3(-2, 0, 0)
	dice2.transform.origin = Vector3(2, 0, 0)
	
	#Randomized Starting Rotation
	dice1.rotation_degrees = Vector3(rand.randf_range(0, 360), rand.randf_range(0, 360), rand.randf_range(0, 360))
	dice2.rotation_degrees = Vector3(rand.randf_range(0, 360), rand.randf_range(0, 360), rand.randf_range(0, 360))
	
	#Randomize torque impulse
	var dice1TVect = Vector3(rand.randf_range(-1, 1), rand.randf_range(-1, 1), rand.randf_range(-1, 1)).normalized() * torqueMult
	var dice2TVect = Vector3(rand.randf_range(-1, 1), rand.randf_range(-1, 1), rand.randf_range(-1, 1)).normalized() * torqueMult
	dice1.apply_torque_impulse(dice1TVect)
	dice2.apply_torque_impulse(dice2TVect)
	
	#Ranomize central impulse
	var dice1IVect = Vector3(rand.randf_range(-1, 1), rand.randf_range(-1, 1), rand.randf_range(-1, 1)).normalized() * impulseMult
	var dice2IVect = Vector3(rand.randf_range(-1, 1), rand.randf_range(-1, 1), rand.randf_range(-1, 1)).normalized() * impulseMult
	dice1.apply_central_impulse(dice1IVect)
	dice2.apply_central_impulse(dice2IVect)
	
	areDiceThrown = true
