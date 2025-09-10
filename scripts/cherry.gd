extends Area2D

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var respawn_timer = $Timer

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	respawn_timer.one_shot = true
	respawn_timer.wait_time = 5.0
	respawn_timer.timeout.connect(_on_RespawnTimer_timeout)

func _on_area_entered(area: Area2D) -> void:
	if area.name == "hurtbox":
		hide_item()
		respawn_timer.start()

func hide_item() -> void:
	sprite.hide()
	collision.disabled = true

func show_item() -> void:
	sprite.show()
	collision.disabled = false

func _on_RespawnTimer_timeout() -> void:
	show_item()
	
