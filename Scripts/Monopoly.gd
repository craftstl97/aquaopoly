extends Spatial


var boardList = [
	"Swim",
	"Pacific Ocean Garbage Patch",
	"Neptunes Bounty",
	"Indian Ocean Garbage Patch",
	"Jellyfish Sting",
	"Gulf Stream Current",
	"Yonaguni Monument",
	"Chance",
	"Grenada Sculpture Park",
	"The Great Blue Hole",
	"Just Visiting",
	"Patuxent River Ghost Fleet",
	"Offshore Drilling Platform",
	"Camaret Sur Mer",
	"Staten Island Boat Grave",
	"Norwegian Current",
	"Belize Barrier Reef",
	"Neptunes Bounty2",
	"Lyra Reef",
	"Great Barrier Reef",
	"The Docks",
	"Cape Leeuwin",
	"Chance2",
	"Cape of Good Hope",
	"Cape Horn",
	"Mozambique Current",
	"Great Canal",
	"Suez Canal",
	"Niagra Falls",
	"Panama Canal",
	"Go To Bermuda Triangle",
	"Bosporus Strait",
	"Strait of Dover",
	"Neptunes Bounty3",
	"Strait of Girbraltar",
	"East Australian Current",
	"Chance3",
	"Marianas Trench",
	"Oil Spill",
	"Atlantis",
]

#Objects
var playbackPos = 0
onready var dice = $Dice
onready var theBoard = $Board
onready var chance = $Chance
onready var neptune = $CommunityChest
onready var waves = $Waves
onready var seagull1 = $Seagull1
onready var seagull2 = $Seagull2
onready var seagull3 = $Seagull3
onready var pirate = $HesAPirate
onready var jailSpace = theBoard.get_child(2)
var boardObjectList = null
var rng_sound = RandomNumberGenerator.new()
onready var playerIndicator = preload("res://Scenes/PlayerIndicator.tscn")
onready var coolCamera = $CoolCamera

# Player Control
var playerTurn = 0
var playerNum: int = 4
var playerSpacesLeft = 0
onready var playerList = [get_node("Player1"), get_node("Player2"), get_node("Player3"), get_node("Player4")]

# Main Menu
onready var mainMenu = $MainMenu
onready var playerNumSlider = $MainMenu/PlayersSlider
onready var playerNumSliderLabel = $MainMenu/PlayersSliderLabel
onready var aiNumSlider = $MainMenu/AiSlider
onready var aiNumSliderLabel = $MainMenu/AiSliderLabel
onready var creditsMenu = $CreditsMenu

# Trade Menu
onready var tradeMenu = $TradeMenu
onready var tradeSelectPlayer = $TradeMenu/PlayerTradeSelect
onready var tradePropertiesMine = $TradeMenu/PropertiesMine
onready var tradePropertiesTheirs = $TradeMenu/PropertiesTheirs
onready var tradeMoneyMine = $TradeMenu/MoneySliderMine
onready var tradeMoneyMineLabel = $TradeMenu/MoneySliderMine/Label
onready var tradeMoneyTheirs = $TradeMenu/MoneySliderTheirs
onready var tradeMoneyTheirsLabel = $TradeMenu/MoneySliderTheirs/Label
var lastResort: bool = false

# Buy Menu
onready var buyMenuUI = $BuyMenu
onready var buySpace : Label = $BuyMenu/Space
onready var buyPrice : Label = $BuyMenu/Price
onready var spaceRent : Label = $BuyMenu/Rent
onready var spaceRentWithSet : Label = $BuyMenu/RentWithSet

# Money
onready var p1Money = $P1Money
onready var p2Money = $P2Money
onready var p3Money = $P3Money
onready var p4Money = $P4Money

# Other Menus
onready var playerInputUI = $PlayerTurnUI
onready var jailMenu = $JailMenu
onready var jailPayBail = $JailMenu/PayBailButton
onready var jailUseCard = $JailMenu/UseCardButton
onready var buttonBlocker = $ButtonBlocker
onready var outputMessage = $OutputMessage
onready var playerMoneyList = [get_node("P1Money"), get_node("P2Money"), get_node("P3Money"), get_node("P4Money")]

