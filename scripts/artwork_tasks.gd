extends Control

# Removed fixed textures, will load random from assets/sprites

@onready var timer_label = $"../timer_label"
@onready var timer = $"../timer_label/Timer"
var total_time = 120
var possible_textures: Array = []
var selected_asset_name: String = ""

# --- Internal state ---
var color_to_index: Dictionary = {}   # key: String(color), value: int index
var index_to_color: Dictionary = {}   # key: int index, value: Color
var tile_nodes: Dictionary = {}       # key: Vector2i(grid_x,grid_y), value: Panel
var selected_index: int = -1


func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)
	_update_label()
	load_possible_textures()
	image_conversion()


func load_possible_textures():
	var dir = DirAccess.open("res://assets/sprites")
	if dir:
		dir.list_dir_begin()
		var file = dir.get_next()
		while file != "":
			if file.ends_with(".png") or file.ends_with(".jpg"):
				possible_textures.append(file.get_basename())  # Store name without extension
			file = dir.get_next()
		dir.list_dir_end()

func image_conversion():
	# SELECT RANDOM IMAGE, excluding completed assets
	var img: Image
	if possible_textures.size() > 0:
		var available = possible_textures.filter(func(name): return name not in GlobalConfig.completed_art_assets)
		if available.size() > 0:
			selected_asset_name = available[randi() % available.size()]
		else:
			# All completed, select any
			selected_asset_name = possible_textures[randi() % possible_textures.size()]
		
		var texture_path = "res://assets/sprites/" + selected_asset_name + ".png"
		img = Image.load_from_file(texture_path)
		if img:
			img.convert(Image.FORMAT_RGBA8)
		else:
			# Fallback to a default if loading fails
			img = Image.create(64, 64, false, Image.FORMAT_RGBA8)
			img.fill(Color.WHITE)
	else:
		# Fallback
		img = Image.create(64, 64, false, Image.FORMAT_RGBA8)
		img.fill(Color.WHITE)


	var next_number: int = 1
	var img_w := img.get_width()
	var img_h := img.get_height()

	# --- DYNAMIC PIXEL SIZE ---
	var target_size: Vector2 = get_parent().size
	var scale_x: float = target_size.x / img_w
	var scale_y: float = target_size.y / img_h
	var pixel_size: int = int(min(scale_x, scale_y))

	# Final drawn size of the image
	var grid_size_pixels: Vector2 = Vector2(img_w * pixel_size, img_h * pixel_size)

	# --- CENTERING OFFSET ---
	var offset: Vector2 = (target_size - grid_size_pixels) / 2.0
	var offset_x: float = offset.x
	var offset_y: float = offset.y

	# GENERATE THE TILES
	for y in range(img_h):
		for x in range(img_w):
			var color: Color = img.get_pixel(x, y)
			if color.a < 0.1:
				continue

			var color_key := str(color)
			if not color_to_index.has(color_key):
				color_to_index[color_key] = next_number
				index_to_color[next_number] = color
				next_number += 1
			var num: int = color_to_index[color_key]

			var grid_pos: Vector2i = Vector2i(x, y)

			# create tile (Panel)
			var tile := Panel.new()
			tile.name = "Tile_%d_%d" % [x, y]

			# Position and enforce size explicitly
			tile.position = Vector2(offset_x + x * pixel_size, offset_y + y * pixel_size)
			tile.custom_minimum_size = Vector2(pixel_size, pixel_size)

			# Style for UNPAINTED tile: white bg + black 1px border
			var sb := StyleBoxFlat.new()
			sb.bg_color = Color.WHITE
			sb.border_color = Color.BLACK
			sb.border_width_left = 1
			sb.border_width_top = 1
			sb.border_width_right = 1
			sb.border_width_bottom = 1
			tile.add_theme_stylebox_override("panel", sb)

			# ===== Centered number =====
			var center := CenterContainer.new()
			center.name = "LabelCenter"
			center.set_anchors_preset(Control.PRESET_FULL_RECT)
			tile.add_child(center)

			var label := Label.new()
			label.name = "NumberLabel"
			label.text = str(num)
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			label.mouse_filter = Control.MOUSE_FILTER_IGNORE
			label.modulate = Color.BLACK
			label.add_theme_font_size_override("font_size", max(16, pixel_size / 2))
			center.add_child(label)
			# ===========================

			# metadata
			tile.set_meta("number", num)
			tile.set_meta("grid_pos", grid_pos)
			tile.set_meta("filled", false)

			# clickable via gui_input
			tile.mouse_filter = Control.MOUSE_FILTER_STOP
			tile.gui_input.connect(Callable(self, "_on_tile_gui_input").bind(tile))

			add_child(tile)
			tile_nodes[grid_pos] = tile

	# create palette in color_zone
	_create_palette(next_number)


