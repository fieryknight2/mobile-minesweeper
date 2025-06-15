extends MarginContainer

var mine_count
var width
var height

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# DisplayServer.screen_set_orientation(DisplayServer.SCREEN_SENSOR)
	#print(DisplayServer.screen_get_orientation())
	#DisplayServer.screen_set_orientation(DisplayServer.SCREEN_LANDSCAPE)
	#print(DisplayServer.screen_get_orientation())
	call_deferred("set_limits")
	
	update_ui_ios()
	
	$VBoxContainer/Width/HSlider.value = Settings.width
	$VBoxContainer/Height/HSlider.value = Settings.height
	$VBoxContainer/MineCount/HSlider.value = Settings.mine_count

func update_ui_ios():
	if size.y > size.x and OS.get_name() == 'iOS':
		add_theme_constant_override("margin_top", 100)
		add_theme_constant_override("margin_left", 5)
		add_theme_constant_override("margin_right", 5)
	elif OS.get_name() == 'iOS':
		add_theme_constant_override("margin_top", 20)
		add_theme_constant_override("margin_left", 100)
		add_theme_constant_override("margin_right", 100)
	
	if OS.get_name() == 'iOS':
		%Easy.add_theme_font_size_override("font_size", 35)
		%Medium.add_theme_font_size_override("font_size", 35)
		%Hard.add_theme_font_size_override("font_size", 35)
		
		$VBoxContainer/Label.add_theme_font_size_override("font_size", 30)
		
		$VBoxContainer/MineCount/Label2.add_theme_font_size_override("font_size", 25)
		$VBoxContainer/MineCount/Label3.add_theme_font_size_override("font_size", 25)
		$VBoxContainer/Width/Label2.add_theme_font_size_override("font_size", 25)
		$VBoxContainer/Width/Label4.add_theme_font_size_override("font_size", 25)
		$VBoxContainer/Height/Label2.add_theme_font_size_override("font_size", 25)
		$VBoxContainer/Height/Label5.add_theme_font_size_override("font_size", 25)
		
		%Warning.add_theme_font_size_override("font_size", 25)
		%Start.add_theme_font_size_override("font_size", 45)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta) -> void:
	update_ui_ios()
	
	mine_count = $VBoxContainer/MineCount/HSlider.value
	width = $VBoxContainer/Width/HSlider.value
	height = $VBoxContainer/Height/HSlider.value
	
	$VBoxContainer/MineCount/Label3.text = str(int(mine_count))
	$VBoxContainer/Width/Label4.text = str(int(width))
	$VBoxContainer/Height/Label5.text = str(int(height))
	
	if mine_count > width * height / 3:
		%Warning.visible = true
		%Warning.text = "Too many mines!"
		%Start.disabled = true
	else:
		%Warning.visible = false
		%Start.disabled = false
	
		
	if width * height >= 900:
		%Warning.visible = true
		%Warning.text = "Sorry, that many squares isn't support yet!"
		%Start.disabled = true
	else:
		%Warning.visible = false
		%Start.disabled = false

func set_limits():
	var max_width = floor((size.x - Settings.offsets.x) / Settings.min_tile_size)
	var max_height = floor((size.y - Settings.offsets.y) / Settings.min_tile_size)
	print(max_width * Settings.min_tile_size)
	
	$VBoxContainer/MineCount/HSlider.max_value = max_width * max_height / 3
	$VBoxContainer/Width/HSlider.max_value = max_width
	$VBoxContainer/Height/HSlider.max_value = max_height
	
	if max_width < 16 or max_height < 16:
		%Medium.disabled = true
	if max_width < 30 or max_height < 16:
		%Hard.disabled = true
	if max_width < 9 or max_height < 9:
		%Easy.disabled = true

func _on_start_pressed() -> void:
	Settings.mine_count = mine_count
	Settings.width = width
	Settings.height = height
	
	get_tree().change_scene_to_file("res://main.tscn")


func _on_easy_pressed() -> void:
	Settings.mine_count = 10
	Settings.width = 9
	Settings.height = 9
	
	get_tree().change_scene_to_file("res://main.tscn")

func _on_medium_pressed() -> void:
	Settings.mine_count = 40
	Settings.width = 16
	Settings.height = 16
	
	get_tree().change_scene_to_file("res://main.tscn")

func _on_hard_pressed() -> void:
	Settings.mine_count = 99
	Settings.width = 30
	Settings.height = 16
	
	get_tree().change_scene_to_file("res://main.tscn")
