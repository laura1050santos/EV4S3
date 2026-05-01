extends Sprite2D


# No script do seu Level/Mapa (ex: world.gd)
func _ready():
	# Espera um frame para garantir que tudo carregou
	await get_tree().process_frame
	
	for item_info in GlobalSingleton.itens_no_mundo:
		_instanciar_item_salvo(item_info.data, item_info.pos)

func _instanciar_item_salvo(resource, posicao):
	var node = preload("res://scenes/worldItem.tscn").instantiate()
	node.set_meta("item_data", resource)
	node.texture = resource.icon
	
	add_child(node)
	node.global_position = posicao