# Widely used, mostly constant
export var startingMoney = 1500
export var passGoMoney = 200
export var escapeJailCost = 50
export var aiMenuWait = 1.0

func _ready():
	rng_sound.randomize()
	set_process_input(true)
	outputMessage.text = ""
	buyMenuUI.visible = false
	playerInputUI.visible = false
	jailMenu.visible = false
	boardObjectList = theBoard.get_children()[1].get_children()
	print(boardObjectList[12])
	print(boardList[12])
	print("Jail: ", jailSpace)
	dice.connect("diceResult", self, "PlayerMove")
	$Chance/ChanceCard.connect("chance_drawn", self, "_on_Chance_card_drawn")
	$CommunityChest/CommunityCard.connect("chest_drawn", self, "_on_CommunityChest_card_drawn")
	for p in range(playerList.size()):
		playerList[p].connect("player_turn_finished", self, "PlayerEndTurn")
		playerList[p].connect("moving", self, "moving")
		playerList[p].connect("notMoving", self, "notMoving")
	
	UpdatePlayerMoney()
	for p in range(playerList.size()):
		playerList[p].visible = false
		playerMoneyList[p].visible = false
	waves.playing = true
	randomSeagulls()

func PlayerRollDice():
	#coolCamera.lookAtDice()
	coolCamera.lookAtBoard()
	playerInputUI.visible = false
	jailMenu.visible = false
	#yield(get_tree().create_timer(1.0), "timeout")
	dice.throwDice()

func PlayerMove(diceResult : int, doubles: bool):
	coolCamera.lookAtPlayer(playerTurn)
	yield(get_tree().create_timer(1.0), "timeout")
	#coolCamera.lookAtBoard()
	if playerList[playerTurn].currentState == Player.PLAYERSTATE.jail && !doubles:
		playerList[playerTurn].turnsInJail += 1
		if playerList[playerTurn].turnsInJail < 3:
			IncrimentPlayerTurn()
			return
		else:
			PayBail()
	playerList[playerTurn].turnsInJail = 0
	playerSpacesLeft = diceResult
	print("Moving Player ", playerSpacesLeft, " spaces")
	moving()
	var finalSpace: Space = boardObjectList[(playerList[playerTurn].currentSpaceNum + diceResult) % boardObjectList.size()]
	if finalSpace.color == Space.COLOR.utility && finalSpace.ownerPlayer != -1:
		finalSpace.rent = [diceResult]
		print("About to land on ", finalSpace, " with dice result ", diceResult, " : ", finalSpace.rent)
	playerInputUI.visible = false
	if (playerSpacesLeft > 0): # The player now moves one space at a time for animation
		playerSpacesLeft -= 1
		var newSpaceNum = (playerList[playerTurn].currentSpaceNum + 1) % boardObjectList.size()
		playerList[playerTurn].MoveToSpace( boardObjectList[newSpaceNum], newSpaceNum )
	elif (playerSpacesLeft < 0):
		playerSpacesLeft += 1
		var newSpaceNum = ((playerList[playerTurn].currentSpaceNum - 1) + boardObjectList.size()) % boardObjectList.size()
		playerList[playerTurn].MoveToSpace( boardObjectList[newSpaceNum], newSpaceNum )
	


