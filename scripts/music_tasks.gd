extends Control

var sequence = []
var player_sequence = []
var current_index = 0
var buttons = []
var sounds = []
var audio_player
var is_player_turn = false
var round_label
var score = 0
var score_label
var progress_bar
var timer_label
var sequence_timer
var hint_button
var slow_button
var original_playback_speed = 0.5
var playback_speed = 0.5
var note_delay = 0.8  # Delay between notes in seconds

func _ready():
	randomize()
	buttons = [
		$GridContainer/TextureButton,
		$GridContainer/TextureButton2,
		$GridContainer/TextureButton3,
		$GridContainer/TextureButton4,
		$GridContainer/TextureButton5,
		$GridContainer/TextureButton6,
		$GridContainer/TextureButton7,
		$GridContainer/TextureButton8,
		$GridContainer/TextureButton9
	]
	sounds = [
		preload("res://assets/sounds/D#6.ogg"),
		preload("res://assets/sounds/C#6.ogg"),
		preload("res://assets/sounds/A#5.ogg"),
		preload("res://assets/sounds/F#5.ogg"),
		preload("res://assets/sounds/D#5.ogg"),
		preload("res://assets/sounds/C#5.ogg"),
		preload("res://assets/sounds/F#4.ogg"),
		preload("res://assets/sounds/D#4.ogg"),
		preload("res://assets/sounds/C#4.ogg"),
		preload("res://assets/sounds/failed.mp3")  # for wrong
	]
	audio_player = $AudioStreamPlayer
	round_label = $RoundLabel
	score_label = $ScoreLabel
	progress_bar = $ProgressBar
	timer_label = $TimerLabel
	sequence_timer = $SequenceTimer
	hint_button = $HintButton
	slow_button = $SlowButton
	update_score_label()
	update_progress_bar()
	start_game()

func start_game():
	sequence = []
	player_sequence = []
	current_index = 0
	add_random_note()
	update_round_label()
	play_sequence()

func update_round_label():
	round_label.text = "Sequence Length: " + str(sequence.size())

func update_score_label():
	score_label.text = "Score: " + str(score)

func update_progress_bar():
	progress_bar.value = sequence.size() * 20.0

func update_timer_label():
	timer_label.text = "Time: " + str(int(sequence_timer.time_left))

func add_random_note():
	var rand_index = randi() % 9
	sequence.append(rand_index)

func _on_hint_pressed():
	if score >= 200 and is_player_turn and current_index < sequence.size():
		score -= 200
		update_score_label()
		var next_note = sequence[current_index]
		buttons[next_note].self_modulate *= 2
		await get_tree().create_timer(1.0).timeout
		buttons[next_note].self_modulate /= 2

func _on_slow_pressed():
	if score >= 200:
		score -= 200
		update_score_label()
		playback_speed = 1.0  # slower visual feedback
		note_delay = 1.2  # slower delay between notes
		await get_tree().create_timer(5.0).timeout  # duration
		playback_speed = original_playback_speed
		note_delay = 0.8

func _on_sequence_timer_timeout():
	if is_player_turn:
		# timeout, treat as failure
		score -= 100
		update_score_label()
		audio_player.stream = sounds[9]
		audio_player.play()
		await get_tree().create_timer(1.0).timeout
		player_sequence = []
		current_index = 0
		play_sequence()



func play_sequence():
	is_player_turn = false
	for button in buttons:
		button.disabled = true
	for note in sequence:
		await get_tree().create_timer(note_delay).timeout
		buttons[note].self_modulate *= 2  # brighter
		audio_player.stream = sounds[note]
		audio_player.play()
		await get_tree().create_timer(playback_speed).timeout
		buttons[note].self_modulate /= 2
	await get_tree().create_timer(0.5).timeout
	for button in buttons:
		button.disabled = false
	is_player_turn = true

func _on_button_pressed(index):
	if not is_player_turn:
		return
	if current_index == 0 and not sequence_timer.is_stopped():
		sequence_timer.start()
	player_sequence.append(index)
	audio_player.stream = sounds[index]
	audio_player.play()
	# Bounce animation
	var tween = create_tween()
	tween.tween_property(buttons[index], "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(buttons[index], "scale", Vector2(1, 1), 0.1)
	if player_sequence[current_index] != sequence[current_index]:
		# wrong
		score -= 100
		update_score_label()
		audio_player.stream = sounds[9]  # failed
		audio_player.play()
		await get_tree().create_timer(1.0).timeout
		# reset current sequence
		player_sequence = []
		current_index = 0
		sequence_timer.stop()
		play_sequence()
		return
	score += 200
	update_score_label()
	current_index += 1
	if current_index == sequence.size():
		# sequence complete
		sequence_timer.stop()
		if sequence.size() == 5:
			play_melody()
			await get_tree().create_timer(2.0).timeout
			get_tree().change_scene_to_file("res://scenes/main.tscn")
		else:
			player_sequence = []
			current_index = 0
			add_random_note()
			update_round_label()
			update_progress_bar()
			play_sequence()

func play_melody():
	is_player_turn = false
	for note in sequence:
		audio_player.stream = sounds[note]
		audio_player.play()
		await get_tree().create_timer(note_delay).timeout
