extends TextureRect

@onready var current_time = $HeaderMargin/Header/Time
@onready var daysLeft_label = $HeaderMargin/Header/TurnsLeft
@onready var art_button = $ArtButton
@onready var music_button = $MusicButton
@onready var programming_button = $ProgrammingButton
@onready var background = self

# Progress bars
@onready var programming_progress = $ProgressBars/Programming
@onready var artwork_progress = $ProgressBars/Artworks
@onready var music_progress = $ProgressBars/Music
@onready var cherry_button = $CherryButton

# Background textures for different times of day
@onready var morning_texture = preload("res://assets/objects/citymorning.png")
@onready var noon_texture = preload("res://assets/objects/citynoon.png")
@onready var night_texture = preload("res://assets/objects/citynight.png")

func _ready() -> void:
	setup_button_animations()
	update_background()  # Set initial background
	start_background_flicker()  # Start simple flicker animation
	update_progress_bars()
	cherry_button.visible = false
	cherry_button.disabled = true
	cherry_button.pressed.connect(_on_cherry_button_pressed)
	check_all_tasks_completed()
	pass

func setup_button_animations():
	# Start bounce animations for all buttons
	bounce_button(art_button)
	bounce_button(music_button)
	bounce_button(programming_button)

func bounce_button(button: Control):
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(button, "position:y", button.position.y - 10, 0.5).set_trans(Tween.TRANS_SINE)
	tween.tween_property(button, "position:y", button.position.y, 0.5).set_trans(Tween.TRANS_SINE)

func _physics_process(delta):
#	GAME OVER IF THE NUMBER OF DAYS IS 0 AND TIME IS 6PM
	if GlobalConfig.days_left <= 0 and GlobalConfig.current_time >= 18:
		GlobalConfig.game_over()
	display_time()
	update_progress_bars()  # Update progress bars every frame

func _on_art_button_pressed() -> void:
	if GlobalConfig.artwork_tasks_completed < 1:
		get_tree().change_scene_to_file("res://scenes/artwork_tasks.tscn")
	else:
		print("All art tasks completed")
		check_all_tasks_completed()

func _on_programming_button_pressed() -> void:
	if GlobalConfig.programming_tasks_completed < 1:
		get_tree().change_scene_to_file("res://scenes/programming_tasks.tscn")
	else:
		print("All programming tasks completed")
		check_all_tasks_completed()

func _on_music_button_pressed() -> void:
	if GlobalConfig.music_tasks_completed < 1:
		get_tree().change_scene_to_file("res://scenes/music_tasks.tscn")
	else:
		print("All music tasks completed")
		check_all_tasks_completed()

#	LOGIC FOR DISPLAYING THE CURRENT TIME
func display_time():
	daysLeft_label.text = str("    Days Left: ", GlobalConfig.days_left)

	if GlobalConfig.current_time < 12:
		current_time.text = str(GlobalConfig.current_time) + ":00AM     "
	else:
		current_time.text = str(GlobalConfig.current_time - 12) + ":00PM     "

	# Update background based on time of day
	update_background()

	# Check if we passed the end of the day (e.g., after 6PM)
	if GlobalConfig.current_time >= 18:
		GlobalConfig.reset_day()
		GlobalConfig.days_left -= 1
		current_time.text = str(GlobalConfig.current_time) + ":00AM     "

# FUNCTION TO UPDATE BACKGROUND BASED ON TIME OF DAY
func update_background():
	if GlobalConfig.current_time >= 6 and GlobalConfig.current_time < 12:
		# Morning (6AM - 12PM)
		texture = morning_texture
	elif GlobalConfig.current_time >= 12 and GlobalConfig.current_time < 18:
		# Noon/Afternoon (12PM - 6PM)
		texture = noon_texture
	else:
		# Night (6PM - 6AM)
		texture = night_texture

func start_background_flicker():
	if background:
		var flicker_tween = create_tween().set_loops()
		# Fade out to 30% opacity
		flicker_tween.tween_property(background, "modulate:a", 0.8, 1.0).set_trans(Tween.TRANS_SINE)
		# Fade back to full opacity
		flicker_tween.tween_property(background, "modulate:a", 1.0, 1.9).set_trans(Tween.TRANS_SINE)

func update_progress_bars():
	programming_progress.value = GlobalConfig.programming_tasks_completed
	programming_progress.max_value = 1
	artwork_progress.value = GlobalConfig.artwork_tasks_completed
	artwork_progress.max_value = 1
	music_progress.value = GlobalConfig.music_tasks_completed
	music_progress.max_value = 1

	# Disable buttons when tasks are completed
	programming_button.disabled = GlobalConfig.programming_tasks_completed >= 1
	art_button.disabled = GlobalConfig.artwork_tasks_completed >= 1
	music_button.disabled = GlobalConfig.music_tasks_completed >= 1

func check_all_tasks_completed():
	if GlobalConfig.is_all_tasks_completed():
		print("All tasks completed! Enabling cherry button...")
		cherry_button.visible = true
		cherry_button.disabled = false

func _on_cherry_button_pressed():
	get_tree().change_scene_to_file("res://scenes/game_world.tscn")
