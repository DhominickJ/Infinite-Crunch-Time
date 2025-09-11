extends CharacterBody2D

@export var speed: float = 200
@export var jump_force: float = -400

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

# Health system
var health: int = 100
var max_health: int = 100

func _ready() -> void:
	$hurtbox.body_entered.connect(_on_hurtbox_body_entered)

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

func _on_hurtbox_body_entered(body: Node2D):
	if body.is_in_group("enemy"):
		take_damage(10)

func take_damage(amount: int):
	health -= amount
	health = max(0, health)
	print("Player took damage, health: ", health)
	if health <= 0:
		print("Player died!")
		# Handle death, e.g., restart or game over
