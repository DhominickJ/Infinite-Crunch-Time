extends CharacterBody2D

@export var speed: float = 50
var player: Node = null
var is_dead: bool = false

@onready var vision_area = $enemy_detect
@onready var respawn_timer: Timer = $Timer   # Add a Timer as child of Enemy
@onready var hitbox = $"body_hitbox&hurtbox"

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
	add_to_group("enemy")
	vision_area.area_entered.connect(_on_VisionArea_area_entered)
	vision_area.area_exited.connect(_on_VisionArea_area_exited)
	hitbox.area_entered.connect(on_enemy_hits_player)
	hitbox.area_entered.connect(on_player_attack_hits_enemy)
	respawn_timer.one_shot = false
	respawn_timer.wait_time = 10.0
	respawn_timer.timeout.connect(_on_respawn_timeout)

func _physics_process(delta: float) -> void:
	enemy_movement()
	if not is_on_floor():
			velocity.y += gravity * delta
	move_and_slide()



func enemy_movement():
	if player:
		# Move towards player
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed
	else:
		velocity = Vector2.ZERO  # stop if no player in range
		

# 1. Enemy collides with player's Area2D
func on_enemy_hits_player(area: Area2D) -> void:
	if area.name == "hurtbox":  # rename based on your player's Area2D node
		print("player is damaged")

# 2. If player's Collision2D collides with enemy → enemy dies
func on_player_attack_hits_enemy(area: Area2D) -> void:
	if area.name == "hitbox":  # adjust to your player's attack/hitbox node
		die()

# Enemy death
func die() -> void:
	if not is_dead:
		is_dead = true
		hide()# hide enemy visually
		$base_collision.set_deferred("disabled", true)
		vision_area.monitoring = false
		velocity = Vector2.ZERO
		respawn_timer.start()

# 3. Respawn enemy 10 seconds later
func _on_respawn_timeout() -> void:
	is_dead = false
	show()
	$base_collision.disabled = false
	vision_area.monitoring = true

func _on_VisionArea_area_entered(area: Area2D) -> void:
	if area.name == "hurtbox": 
		player = area
func _on_VisionArea_area_exited(area: Area2D) -> void:
	if area == player:
		player = null