func PlayerEndTurn():
	if (playerList[playerTurn].currentSpaceNum == 0):
		playerList[playerTurn].AddMoney(passGoMoney)
		UpdatePlayerMoney()
		
	if (playerSpacesLeft > 0): # The player now moves one space at a time for animation
		playerSpacesLeft -= 1
		var newSpaceNum = (playerList[playerTurn].currentSpaceNum + 1) % boardObjectList.size()
		playerList[playerTurn].MoveToSpace( boardObjectList[newSpaceNum], newSpaceNum )
	elif (playerSpacesLeft < 0):
		playerSpacesLeft += 1
		var newSpaceNum = ((playerList[playerTurn].currentSpaceNum - 1) + boardObjectList.size()) % boardObjectList.size()
		playerList[playerTurn].MoveToSpace( boardObjectList[newSpaceNum], newSpaceNum )
		
	else: # The player is actually done moving
		notMoving()
		yield(get_tree().create_timer(1.0), "timeout")
		#coolCamera.lookAtPlayer(playerTurn)
		var space : Space = playerList[playerTurn].currentSpace
		print("Player ", playerTurn + 1, " lands on ", space.name)
		match space.spaceType: # See Space.gd for details
			Space.SPACETYPE.constmoney:
				# Add / remove money from player
				playerList[playerTurn].AddMoney(-space.rent[0])
				#yield(get_tree().create_timer(aiMenuWait), "timeout")
			Space.SPACETYPE.property, Space.SPACETYPE.nodevelop:
				if (space.ownerPlayer == -1): 
					print("Property not owned")
					# Player can buy property
					# TODO: 
					#		* Display who owns which prperty on the board itself
					if (playerList[playerTurn].money >= space.value):
						# For now AI will always buy the space
						buySpace.text = boardList[playerList[playerTurn].currentSpaceNum]
						buyPrice.text = "Price: $" + str(space.value)
						match space.color:
							Space.COLOR.railroad:
								spaceRent.text = "Rent: $25/$50/$100/$200"
								spaceRentWithSet.text = "for number owned respectively"
							Space.COLOR.utility:
								spaceRent.text = "Rent with one: 4 x Dice Roll"
								spaceRentWithSet.text = "Rent if Both: 10 x Dice Roll"
							_: # Everything else:
								var rent : int
								rent = round(pow(space.value / 15, 1.7))
								spaceRent.text = "Standard Rent: $" + str(rent)
								spaceRentWithSet.text = "Rent with full set: $" + str(2 * rent)
						buyMenuUI.visible = true
						if playerList[playerTurn].compControlled:
							buttonBlocker.visible = true
							yield(get_tree().create_timer(aiMenuWait), "timeout")
							buttonBlocker.visible = false
							buySpace()
						else:
							buyMenuUI.visible = true
						return
					else:
						print("Player ", playerTurn + 1, " cannot buy ", space.name)
						setOutput("Not enough money to buy!")
						yield(get_tree().create_timer(aiMenuWait), "timeout")
				elif (space.ownerPlayer != playerTurn): 
					print("Property owned by player ", space.ownerPlayer + 1)
					# Player pays rent
					playerList[playerTurn].AddMoney(-CalculateSpaceRent(space))
					playerList[space.ownerPlayer].AddMoney(CalculateSpaceRent(space))
					print("Player ", playerTurn + 1, " pays Player ", space.ownerPlayer + 1, " $", CalculateSpaceRent(space))
					setOutput(str("Paid $" + str(CalculateSpaceRent(space)) + " to Player " + str(space.ownerPlayer + 1)))
					yield(get_tree().create_timer(aiMenuWait), "timeout")
				elif space.spaceType == Space.SPACETYPE.property:
					# TODO: Let player buy houses or whatever
					pass
			Space.SPACETYPE.chest:
				# Call community chest
				#TODO make the cards actually do their displayed effect
				neptune.drawCommunityCard()
				#yield(get_tree().create_timer(1.0), "timeout")
				coolCamera.lookAtCommunity()
				return
			Space.SPACETYPE.chance:
				# Call chance cards
				#TODO make the cards actually do their displayed effect
				chance.drawChanceCard()
				#yield(get_tree().create_timer(1.0), "timeout")
				coolCamera.lookAtChance()
				return
			# Space.SPACETYPE.noeffect:
				# Nothing happens
				# pass
			Space.SPACETYPE.gojail:
				# Immediately move to jail and return to not reinable UI yet
				# Jail is not in the boardObjectList but boardObjectList[10] == just visiting
				playerList[playerTurn].MoveToSpace( jailSpace, 10 )
				#yield(get_tree().create_timer(1.0), "timeout")
				coolCamera.lookAtBoard()
				return
			Space.SPACETYPE.jail:
				playerList[playerTurn].currentState = Player.PLAYERSTATE.jail
				pass
				
		if (playerList[playerTurn].currentState == Player.PLAYERSTATE.bankrupt):
			lastResort = true
			OpenTradeMenu()
			if playerList[playerTurn].compControlled:
				# TODO: Make AI sell properties
				buttonBlocker.visible = true
				yield(get_tree().create_timer(aiMenuWait), "timeout")
				buttonBlocker.visible = false
				cancelTrade()
		elif (!buyMenuUI.visible):
			IncrimentPlayerTurn()
			

