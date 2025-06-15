extends Control

@export var tile_scene: PackedScene

@export var new_game_scene: PackedScene

var world = []
var visible_world = []

var gen_world = false
var counting_time = false
var time = 0.0

var lose_state = false
var win_state = false

var remaining_mines = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	call_deferred("new_game")
	
	update_ui_ios()
		
	#print(DisplayServer.screen_get_orientation())
	#if DisplayServer.screen_get_orientation() == DisplayServer.SCREEN_SENSOR:
		#if Settings.width < Settings.height:
			#DisplayServer.screen_set_orientation(DisplayServer.SCREEN_SENSOR_PORTRAIT)
			#print("Oriented vertically")
			#DisplayServer.screen_set_orientation(DisplayServer.SCREEN_SENSOR_PORTRAIT)
			#$MarginContainer.add_theme_constant_override("margin_top", 100)
			#%NewGame.custom_minimum_size.y = 50
			#%NewGame.add_theme_font_size_override("font_size", 35)
		#else:
			#DisplayServer.screen_set_orientation(DisplayServer.SCREEN_SENSOR_LANDSCAPE)
			#$MarginContainer.add_theme_constant_override("margin_top", 5)
	#else:
		#var val = DisplayServer.screen_get_orientation()
		#if val in [DisplayServer.SCREEN_PORTRAIT, DisplayServer.SCREEN_REVERSE_PORTRAIT]:
			#print("Oriented vertically")
			#DisplayServer.screen_set_orientation(DisplayServer.SCREEN_SENSOR_PORTRAIT)
			#$MarginContainer.add_theme_constant_override("margin_top", 100)
			#%NewGame.custom_minimum_size.y = 50
			#%NewGame.add_theme_font_size_override("font_size", 35)
		#if val in [DisplayServer.SCREEN_LANDSCAPE, DisplayServer.SCREEN_REVERSE_LANDSCAPE]:
			#DisplayServer.screen_set_orientation(DisplayServer.SCREEN_SENSOR_LANDSCAPE)
			#$MarginContainer.add_theme_constant_override("margin_top", 5)

func update_ui_ios():
	if size.y > size.x and OS.get_name() == 'iOS':
		$MarginContainer.add_theme_constant_override("margin_top", 100)
		$MarginContainer.add_theme_constant_override("margin_left", 5)
		$MarginContainer.add_theme_constant_override("margin_right", 5)
	elif OS.get_name() == 'iOS':
		$MarginContainer.add_theme_constant_override("margin_top", 15)
		$MarginContainer.add_theme_constant_override("margin_left", 100)
		$MarginContainer.add_theme_constant_override("margin_right", 100)
	
	if OS.get_name() == 'iOS':
		%NewGame.add_theme_font_size_override("font_size", 35)
		%MineCount.add_theme_font_size_override("font_size", 25)
		%TimeTaken.add_theme_font_size_override("font_size", 25)
		%NewGame.custom_minimum_size.y = 50

func _process(delta):
	update_ui_ios()
	
	if counting_time:
		time += delta
		
		if gen_world:
			remaining_mines = Settings.mine_count - count_flags()
	
	@warning_ignore("integer_division")
	var minutes = int(time) / 60
	@warning_ignore("integer_division")
	var hours = minutes / 60
	var seconds = int(time) % 60
	%TimeTaken.text = "Time Taken: %d:%02d:%02d" % [hours, minutes, seconds]
	
	%MineCount.text = "Remaining Mines: %d" % remaining_mines

func new_game():
	generate_tiles()
	
	counting_time = true
	remaining_mines = Settings.mine_count

func generate_world(start_location):
	# Generate initial world
	world.clear()
	for y in range(Settings.height):
		world.append([])
		for x in range(Settings.width):
			world[y].append(false)
	
	world[start_location.y][start_location.x] = true # prevent start from mine
	
	# Set bombs
	for i in range(Settings.mine_count):
		var l = Vector2(randi_range(0, Settings.width-1), randi_range(0, Settings.height-1))
		while world[l.y][l.x]:
			l = Vector2(randi_range(0, Settings.width-1), randi_range(0, Settings.height-1))
		
		world[l.y][l.x] = true
	
	world[start_location.y][start_location.x] = false

