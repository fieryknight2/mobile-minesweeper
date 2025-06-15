extends Button

@export var flag: Texture
@export var big_flag: Texture
@export var red_flag: Texture
@export var big_red_flag: Texture
@export var bomb: Texture
@export var big_bomb: Texture

var x
var y

var revealed = false
var warning = false

var border_width = 2
var cvalue = 0

@export var touch_hold_time = 0.5
var touch_timer = 0.0
var is_touching = false

var updated_to_lose = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_theme()
	
	$TextureRect.custom_minimum_size = Vector2(Settings.min_tile_size * 0.7, Settings.min_tile_size * 0.7)
	#$TextureRect.size = Vector2(size.x * 0.7, size.y * 0.7)
	#$TextureRect.position.x = (size.x - $TextureRect.size.x) / 2
	#$TextureRect.position.y = (size.y - $TextureRect.size.y) / 2
	call_deferred("configure_tex_rect")
	call_deferred("update_sizes")

func configure_tex_rect():
	$TextureRect.size = Vector2(size.x * 0.7, size.y * 0.7)
	$TextureRect.position = (size - $TextureRect.size) / 2

func update_sizes():
	if size.x >= 40:
		flag = big_flag
		red_flag = big_red_flag
		bomb = big_bomb
		add_theme_font_size_override("font_size", 32)

func _process(delta):
	if is_touching:
		touch_timer += delta
		if touch_timer >= touch_hold_time:
			toggle_flag()
			is_touching = false
	
	if get_tree().current_scene.lose_state:
		if !updated_to_lose:
			updated_to_lose = true
		
			if get_tree().current_scene.world[y][x]:
				if get_tree().current_scene.visible_world[y][x] != Settings.WorldValues.FLAG:
					$TextureRect.texture = bomb
					revealed = true
					text = ""
			else:
				if get_tree().current_scene.visible_world[y][x] == Settings.WorldValues.FLAG:
					$TextureRect.texture = red_flag
			warning = false
			
			update_theme()
		return
	
	var value = get_tree().current_scene.visible_world[y][x]
	
	if cvalue != value:
		cvalue = value
		
		match cvalue:
			Settings.WorldValues.EMPTY:
				revealed = true
				warning = false
				$TextureRect.texture = null
				text = ""
			Settings.WorldValues.HIDDEN:
				revealed = false
				warning = false
				$TextureRect.texture = null
				text = ""
			Settings.WorldValues.FLAG:
				$TextureRect.texture = flag
				text = ""
				revealed = false
				warning = false
			Settings.WorldValues.BOMB:
				$TextureRect.texture = bomb
				text = ""
				revealed = true
				warning = false
			_:
				revealed = true
				$TextureRect.texture = null
				text = str(cvalue)
		update_theme()
	
	check_warning()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			toggle_flag()
	elif event is InputEventScreenTouch and event.pressed:
		is_touching = true
		touch_timer = 0.0
	elif event is InputEventScreenTouch and not event.pressed:
		if touch_timer < touch_hold_time:
			_on_pressed()
		is_touching = false
		touch_timer = 0.0

func toggle_flag():
	if get_tree().current_scene.win_state or get_tree().current_scene.lose_state:
		return
	
	if get_tree().current_scene.visible_world[y][x] == Settings.WorldValues.FLAG:
		get_tree().current_scene.visible_world[y][x] = Settings.WorldValues.HIDDEN
	elif get_tree().current_scene.visible_world[y][x] == Settings.WorldValues.HIDDEN:
		get_tree().current_scene.visible_world[y][x] = Settings.WorldValues.FLAG

func check_warning():
	if !get_tree().current_scene.gen_world or get_tree().current_scene.visible_world[y][x] <= 0:
		return 
	
	var pw = warning
	var c = get_tree().current_scene.count_nearby(x, y, Settings.WorldValues.FLAG)
	if c > cvalue:
		warning = true
	else:
		warning = false
	
	if pw != warning:
		update_theme()

func set_min_size(min_size):
	custom_minimum_size = Vector2(min_size, min_size)

func _on_pressed() -> void:
	get_tree().current_scene.button_clicked(x, y)

func update_theme():
	if warning:
		var warn_style = StyleBoxFlat.new()
		warn_style.bg_color = Color("#ff6666")
		# warn_style.border_color = Color("#b00020")
		warn_style.border_color = Color("#444444")
		warn_style.set_border_width_all(border_width)
		
		add_theme_stylebox_override("normal", warn_style)
		add_theme_stylebox_override("hover", warn_style)
		add_theme_stylebox_override("pressed", warn_style)
		# add_theme_color_override("font_color", Color("#b00020"))
	else:
		var style = StyleBoxFlat.new()
		style.bg_color = Color("#1e1e1e") if revealed else Color("#2c2c2c")
		style.border_color = Color("#333333") if revealed else Color("#444444")
		style.set_border_width_all(border_width)
		
		if !revealed:
			var hover = StyleBoxFlat.new()
			hover.bg_color = Color("#343434")
			hover.border_color = Color("#444444")
			hover.set_border_width_all(border_width)
			
			var pressedb = StyleBoxFlat.new()
			pressedb.bg_color = Color("#232323")
			pressedb.border_color = Color("#444444")
			pressedb.set_border_width_all(border_width)
			
			add_theme_stylebox_override("hover", hover)
			add_theme_stylebox_override("pressed", pressedb)
		else:
			add_theme_stylebox_override("hover", style)
			add_theme_stylebox_override("pressed", style)
		
		add_theme_stylebox_override("normal", style)
		add_theme_color_override("font_color", Color("#eeeeee"))
