extends TextureRect

@onready var current_time = $HeaderMargin/Header/Time
@onready var daysLeft_label = $HeaderMargin/Header/TurnsLeft

func _ready() -> void:
	
	pass

func _physics_process(delta):
#	GAME OVER IF THE NUMBER OF DAYS IS 0 AND TIME IS 6PM
	if GlobalConfig.days_left <= 0 and GlobalConfig.current_time >= 18:
		GlobalConfig.game_over()
	display_time()


func _on_art_button_pressed() -> void:
	if GlobalConfig.finished_artwork_task == false:
		get_tree().change_scene_to_file("res://scenes/artwork_tasks.tscn")
	else:
		print("All tasks in this workstation is done")

func _on_programming_button_pressed() -> void:
	if GlobalConfig.finished_programming_task == false:
		get_tree().change_scene_to_file("res://scenes/programming_tasks.tscn")
	else:
		print("All tasks in this workstation is done")

func _on_music_button_pressed() -> void:
	if GlobalConfig.finished_music_task == false:
		get_tree().change_scene_to_file("res://scenes/music_tasks.tscn")
	else:
		print("All tasks in this workstation is done")

	

#	LOGIC FOR DISPLAYING THE CURRENT TIME
func display_time():
	daysLeft_label.text = str("    Days Left: ", GlobalConfig.days_left)
	
	if GlobalConfig.current_time < 12:
		current_time.text = str(GlobalConfig.current_time) + ":00AM     "
	else:
		current_time.text = str(GlobalConfig.current_time - 12) + ":00PM     "

	# Check if we passed the end of the day (e.g., after 6PM)
	if GlobalConfig.current_time >= 18:
		GlobalConfig.reset_day()
		GlobalConfig.days_left -= 1
		current_time.text = str(GlobalConfig.current_time) + ":00AM     "
