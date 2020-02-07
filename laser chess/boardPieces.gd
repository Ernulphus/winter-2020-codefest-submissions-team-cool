extends TileMap

var mouse_pos
const DESELECT = Vector2(-1,-1)
var clicked_tile = DESELECT #vector2 location of the clicked tile
var selected_piece #ID in the tileset of the selected piece
var turn_pred = true #True if it's RED's turn
var sidebar_obj

# Called when the node enters the scene tree for the first time.
func _ready():
	sidebar_obj = get_node("../sidebar")
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass #signal to make that tile green
	
func _input(event):
	mouse_pos = get_global_mouse_position()
	
	#this event will handle selecting a square for movement or rotation
	if event is InputEventMouseButton and event.pressed: #when a square is clicked
		#if there isn't a square selected
		if (clicked_tile == DESELECT):
			clicked_tile = world_to_map(mouse_pos) #then select the clicked square
			var id = get_cellv(clicked_tile)
			if id == -1: #if the clicked square is empty
				clicked_tile = DESELECT #don't select it
			elif (turn_pred && (id >= 5)) || (!turn_pred && (id < 5)): #if the selected piece isn't yours
				clicked_tile = DESELECT#don't select it
			else:
				selected_piece = get_cellv(clicked_tile)
				
		else: #if a square is already selected
			var new_tile = world_to_map(mouse_pos)
			var dist = vdistance(clicked_tile, new_tile)
			if dist.x > 1 || dist.y > 1 || clicked_tile.x > 9 || clicked_tile.x < 0 || clicked_tile.y > 9 || clicked_tile.y < 0:
				clicked_tile = DESELECT #deselect it
			elif dist == Vector2(0,0):
				clicked_tile = DESELECT
			else:
				move(clicked_tile, new_tile)
				clicked_tile = DESELECT
				turn_pred = !turn_pred

				
	#rotate a selected piece by hitting left and right
	if event is InputEventKey and event.pressed and clicked_tile != Vector2(-1,-1):
		if event.scancode == KEY_RIGHT:
			rotate_cell(clicked_tile, 90)
			clicked_tile = DESELECT
			fire_cannon()
			turn_pred = !turn_pred

		if event.scancode == KEY_LEFT:
			rotate_cell(clicked_tile,270)
			clicked_tile = DESELECT
			fire_cannon()
			turn_pred = !turn_pred
			
	if event is InputEventKey and event.pressed and event.scancode == KEY_ESCAPE:
		get_tree().change_scene("res://MainMenu.tscn")
		get_node("../../MainMenuMusic").playing = true
		get_node("../../Board/GameMusic").playing = false
	
	update_sidebar()

func fire_cannon():
	var direction
	var tile = Vector2(0,0)
	if turn_pred:
		direction = analyze_orientation(9,7)
		tile = Vector2(9,7)
		
	else:
		direction = analyze_orientation(0,0)
		tile = Vector2(0,0)

	if direction == 0:
		tile = Vector2(tile.x, tile.y - 1)
	if direction == 90:
		tile = Vector2(tile.x + 1, tile.y)
	if direction == 180:
		tile = Vector2(tile.x, tile.y + 1)
	if direction == 270:
		tile = Vector2(tile.x - 1, tile.y)
		
	#as long as the laser remains in bounds:
	while (tile.x > -1 && tile.x < 10 && tile.y > -1 && tile.y < 8):
		#check each next_tile and update direction. 
		#If it's a hit, destroy and return
		var id = get_cellv(tile)
		
		#show the laser as it moves
		var select = get_node("../selectedsquares")
		select.set_cellv(tile, 0)
		var t = Timer.new()
		t.set_wait_time(0.125)
		t.set_one_shot(true)
		self.add_child(t)
		t.start()
		yield(t, "timeout")
		t.queue_free()
		
		#logic for king
		if id % 5 == 0:
			set_cellv(tile,-1)
			select.set_cellv(tile,-1)
			end_game()
			break
		
		#logic for hitting cannon
		if id % 5 == 1:
			select.set_cellv(tile,-1)
			break
		
		#logic for hitting triangular mirror (deflector)
		if id % 5 == 2:
			if analyze_orientation(tile.x,tile.y)  == 0:
				if direction == 0 || direction == 270:
					set_cellv(tile, -1)
					select.set_cellv(tile,-1)
					break
				if direction == 90:
					direction = 0
				if direction == 180:
					direction = 270
			
			if analyze_orientation(tile.x,tile.y)  == 90:
				if direction == 0 || direction == 90:
					set_cellv(tile, -1)
					select.set_cellv(tile,-1)
					break
				if direction == 180:
					direction = 90
				if direction == 270:
					direction = 0
				
			if analyze_orientation(tile.x,tile.y)  == 180:
				if direction == 90 || direction == 180:
					set_cellv(tile, -1)
					select.set_cellv(tile,-1)
					break
				if direction == 0:
					direction = 90
				if direction == 270:
					direction = 180
				
			if analyze_orientation(tile.x,tile.y)  == 270:
				if direction == 180 || direction == 270:
					set_cellv(tile, -1)
					select.set_cellv(tile,-1)
					break
				if direction == 0:
					direction = 270
				if direction == 90:
					direction = 180
					
			#This was supposed to be a better version of the deflector logic but it doesn't work
	#		if id % 5 == 2:
	#			if (direction - analyze_orientation(tile.x,tile.y)) % 360 == 0 || (direction - analyze_orientation(tile.x,tile.y) ) % 360 == 270:
	#				set_cellv(tile, -1)
	#				select.set_cellv(tile,-1)
	#				break
	#
	#			elif (direction - analyze_orientation(tile.x,tile.y)) % 360 == 90:
	#				direction = analyze_orientation(tile.x,tile.y)
	#				print(direction)
	#
	#			elif (direction - analyze_orientation(tile.x,tile.y)) % 360 == 180:
	#				direction = (analyze_orientation(tile.x,tile.y) - 90) % 360
		
		#logic for hitting diagonal mirror

		if id % 5 == 3:
			if analyze_orientation(tile.x,tile.y) == 0 || analyze_orientation(tile.x,tile.y) == 180:
				if direction == 0:
					direction = 90
				elif direction == 90:
					direction = 0
				elif direction == 180:
					direction = 270
				elif direction == 270:
					direction = 180
			else:
				if direction == 0:
					direction = 270
				elif direction == 270:
					direction = 0
				elif direction == 180:
					direction = 90
				elif direction == 90:
					direction = 180
		
		#logic for hitting block
		if id % 5 == 4:
			if direction == (analyze_orientation(tile.x,tile.y) + 180) % 360:
				select.set_cellv(tile,-1)
				break #do nothing if the block blocks the laser
			else:
				set_cellv(tile, -1) #if it hits any other side, destroy the block
				select.set_cellv(tile,-1)
				break
		
		#if nothing was destroyed, move laser to next tile
		select.set_cellv(tile,-1)
		
		
		if direction == 0:
			tile = Vector2(tile.x, tile.y - 1)
		if direction == 90:
			tile = Vector2(tile.x + 1, tile.y)
		if direction == 180:
			tile = Vector2(tile.x, tile.y + 1)
		if direction == 270:
			tile = Vector2(tile.x - 1, tile.y)

