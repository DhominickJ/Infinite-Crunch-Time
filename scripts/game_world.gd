extends Node2D

@onready var asset_nodes = {
	"cherry": $cherry,
	"slime": $slime
}

@onready var back_button = $BackButton
@onready var next_day_button = $NextDayButton
@onready var player = $character
@onready var hp_bar = $hpBar
@onready var music_timer = $Timer
@onready var music_player = $AudioStreamPlayer

var current_note_index = 0
var sounds = []

# Static positions for dynamic sprites
var asset_positions = {
	"tree": Vector2(369, 40),
	"stone": Vector2(270, 43),
	"house": Vector2(392, 48)
}

func _ready():
	# Character is always visible (player)
	$character.visible = true
	
	# Show completed scene-based assets
	for asset_name in GlobalConfig.completed_art_assets:
		if asset_name in asset_nodes:
			asset_nodes[asset_name].visible = true
			print("Unlocked scene asset: ", asset_name)
	
	# Add completed sprite-based assets dynamically at their original positions
	for asset_name in GlobalConfig.completed_art_assets:
		if asset_name in asset_positions:
			var texture_path = "res://assets/sprites/" + asset_name + ".png"
			var texture = load(texture_path)
			if texture:
				var sprite = Sprite2D.new()
				sprite.texture = texture
				sprite.position = asset_positions[asset_name]
				sprite.visible = true
				add_child(sprite)
				print("Added completed sprite asset: ", asset_name)
	
	# Start background music if sequence exists
	if GlobalConfig.music_sequence.size() > 0:
		start_background_music()
	
	# Load sounds
	sounds = [
		load("res://assets/sounds/C#4.ogg"),
		load("res://assets/sounds/D#4.ogg"),
		load("res://assets/sounds/F#4.ogg"),
		load("res://assets/sounds/A#5.ogg"),
		load("res://assets/sounds/C#5.ogg"),
		load("res://assets/sounds/D#5.ogg"),
		load("res://assets/sounds/F#5.ogg"),
		load("res://assets/sounds/C#6.ogg"),
		load("res://assets/sounds/D#6.ogg")
	]

	# Show buttons after 5 seconds
	await get_tree().create_timer(5.0).timeout
	back_button.visible = true
	back_button.pressed.connect(_on_back_button_pressed)
	next_day_button.visible = true
	next_day_button.pressed.connect(_on_next_day_button_pressed)

func _process(delta):
	# Update HP bar
	hp_bar.value = player.health

func start_background_music():
	music_timer.wait_time = 0.8  # Note delay
	music_timer.timeout.connect(_on_music_timer_timeout)
	play_next_note()

func play_next_note():
	if GlobalConfig.music_sequence.size() == 0:
		return
	
	var note_index = GlobalConfig.music_sequence[current_note_index]
	if note_index >= 0 and note_index < sounds.size():
		music_player.stream = sounds[note_index]
		music_player.play()
	
	current_note_index += 1
	if current_note_index >= GlobalConfig.music_sequence.size():
		current_note_index = 0  # Loop back to start
	
	music_timer.start()

func _on_music_timer_timeout():
	play_next_note()

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_next_day_button_pressed():
	# Advance to next day
	GlobalConfig.days_left -= 1
	GlobalConfig.reset_day()
	print("Day advanced! Days left: ", GlobalConfig.days_left)
	# Return to main scene
	get_tree().change_scene_to_file("res://scenes/game.tscn")
