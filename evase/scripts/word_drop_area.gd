extends Control
const WORLD_ITEM = preload("res://scenes/Sprite_2D.tscn")


func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return true
	
func _drop_data(at_position: Vector2, data: Variant) -> void:
	var node = WORLD_ITEM.instantiate()
	node.set_meta("item_data", data.item)
	node.texture = data.item.icon  # Se o nó raiz já for o Sprite2D
	
	get_tree().current_scene.add_child(node)
	data.item =null
	node.global_position= Vector2i(randf(), randf())