func _create_palette(total_colors: int) -> void:
	var palette_panel := $color_zone
	for child in palette_panel.get_children():
		child.queue_free()

	for i in range(1, total_colors):
		var btn := Button.new()
		btn.text = str(i)
		btn.custom_minimum_size = Vector2(40, 40)

		# style button background with the color
		var style := StyleBoxFlat.new()
		style.bg_color = index_to_color[i]
		style.border_color = Color.BLACK
		style.border_width_left = 1
		style.border_width_top = 1
		style.border_width_right = 1
		style.border_width_bottom = 1
		btn.add_theme_stylebox_override("normal", style)
		btn.add_theme_color_override("font_color", Color.BLACK)

		# connect with bound index
		btn.pressed.connect(Callable(self, "_on_palette_selected").bind(i))
		palette_panel.add_child(btn)


func _on_palette_selected(index: int) -> void:
	selected_index = index
	print("Selected color index:", index)


func _on_tile_gui_input(event: InputEvent, tile: Panel) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var tile_number: int = tile.get_meta("number")
		if tile_number == selected_index:
			var start_pos: Vector2i = tile.get_meta("grid_pos")
			_flood_fill(start_pos, tile_number)


func _flood_fill(start_pos: Vector2i, num: int) -> void:
	var color: Color = index_to_color[num]
	var queue: Array = [start_pos]
	var visited: Dictionary = {}

	while queue.size() > 0:
		var pos: Vector2i = queue.pop_front()
		if visited.has(pos):
			continue
		visited[pos] = true

		if not tile_nodes.has(pos):
			continue
		var tile: Panel = tile_nodes[pos]
		if tile.get_meta("number") != num:
			continue
		if tile.get_meta("filled") == true:
			continue

		# apply filled style (solid color, no borders)
		var sb := StyleBoxFlat.new()
		sb.bg_color = color
		sb.border_color = Color.TRANSPARENT
		sb.border_width_left = 0
		sb.border_width_top = 0
		sb.border_width_right = 0
		sb.border_width_bottom = 0
		tile.add_theme_stylebox_override("panel", sb)

		# hide number label
		var lbl := tile.get_node_or_null("LabelCenter/NumberLabel") as Label
		if lbl:
			lbl.visible = false

		tile.set_meta("filled", true)

		# enqueue 4-neighbors
		for d in [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]:
			queue.append(pos + d)

	_check_completion()
	print("Flood-filled region with number", num)


func _check_completion() -> void:
	for tile in tile_nodes.values():
		if tile.get_meta("filled") == false:
			return # stop early if we find at least one unfilled tile
	print("Artwork task", GlobalConfig.artwork_tasks_completed + 1, "completed")
	GlobalConfig.artwork_tasks_completed += 1
	GlobalConfig.current_time += 3  # Add 3 hours for each task
	# Store the completed asset
	if selected_asset_name != "":
		GlobalConfig.completed_art_assets.append(selected_asset_name)
	if GlobalConfig.artwork_tasks_completed < 1:
		# Reset for next task
		for tile in tile_nodes.values():
			tile.set_meta("filled", false)
			var sb := StyleBoxFlat.new()
			sb.bg_color = Color.WHITE
			sb.border_color = Color.BLACK
			sb.border_width_left = 1
			sb.border_width_top = 1
			sb.border_width_right = 1
			sb.border_width_bottom = 1
			tile.add_theme_stylebox_override("panel", sb)
			var lbl := tile.get_node_or_null("LabelCenter/NumberLabel") as Label
			if lbl:
				lbl.visible = true
		image_conversion()  # Load next image
	else:
		GlobalConfig.finished_artwork_task = true  # For compatibility
		get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_timer_timeout():
	if total_time > 0:
		total_time -= 1
		_update_label()
	else:
		evaluate_performance()
		timer.stop()
		print("Time's up!")
		get_tree().change_scene_to_file("res://scenes/game.tscn")

func _update_label():
	var minutes = total_time / 60
	var seconds = total_time % 60
	timer_label.text = "Time Left: " + str(minutes) + ":" + str(seconds).pad_zeros(2)
	
	
func evaluate_performance():
	var consumed_time = 120 - total_time
	if consumed_time <= 60:
		GlobalConfig.current_time += 1
	elif consumed_time <= 120:
		GlobalConfig.current_time += 2
