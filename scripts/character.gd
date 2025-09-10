extends CharacterBody2D

@export var speed: float = 200
@export var jump_force: float = -400

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Handle input
	player_movement()
	player_jump()

	# Apply movement
	move_and_slide()

func player_movement():
	velocity.x = 0
	if Input.is_action_pressed("ui_right"):
		velocity.x += speed
	if Input.is_action_pressed("ui_left"):
		velocity.x -= speed

func player_jump():
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_force
		print("Jump")