func UpdatePlayerMoney():
	for p in range(playerNum):
		var test : Label = playerMoneyList[p]
		if (playerList[p].currentState != Player.PLAYERSTATE.bankrupt):
			test.text = "P" + str(p+1) + (" >>" if p == playerTurn else "") + " $" + str(playerList[p].money)
		else:
			test.text = "P" + str(p+1) + " BANKRUPT"
		#.text = playerList[p].money

# Handles keyboard input from player
func _input(event):
	if(playerInputUI.visible && buttonBlocker.visible == false):
		if event.is_action_pressed("ui_accept"):
			PlayerRollDice()
		if event.is_action_pressed("ui_open_trade_menu"):
			OpenTradeMenu()
	elif(buyMenuUI.visible):
		if event.is_action_pressed("ui_accept"):
			buySpace()
		if event.is_action_pressed("ui_cancel"):
			passSpace()
	elif(tradeMenu.visible):
		if event.is_action_pressed("ui_accept"):
			confirmTrade()
		if event.is_action_pressed("ui_cancel"):
			cancelTrade()
	elif(creditsMenu.visible):
		if event.is_action_pressed("ui_cancel"):
			hideCredits()
	elif(mainMenu.visible):
		if event.is_action_pressed("ui_accept"):
			startGame()
		if event.is_action_pressed("ui_cancel"):
			quitGame()
			
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

func CalculateSpaceRent(space: Space):
	var rent: int
	match space.color:
		Space.COLOR.railroad:
			var numOwned = 0
			for s in boardObjectList:
				if (s.color == space.color && s.ownerPlayer == space.ownerPlayer):
					numOwned += 1
			rent = space.value / (8 / pow(2, numOwned-1))
		Space.COLOR.utility:
			var ownAll = true
			for s in boardObjectList:
				if (s.color == space.color && s.ownerPlayer != space.ownerPlayer):
					ownAll = false
					break
			if ownAll:
				rent = space.rent[0] * 10
			else:
				rent = space.rent[0] * 4
		_: # Everything else:
			var ownAll = true
			for s in boardObjectList:
				if (s.color == space.color && s.ownerPlayer != space.ownerPlayer):
					ownAll = false
			rent = round(pow(space.value / 15, 1.7))
			if ownAll:
				rent *= 2
	return rent
	
func IncrimentPlayerTurn():
	var startingTurn = playerTurn
	while true: # Godot equivalent of do ... while loop
		playerTurn = (playerTurn + 1) % playerNum
		if (playerList[playerTurn].currentState != Player.PLAYERSTATE.bankrupt):
			break
		elif (playerTurn == startingTurn):
			printerr("Only one player is left but the game has not ended!")
	#coolCamera.lookAtPlayer(playerTurn)
	yield(get_tree().create_timer(1.0), "timeout")
	coolCamera.lookAtBoard()
	
	# Ending the game
	var numPlayersNotBankrupt = 0
	for p in range(playerNum):
		if playerList[p].currentState != Player.PLAYERSTATE.bankrupt:
			numPlayersNotBankrupt += 1
	if numPlayersNotBankrupt <= 1:
		$MainMenu/Subtitle.text = "Player #" + str(playerTurn + 1) + " wins!"
		p1Money.visible = false
		p2Money.visible = false
		p3Money.visible = false
		p4Money.visible = false
		mainMenu.visible = true
		coolCamera.lookAtStartMenu()
		playerInputUI.visible = false
		for obj in boardObjectList:
			var temp = obj.get_node("PlayerIndicator")
			if temp:
				temp.queue_free()
	else:
		UpdatePlayerMoney()
		if playerList[playerTurn].currentState == Player.PLAYERSTATE.idle:
			# Let next player take thier turn
			if playerList[playerTurn].compControlled:
				playerInputUI.visible = true
				buttonBlocker.visible = true
				yield(get_tree().create_timer(1.5), "timeout")
				buttonBlocker.visible = false
				playerInputUI.visible = false
				AiDecideMove()
			else:
				playerInputUI.visible = true
		elif playerList[playerTurn].currentState == Player.PLAYERSTATE.jail:
			if playerList[playerTurn].compControlled:
				OpenJailMenu()
				playerInputUI.visible = true
				buttonBlocker.visible = true
				yield(get_tree().create_timer(aiMenuWait), "timeout")
				AiDecideJail()
			else:
				OpenJailMenu()
				playerInputUI.visible = true
		else:
			printerr("Player state is not idle or jail")

