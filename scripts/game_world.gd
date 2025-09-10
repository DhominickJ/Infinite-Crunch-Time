extends Node2D

@onready var asset_nodes = {
	"character": $character,
	"cherry": $cherry,
	"slime": $slime
}

# Static positions for dynamic sprites
var asset_positions = {
	"tree": Vector2(369, 40),
	"stone": Vector2(270, 43),
	"house": Vector2(392, 48)
}

# Music playback
var sounds = [
	preload("res://assets/sounds/D#6.ogg"),
	preload("res://assets/sounds/C#6.ogg"),
	preload("res://assets/sounds/A#5.ogg"),
	preload("res://assets/sounds/F#5.ogg"),
	preload("res://assets/sounds/D#5.ogg"),
	preload("res://assets/sounds/C#5.ogg"),
	preload("res://assets/sounds/F#4.ogg"),
	preload("res://assets/sounds/D#4.ogg"),
	preload("res://assets/sounds/C#4.ogg")
]

@onready var music_player = $AudioStreamPlayer
@onready var music_timer = $Timer
var current_note_index = 0

func _ready():
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