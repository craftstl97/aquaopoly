extends Spatial
onready var camYRot = $CamYRot
onready var camXRot = $CamYRot/CamXRot
onready var springArm = $CamYRot/CamXRot/SpringArm
onready var camera = $CamYRot/CamXRot/SpringArm/Camera

var goalPos = Vector3()
var dir = Vector3()
var player1 = null
var player2 = null
var player3 = null
var player4 = null
var dice = null
var chance = null
var community = null
var board = null
var currentTarget = "start"

func _ready():
	#print(get_parent().get_children())
	print(get_parent().find_node("Player1"))
	player1 = get_parent().find_node("Player1")
	player2 = get_parent().find_node("Player2")
	player3 = get_parent().find_node("Player3")
	player4 = get_parent().find_node("Player4")
	dice = get_parent().find_node("Dice")
	chance = get_parent().find_node("Chance")
	community = get_parent().find_node("CommunityChest")
	board = get_parent().find_node("Board")
	
	goalPos = global_transform.origin

func _process(delta):
	if Input.is_action_just_pressed("ui_left"):
		lookAtPlayer1()
	if Input.is_action_just_pressed("ui_up"):
		lookAtPlayer2()
	if Input.is_action_just_pressed("ui_right"):
		lookAtBoard()
	if Input.is_action_just_pressed("ui_down"):
		lookAtStartMenu()
	
	if currentTarget == "player1":
		goalPos = player1.global_transform.origin
	if currentTarget == "player2":
		goalPos = player2.global_transform.origin
	if currentTarget == "player3":
		goalPos = player3.global_transform.origin
	if currentTarget == "player4":
		goalPos = player4.global_transform.origin
	if currentTarget == "dice":
		goalPos = dice.global_transform.origin
	if currentTarget == "chance":
		goalPos = chance.global_transform.origin
	if currentTarget == "community":
		goalPos = community.global_transform.origin
	if currentTarget == "board":
		goalPos = board.global_transform.origin
	
	if currentTarget == "player1" or currentTarget == "player2" or currentTarget == "player3" or currentTarget == "player4":
		camYRot.look_at(-goalPos, Vector3.UP)
		camYRot.rotation_degrees *= Vector3.UP
		
		camXRot.rotation_degrees = Vector3(-25, 0, 0)
		
		var distToPawn = global_transform.origin.distance_to(goalPos)
		springArm.spring_length = distToPawn / cos(deg2rad(30))
		
		camera.rotation_degrees = Vector3(-50, 0, 0)
		
	elif currentTarget == "dice":
		camYRot.rotation_degrees = Vector3(0, 15, 0)
		camXRot.rotation_degrees = Vector3(-90, 0, 0)
		camera.rotation_degrees = Vector3(0, 0, 0)
		springArm.spring_length = 10
	
	elif currentTarget == "chance":
		camYRot.rotation_degrees = Vector3(0, 45, 0)
		camXRot.rotation_degrees = Vector3(-45, 0, 0)
		var distToChance = global_transform.origin.distance_to(goalPos)
		springArm.spring_length = distToChance / cos(deg2rad(45))
		camera.rotation_degrees = Vector3(-20, 0, 0)
		
	elif currentTarget == "community":
		camYRot.rotation_degrees = Vector3(0, 225, 0)
		camXRot.rotation_degrees = Vector3(-45, 0, 0)
		var distToChance = global_transform.origin.distance_to(goalPos)
		springArm.spring_length = distToChance / cos(deg2rad(45)) + 3
		camera.rotation_degrees = Vector3(-20, 0, 0)
		
	elif currentTarget == "board":
		camYRot.rotation_degrees = Vector3(0, 0, 0)
		camXRot.rotation_degrees = Vector3(-90, 0, 0)
		camera.rotation_degrees = Vector3(0, 0, 0)
		springArm.spring_length = 18
	
	elif currentTarget == "start":
		camYRot.rotation_degrees += Vector3(0, 10, 0) * delta
		camXRot.rotation_degrees = Vector3(-20, 0, 0)
		springArm.spring_length = 25
		camera.rotation_degrees = Vector3(0, 0, 0)
	
func lookAtPlayer1():
	currentTarget = "player1"

func lookAtPlayer2():
	currentTarget = "player2"

func lookAtPlayer3():
	currentTarget = "player3"

func lookAtPlayer4():
	currentTarget = "player4"
	
func lookAtPlayer(num: int):
	currentTarget = "player" + str(num+1)

func lookAtDice():
	currentTarget = "dice"

func lookAtChance():
	currentTarget = "chance"

func lookAtCommunity():
	currentTarget = "community"

func lookAtBoard():
	currentTarget = "board"

func lookAtStartMenu():
	currentTarget = "start"