func end_game():
	#wait a bit and restart the game
	var t = Timer.new()
	t.set_wait_time(3)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	t.queue_free()
	get_tree().change_scene("res://MainMenu.tscn")

func move(start, end):
	var id = get_cellv(start)
	var id2 = get_cellv(end)
	var state = analyze_orientation(start.x,start.y)
	var state2 = analyze_orientation(end.x,end.y)
	var squares = get_node("../boardSquares")
	
	#no moving onto forbidden squares
	if (squares.get_cellv(end) == 4 && id > 4) || (squares.get_cellv(end) == 5 && id < 5):
		clicked_tile = DESELECT
		turn_pred = !turn_pred
	
	elif id % 5 == 1: #no moving cannons
		clicked_tile = DESELECT
		turn_pred = !turn_pred
		
	elif id % 5 == 3 && (id2 % 5 == 2 || id2 % 5 == 4):
		set_cellv(start, id2)
		set_cellv(end, id)
		rotate_cell(start, state2)
		rotate_cell(end,state)
		fire_cannon()
	
	elif id2 != -1:
		clicked_tile = DESELECT
		turn_pred = !turn_pred

	else:
		set_cellv(start,-1)
		set_cellv(end,id)
		rotate_cell(end,state)
		fire_cannon()

func analyze_orientation(x,y):
	if is_cell_transposed(x,y) and is_cell_x_flipped(x,y):
		return 90
	elif is_cell_transposed(x,y) and is_cell_y_flipped(x,y):
		return 270
	elif is_cell_x_flipped(x,y) and is_cell_y_flipped(x,y):
		return 180
	else:
		return 0

func rotate_cell(cell, deg):
	if get_cellv(cell) == 1: #red cannon
		if analyze_orientation(cell.x,cell.y) == 0:
			deg = 270
		elif analyze_orientation(cell.x,cell.y) == 270:
			deg = 90
	if get_cellv(cell) == 6: #blue cannon
		if analyze_orientation(cell.x,cell.y) == 90:
			deg = 90
		elif analyze_orientation(cell.y,cell.y) == 180:
			deg = 270
	
	var targ = (analyze_orientation(cell.x,cell.y) + deg) % 360
	if targ == 0:
		set_cellv(cell, get_cellv(cell), false, false, false)
	if targ == 90:
		set_cellv(cell, get_cellv(cell), true, false, true)
	if targ == 180:
		set_cellv(cell, get_cellv(cell), true, true, false)
	if targ == 270:
		set_cellv(cell, get_cellv(cell), false, true, true)
		
#Additional rotate cell function, called only when the board is initialized. Allows the rotations of the cannons to be defined by file.
func init_rotate_cell(cell, deg):
	var targ = (analyze_orientation(cell.x,cell.y) + deg) % 360
	if targ == 0:
		set_cellv(cell, get_cellv(cell), false, false, false)
	if targ == 90:
		set_cellv(cell, get_cellv(cell), true, false, true)
	if targ == 180:
		set_cellv(cell, get_cellv(cell), true, true, false)
	if targ == 270:
		set_cellv(cell, get_cellv(cell), false, true, true)

func vdistance(start, end):
	return Vector2(abs(end.x-start.x),abs(end.y-start.y))

#Change the sidebar to reflect whose turn it is
func update_sidebar():
	if (turn_pred):
		sidebar_obj.get_node("./redTeamMarker").show()
		sidebar_obj.get_node("./blueTeamMarker").hide()
	else:
		sidebar_obj.get_node("./redTeamMarker").hide()
		sidebar_obj.get_node("./blueTeamMarker").show()
	pass