# Accepts pruchase of a property
func buySpace():
	var space = playerList[playerTurn].currentSpace
	space.ownerPlayer = playerTurn
	playerList[playerTurn].AddMoney(-space.value)
	print("Player ", playerTurn + 1, " buys ", space.name)
	buyMenuUI.visible = false
	var temp = playerIndicator.instance()
	space.add_child(temp)
	temp.material = playerList[playerTurn].material
	
	IncrimentPlayerTurn()

# Declines purchase of a property
func passSpace():
	var space = playerList[playerTurn].currentSpace
	print("Player ", playerTurn + 1, " does not buy ", space.name)
	buyMenuUI.visible = false
	IncrimentPlayerTurn()

func _on_PlayersSlider_value_changed(value):
	playerNumSliderLabel.text = "Number of Players: " + str(value)
	playerNum = value
	aiNumSlider.max_value = value
	pass # Replace with function body.


func _on_AiSlider_value_changed(value):
	aiNumSliderLabel.text = "Number of AI: " + str(value)

func startGame():
	buttonBlocker.visible = false
	p1Money.visible = true
	p2Money.visible = true
	p3Money.visible = true
	p4Money.visible = true
	var anglePerPlayer = deg2rad(360 / playerNum)
	for p in range(playerList.size()):
		playerList[p].money = startingMoney
		playerList[p].currentState = Player.PLAYERSTATE.idle
		
		if p >= playerNum - aiNumSlider.value:
			playerList[p].compControlled = true
		else:
			playerList[p].compControlled = false
		
		if p >= playerNum:
			playerList[p].visible = false
			playerMoneyList[p].visible = false
		else:
			playerList[p].visible = true
			playerMoneyList[p].visible = true
			var spaceOffset = Vector3(-0.75 * cos(p * anglePerPlayer - deg2rad(30)), 0.125, -0.75 * sin(p * anglePerPlayer - deg2rad(30)))
			playerList[p].currentSpaceNum = 0
			playerList[p].transform.origin = boardObjectList[0].transform.origin + spaceOffset
			playerList[p].spaceOffset = spaceOffset
	for s in boardObjectList:
		s.ownerPlayer = -1
		
	mainMenu.visible = false
	
	playerTurn = -1
	IncrimentPlayerTurn()


func quitGame():
	get_tree().quit()
	pass # Replace with function body.

func OpenTradeMenu():
	#tradePropertiesMine.fixed_column_width = tradePropertiesMine.get_global_rect().size.x
	#tradePropertiesTheirs.fixed_column_width = tradePropertiesTheirs.get_global_rect().size.x
	tradeSelectPlayer.clear()
	for p in range(playerNum):
		if (p != playerTurn):
			tradeSelectPlayer.add_item("Player #" + str(p+1), p)
			
	tradePropertiesMine.clear()
	for i in range(boardObjectList.size()):
		if (boardObjectList[i].ownerPlayer == playerTurn):
			var temp: String = boardObjectList[i].name + " - $" + str(boardObjectList[i].value)
			tradePropertiesMine.AddItem(temp, i, boardObjectList[i].GetActualColor())
	
	tradeMoneyMine.value = 0
	tradeMoneyTheirs.value = 0
	tradeMoneyMine.max_value = playerList[playerTurn].money
	_on_MoneySliderMine_value_changed(0)
	_on_MoneySliderTheirs_value_changed(0)
	_on_PlayerTradeSelect_item_selected(0)
	playerInputUI.visible = false
	tradeMenu.visible = true

