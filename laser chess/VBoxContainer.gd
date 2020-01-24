extends VBoxContainer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var img = get_node("../CenterContainer/board")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_ace_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			get_tree().change_scene("chessboard.tscn")
	img.set_texture(load("res://boards and buttons/bace.png"))

func _on_curious_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			get_tree().change_scene("curious.tscn")
	img.set_texture(load("res://boards and buttons/bcurious.png"))

func _on_grail_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		get_tree().change_scene("grail.tscn")
	img.set_texture(load("res://boards and buttons/bgrail.png"))


func _on_mercury_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		get_tree().change_scene("mercury.tscn")
	img.set_texture(load("res://boards and buttons/bmercury.png"))


func _on_sophie_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		get_tree().change_scene("sophie.tscn")
	img.set_texture(load("res://boards and buttons/bsophie.png"))

func _on_exit_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		get_tree().quit()


func _on_manual_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		get_tree().change_scene("res://manual.tscn")