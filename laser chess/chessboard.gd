extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	OS.set_window_size(Vector2(640, 512))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$selectedsquares.check = $boardPieces.clicked_tile
