extends TileMap

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var check
var green = Vector2(-1,-1)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if check != Vector2(-1,-1):
		set_cellv(green, -1)
		set_cellv(check, 0)
		green = check
	else:
		set_cellv(green, -1)