func _on_MoneySliderMine_value_changed(value):
	tradeMoneyMineLabel.text = "$" + str(value) + " / $" + str(playerList[playerTurn].money)


func _on_MoneySliderTheirs_value_changed(value):
	tradeMoneyTheirsLabel.text = "$" + str(value) + " / $" + str(playerList[tradeSelectPlayer.get_selected_id()].money)


func _on_PlayerTradeSelect_item_selected(index):
	print("Filling properties menu for player#", tradeSelectPlayer.get_selected_id())
	tradePropertiesTheirs.clear()
	for i in range(boardObjectList.size()):
		if (boardObjectList[i].ownerPlayer == tradeSelectPlayer.get_selected_id()):
			var temp: String = boardObjectList[i].name + " - $" + str(boardObjectList[i].value)
			tradePropertiesTheirs.AddItem(temp, i, boardObjectList[i].GetActualColor())
	
	tradeMoneyTheirs.max_value = playerList[tradeSelectPlayer.get_selected_id()].money
	_on_MoneySliderMine_value_changed(tradeMoneyMine.value)
	_on_MoneySliderTheirs_value_changed(tradeMoneyTheirs.value)


func confirmTrade():
	print("Finishing trade...")
	var otherPlayer: int = tradeSelectPlayer.get_selected_id()
	var tradeAccepted = true
	
	if playerList[otherPlayer].compControlled:
		# Calculate whether the AI wants to accept this deal
		var totalValue = tradeMoneyMine.value - tradeMoneyTheirs.value
		var numNeededPerColor = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
		for space in boardObjectList:
			if space.ownerPlayer != otherPlayer && space.color != Space.COLOR.na:
				numNeededPerColor[space.color] += 1;
			pass
		for i in tradePropertiesMine.GetCheckedItemIds():
			var space: Space = boardObjectList[i]
			if space != null:
				numNeededPerColor[space.color] -= 1
				totalValue += space.value + (space.value * (1.0 / (numNeededPerColor[space.color] + 1)))
				print("DEBUG - Calculated value for this property is $", (space.value + space.value * (1.0 / (numNeededPerColor[space.color] + 1))))
			else:
				printerr("Error! Space not found -- ", i)
		for i in tradePropertiesTheirs.GetCheckedItemIds():
			var space: Space = boardObjectList[i]
			if space != null:
				totalValue -= space.value + (space.value * (1.0 / (numNeededPerColor[space.color] + 1)))
				print("DEBUG - Calculated value for this property is -$", space.value + (space.value * (1.0 / (numNeededPerColor[space.color] + 1))))
				numNeededPerColor[space.color] += 1
			else:
				printerr("Error! Space not found -- ", i)
		pass
		
		if totalValue <= 0:
			tradeAccepted = false
			print("Trade has been declined.")
			setOutput("Trade Declined")
			
		else:
			print("Trade has been accepted!")
			setOutput("Trade Accepted")
	
	if tradeAccepted:
		playerList[playerTurn].AddMoney(tradeMoneyTheirs.value - tradeMoneyMine.value)
		playerList[otherPlayer].AddMoney(tradeMoneyMine.value - tradeMoneyTheirs.value)
		print("Giving player #", playerTurn + 1, " $", tradeMoneyTheirs.value - tradeMoneyMine.value)
		print("Giving player #", otherPlayer + 1, " $", tradeMoneyMine.value - tradeMoneyTheirs.value)
		UpdatePlayerMoney()

		for i in tradePropertiesMine.GetCheckedItemIds():
			#var propName: String = tradePropertiesMine.get_item_text(i).get_slice("\n", 0)
			#var space: Space = get_node("Board/PlayerPositions/" + propName)
			var space: Space = boardObjectList[i]
			if space != null:
				space.ownerPlayer = otherPlayer
				space.get_node("PlayerIndicator").material = playerList[otherPlayer].material
				print("Giving space ", space.name, " to player #", otherPlayer+1)
			else:
				printerr("Error! Space not found -- ", i)
		for i in tradePropertiesTheirs.GetCheckedItemIds():
			#var propName: String = tradePropertiesTheirs.get_item_text(i).get_slice("\n", 0)
			#var space: Space = get_node("Board/PlayerPositions/" + propName)
			var space: Space = boardObjectList[i]
			if space != null:
				space.ownerPlayer = playerTurn
				space.get_node("PlayerIndicator").material = playerList[playerTurn].material
				print("Giving space ", space.name, " to player #", playerTurn+1)
			else:
				printerr("Error! Space not found -- ", i)
	if (lastResort):
		OpenTradeMenu()
	else:
		tradeMenu.visible = false
		playerInputUI.visible = true


