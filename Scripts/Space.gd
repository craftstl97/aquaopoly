extends Node
class_name Space

enum SPACETYPE {
	constmoney, # Go and taxes
	property, # All normal properties
	chest, # Community chests
	chance, # Chance cards
	nodevelop, # Railroads, water, and electric
	noeffect, # Just visiting and free parking
	gojail, # Go to jail
	jail # Jail
}

enum COLOR {
	brown = 0,
	white = 1,
	magenta = 2,
	orange = 3,
	red = 4,
	yellow = 5,
	green = 6,
	blue = 7,
	railroad = 8,
	utility = 9,
	na
}

export(SPACETYPE) var spaceType = SPACETYPE.property
export(COLOR) var color = COLOR.na

 # Cost to buy for spacetype_property and spacetype_nodevelop
export var value = 0

# The amount of money LOST from landing on this space. 
#		* Can be negative for GO space. 
#		* For spacetype_property and spacetype_nodevelop, cost only applies to non-owners if owned.
#		* Index in array is the number of houses developed on this space, which can range from 0 to 5 (inclusive)
export var rent = [100]

# The cost to buy one house
export var houseCost = 0

# The cost to buy one hotel
export var hotelCost = 0

# The money gained by mortgaging this property
#		* We could do this with a constant fraction instead
export var mortgageCost = 0

# ID of the player who owns this property spacetype_property and spacetype_nodevelop.
#		* -1 if nobody owns this space.
var ownerPlayer = -1

# Number of properties that have been developed on this space
#		* Must be 0 for all except spacetype_property
#		* 1-4 are number of houses
#		* 5 means a single hotel
var developedProperties = 0

func GetActualColor():
	match color:
		COLOR.brown:
			return Color.brown
		COLOR.white:
			return Color.aqua
		COLOR.magenta:
			return Color.magenta
		COLOR.orange:
			return Color.orange
		COLOR.red:
			return Color.red
		COLOR.yellow:
			return Color.yellow
		COLOR.green:
			return Color.green
		COLOR.blue:
			return Color.blue
		COLOR.railroad:
			return Color.dimgray
		COLOR.utility:
			return Color.blueviolet

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


	#return rent[developedProperties]