func generate_tiles():
	# Clear children
	while %PlayWorld.get_child_count():
		%PlayWorld.remove_child(%PlayWorld.get_child(0))
	
	for y in range(Settings.height):
		visible_world.append([])
		for x in range(Settings.width):
			visible_world[y].append(Settings.WorldValues.HIDDEN)
	
	# Get tile size
	var tile_size = Settings.tile_size
	Settings.offsets.y = %PlayWorld.position.y + (50 if OS.get_name() == 'iOS' else 5)
	var total_gap = Vector2((Settings.width - 1) * %PlayWorld.get_theme_constant("h_separation"),
		(Settings.height - 1) * %PlayWorld.get_theme_constant("v_separation")) 
	if Settings.auto_size_tiles:
		var available_space = size - Settings.offsets
		print(get_viewport().size)
		var max_width = floor((available_space.x - total_gap.x) / Settings.width)
		var max_height = floor((available_space.y - total_gap.y) / Settings.height)
		#print(available_space.x, " ", max_width, " ", size.x)
		#print(available_space.y, " ", max_height, " ", size.y, " ", max_height * Settings.height)
		tile_size = floor(min(max_width, max_height))
	# print(tile_size)
	
	%PlayWorld.columns = Settings.width
	# %PlayWorld.custom_minimum_size = total_gap + Vector2(Settings.width, Settings.height) * tile_size
	
	# Generate children again
	for y in range(Settings.height):
		for x in range(Settings.width):
			var new_tile = tile_scene.instantiate()
			new_tile.x = x
			new_tile.y = y
			
			new_tile.set_min_size(tile_size)
			
			%PlayWorld.add_child(new_tile)

func win():
	counting_time = false
	win_state = true
	remaining_mines = 0
	
	for x in range(Settings.width):
		for y in range(Settings.height):
			if visible_world[y][x] == Settings.WorldValues.HIDDEN:
				visible_world[y][x] = Settings.WorldValues.FLAG
	
	@warning_ignore("integer_division")
	var minutes = int(time) / 60
	@warning_ignore("integer_division")
	var hours = minutes / 60
	var seconds = int(time) % 60
	var congrats = AcceptDialog.new()
	congrats.title = "Congratulations"
	congrats.dialog_text = "You Won! It took you %d:%02d:%02d" % [hours, minutes, seconds]
	add_child(congrats)
	congrats.call_deferred("popup_centered")

func check_win():
	for x in range(Settings.width):
		for y in range(Settings.height):
			if visible_world[y][x] == Settings.WorldValues.HIDDEN and not world[y][x]:
				return
	
	win()

func lose():
	counting_time = false
	lose_state = true

func in_bounds(x, y):
	return Settings.width > x and x >= 0 and Settings.height > y and y >= 0

func count_nearby(x, y, value):
	var count = 0
	for X in range(x - 1, x + 2):
		for Y in range(y - 1, y + 2):
			if self.in_bounds(X, Y) and not (X == x and Y == y):
				match value:
					Settings.WorldValues.FLAG:
						count += 1 if visible_world[Y][X] == Settings.WorldValues.FLAG else 0
					Settings.WorldValues.BOMB:
						count += 1 if world[Y][X] else 0
	return count

func check(x, y):
	if !in_bounds(x, y):
		return false
	
	if visible_world[y][x] == Settings.WorldValues.FLAG or \
			visible_world[y][x] == Settings.WorldValues.EMPTY:
		return false
	
	if visible_world[y][x] == Settings.WorldValues.HIDDEN:
		if world[y][x]:
			visible_world[y][x] = Settings.WorldValues.BOMB
			return true
		
		var count = count_nearby(x, y, Settings.WorldValues.BOMB)
		
		if count == 0:
			visible_world[y][x] = Settings.WorldValues.EMPTY
			
			for X in range(x - 1, x + 2):
				for Y in range(y - 1, y + 2):
					if !(X == x and Y == y) and self.in_bounds(X, Y) and \
							visible_world[Y][X] == Settings.WorldValues.HIDDEN:
						check(X, Y)
		else:
			visible_world[y][x] = count
	elif visible_world[y][x] > 0:
		if count_nearby(x, y, Settings.WorldValues.FLAG) == visible_world[y][x]:
			for X in range(x - 1, x + 2):
				for Y in range(y - 1, y + 2):
					if !(X == x and Y == y) and self.in_bounds(X, Y):
						if visible_world[Y][X] == Settings.WorldValues.HIDDEN:
							if check(X, Y):
								return true
	return false

func button_clicked(x, y):
	if lose_state or win_state:
		return
	
	if not gen_world:
		generate_world(Vector2(x, y))
		gen_world = true
	
	if check(x, y):
		lose()
	
	check_win()


func count_flags():
	var flags = 0
	for x in range(Settings.width):
		for y in range(Settings.height):
			if visible_world[y][x] == Settings.WorldValues.FLAG:
				flags += 1
	return flags


func _on_button_pressed() -> void:
	get_tree().change_scene_to_packed(new_game_scene)
