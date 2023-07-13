extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var labels = []
var ids = []
var numElements = 0

#var object: Resource = preload("CheckBox")
onready var vboxContainer = $ScrollContainer/VBoxContainer

# Called when the node enters the scene tree for the first time.
# func _ready():
#	for i in range(10):
#		print("Adding an item")
#		AddItem("Label #" + str(i), i)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func AddItem(label: String, id: int, color: Color):
	print("Adding item ", label)
	ids.append(id)
	labels.append(CheckBox.new())
	labels[numElements].text = label
	vboxContainer.add_child(labels[numElements])
	#var temp: CheckBox
	#labels[numElements].clip_text = true
	labels[numElements].add_color_override("font_color", color)
	#labels[numElements].get_rect().position.y += (labels[numElements].get_rect().size.y * numElements * 100)
	numElements += 1

func GetItemId(index: int):
	return ids[index]
	
func GetCheckedItemIds(): 
	var result = []
	for i in range(numElements):
		if labels[i].pressed:
			result.append(ids[i])
	return result
	
func clear():
	for i in range(numElements):
		labels[i].queue_free()
	labels = []
	ids = []
	numElements = 0
	pass