func cancelTrade():
	if (lastResort):
		lastResort = false
		if (playerList[playerTurn]).money >= 0:
			playerList[playerTurn].currentState = Player.PLAYERSTATE.idle
			print("Player #", playerTurn + 1, " has saved themself from bankruptcy!")
		else:
			print("Player #", playerTurn + 1, " did not save themself from bankruptcy!")
			for obj in boardObjectList:
				if obj.ownerPlayer == playerTurn:
					obj.ownerPlayer = -1
					var temp = obj.get_node("PlayerIndicator")
					if temp:
						temp.queue_free()
			playerList[playerTurn].visible = false
		IncrimentPlayerTurn()
	if (playerList[playerTurn].currentState == Player.PLAYERSTATE.jail):
		OpenJailMenu()
	playerInputUI.visible = true
	tradeMenu.visible = false

func OpenJailMenu():
	jailMenu.visible = true
	print("Get out of Jail Free:", playerList[playerTurn].numGetOutOfJailFree)
	if playerList[playerTurn].numGetOutOfJailFree > 0:
		jailUseCard.visible = true
	else:
		jailUseCard.visible = false
	if playerList[playerTurn].money > escapeJailCost:
		jailPayBail.visible = true
	else:
		jailPayBail.visible = false

func PayBail():
	playerList[playerTurn].AddMoney(-escapeJailCost)
	playerList[playerTurn].currentState = Player.PLAYERSTATE.idle
	jailMenu.visible = false
	UpdatePlayerMoney()
	
func GetOutOfJailFree():
	playerList[playerTurn].numGetOutOfJailFree -= 1
	playerList[playerTurn].currentState = Player.PLAYERSTATE.idle
	jailMenu.visible = false

func randomSeagulls():
	var waitTime = rng_sound.randf_range(60.0, 180.0)
	var play = rng_sound.randi_range(1, 3)
	if(play == 1):
		seagull1.playing = true
		print("Playing Seagull 1")
	elif(play == 2):
		seagull2.playing = true
		print("Playing Seagull 2")
	elif(play == 3):
		seagull3.playing = true
		print("Playing Seagull 3")
	print("Waiting for ", waitTime, " seconds")
	yield(get_tree().create_timer(waitTime), "timeout")
	randomSeagulls()
	
func moving():
	pirate.play()
	pirate.seek(playbackPos)
	
func notMoving():
	playbackPos =  pirate.get_playback_position()
	pirate.stop()
	
func AiDecideMove():
	# If we want a difficulty slider, we can do that here
	PlayerRollDice()
	
func AiDecideJail():
	if playerList[playerTurn].numGetOutOfJailFree > 0:
		GetOutOfJailFree()
		yield(get_tree().create_timer(aiMenuWait), "timeout")
		AiDecideMove()
	elif playerList[playerTurn].money > escapeJailCost * 2:
		PayBail()
		yield(get_tree().create_timer(aiMenuWait), "timeout")
		AiDecideMove()
	else:
		PlayerRollDice()
	buttonBlocker.visible = false

