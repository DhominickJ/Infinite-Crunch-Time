extends TextureRect

@onready var code = $desktop_monitor/TextMargin/Code
@onready var problem_section = $problem_note
@onready var choices = $choices_container
@onready var timer_label = $timer_label
@onready var timer = $timer_label/Timer

@onready var button_bg = preload("res://assets/objects/blue_button.png")
@onready var button_font = preload("res://fonts/Pixel Digivolve/Pixel Digivolve.otf")
var quiz_stage = 0
var total_time = 120
#DAY 1 PROGRAMMING TASKS
var debug_dict =  [
 {
	"program": 'var code_string = extends CharacterBody2D
	\n\nvar gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
	\n\n func _physics_process():
	\nif not is_on_floor():
	\n\tvelocity.y += gravity * delta',
	"problem" : "This is the entire code block of _physics_process(), but the character still doesn't fall down. What is missing?",
	"choices" : ["move_and_slide()", "move()", "execute()", "print()"],
	"correct_choice": "move_and_slide()"},
	
{
	"program": '
	var button_section = $HBoxContainer
	\n\nfunc generate_buttons(item_array):
	\nfor child in choices.get_children():
		\n\tchild.queue_free()
	\nfor item in item_array:
		\n\tvar btn = Button.new()
			\n\tbtn.text = item_array
		\nbutton.add_child(btn)',
	"problem":"I am trying to make a button, but it seems that there is a logic error. What should I fix?",
	"choices": ["add_child", "btn", "child", "item"],
	"correct_choice": "item"

#var Day1_3 = {
	#"program": "",
	#"problem":"",
	#"choices": "",
	#"correct_choice": ""
#}
}]

func _ready():
	load_dict(quiz_stage)
	timer.timeout.connect(_on_timer_timeout)
	_update_label()

func load_dict(index):
	var dict = debug_dict[index]
	code.text = dict["program"]
	problem_section.text = dict["problem"]
	generate_choices(dict)

func generate_choices(dict):
#	MAKE THE BUTTONS
	for child in choices.get_children():
		child.queue_free()
	for choice in dict["choices"]:
		var btn = Button.new()
		btn.text = choice
		
#		ADDING TEXTURES TO THE BUTTON 
		var texture = StyleBoxTexture.new()
		texture.texture = button_bg
		btn.add_theme_stylebox_override("normal", texture)
		btn.add_theme_stylebox_override("hover", texture)
		btn.add_theme_stylebox_override("pressed", texture)
		
#		ADD FONT
		var font = FontFile.new()
		btn.add_theme_font_override("font", button_font)
		btn.add_theme_font_size_override("font_size", 24)
		
#		MODIFICATION TO THE BUTTON CREATION
		btn.custom_minimum_size = Vector2(200, 60) 
		btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		
#		SIGNAL TO THE FUNCTION choice_evaluation IF PRESSED. PASS THE choice VARIABLE 
		btn.connect("pressed", Callable(self, "choice_evaluation").bind(choice))
#		ADD THE NODES
		choices.add_child(btn)

#	EVALUATE THE PLAYER'S CHOICES
func choice_evaluation(choice):
	var dict = debug_dict.get(quiz_stage)
	if choice == dict["correct_choice"]:
		if quiz_stage < debug_dict.size() - 1:  # Not the last question
			quiz_stage += 1
			load_dict(quiz_stage)
		else:  # Last question
			GlobalConfig.programming_tasks_completed += 1
			GlobalConfig.current_time += 3  # Add 3 hours for each task
			print("Programming task", GlobalConfig.programming_tasks_completed, "completed")
			GlobalConfig.finished_programming_task = true  # For compatibility
			get_tree().change_scene_to_file("res://scenes/game.tscn")
	else:
		print("Wrong Choice")

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
