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