# Updates current player's status based on the card drawn in the Chance script
func _on_Chance_card_drawn(var card : int):
	print("Chance card function called w/ card #", card)
	#yield(get_tree().create_timer(3.0), "timeout")
	match card:
		0:
			print("Advance to Atlantis")
			PlayerMove(39 - playerList[playerTurn].currentSpaceNum, false)
			#playerList[playerTurn].MoveToSpace( boardObjectList[39], 39 )
		1:
			print("Advance to Swim")
			PlayerMove(40 - playerList[playerTurn].currentSpaceNum, false)
			#playerList[playerTurn].MoveToSpace( boardObjectList[0], 0 )
		2:
			print("Advance to Cape Horn")
			PlayerMove((24 + boardObjectList.size() - playerList[playerTurn].currentSpaceNum) % boardObjectList.size(), false)
			#if 24 < playerList[playerTurn].currentSpaceNum:
			#	playerList[playerTurn].AddMoney(200)
			#playerList[playerTurn].MoveToSpace( boardObjectList[24], 24 )
		3:
			print("Advance to Patuxent")
			PlayerMove((11 + boardObjectList.size() - playerList[playerTurn].currentSpaceNum) % boardObjectList.size(), false)
			#if 11 < playerList[playerTurn].currentSpaceNum:
			#	playerList[playerTurn].AddMoney(200)
			#playerList[playerTurn].MoveToSpace( boardObjectList[11], 11 )
		4:
			print("Bank pays dividend")
			playerList[playerTurn].AddMoney(50)
			IncrimentPlayerTurn()
		5:
			print("Get out of Bermuda Free")
			playerList[playerTurn].GiveGetOutOfJailFreeCard(1)
			IncrimentPlayerTurn()
		6:
			print("Go back 3")
			PlayerMove(-3, false)
			#var tempNewSpace : int = (playerList[playerTurn].currentSpaceNum - 3 ) % 40
			#playerList[playerTurn].MoveToSpace( boardObjectList[tempNewSpace], tempNewSpace)
		7:
			print("Go to Bermuda Triangle")
			playerList[playerTurn].MoveToSpace( jailSpace, 10 )
			coolCamera.lookAtBoard()
			yield(get_tree().create_timer(1.0), "timeout")
			#playerTurn -= 1
		8:
			print("Pay poor tax")
			playerList[playerTurn].AddMoney(-15)
			IncrimentPlayerTurn()
		9:
			print("Building matures")
			playerList[playerTurn].AddMoney(150)
			IncrimentPlayerTurn()
			

# Updates current player's status based on the card drawn in the Community Chest script
func _on_CommunityChest_card_drawn(var card : int):
	#yield(get_tree().create_timer(3.0), "timeout")
	print("Community chest function called w/ card #", card)
	match card:
		0:
			print("Get out of Bermuda free")
			playerList[playerTurn].GiveGetOutOfJailFreeCard(1)
			IncrimentPlayerTurn()
		1:
			print("Go to Bermuda Triangle")
			playerList[playerTurn].MoveToSpace( jailSpace, 10 )
			coolCamera.lookAtBoard()
			yield(get_tree().create_timer(1.0), "timeout")
		2:
			print("Pay doctor's fee")
			playerList[playerTurn].AddMoney(-50)
			IncrimentPlayerTurn()
		3:
			print("Receive income tax refund")
			playerList[playerTurn].AddMoney(20)
			IncrimentPlayerTurn()
		4:
			print("Pay hospital")
			playerList[playerTurn].AddMoney(-100)
			IncrimentPlayerTurn()
		5:
			print("Bank error in your favor")
			playerList[playerTurn].AddMoney(200)
			IncrimentPlayerTurn()

func setOutput(var text: String):
	outputMessage.text = text
	yield(get_tree().create_timer(3.0), "timeout")
	outputMessage.text = ""
	
	

func DisplayCredits():
	creditsMenu.visible = true


func hideCredits():
	creditsMenu.visible = false
