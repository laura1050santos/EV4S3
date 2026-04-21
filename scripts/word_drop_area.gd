extends Control
const WORLD_ITEM = preload("res://scenes/worldItem.tscn")

func _ready():
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _notification(what):
	# Quando um "Drag" começa no jogo, a gente ativa a área de drop
	if what == NOTIFICATION_DRAG_BEGIN:
		mouse_filter = Control.MOUSE_FILTER_STOP
	# Quando o "Drag" termina, a gente volta a ignorar
	elif what == NOTIFICATION_DRAG_END:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		
func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return true
	
func _drop_data(at_position: Vector2, data: Variant) -> void:
	var node = WORLD_ITEM.instantiate()
	node.set_meta("item_data", data.item)
	node.texture = data.item.icon  # Se o nó raiz já for o Sprite2D
	
	get_tree().current_scene.add_child(node)
	node.global_position= get_global_mouse_position()
	data.item =null
	data.update_ui()

func _input(event: InputEvent)-> void:
	if event is InputEventMouseButton and event.pressed:
			print("asd")
			var space_state = get_world_2d().direct_space_state
			var parameters = PhysicsPointQueryParameters2D.new()
			parameters.position = get_global_mouse_position()
			parameters.collide_with_areas = true # Para detectar Area2D
			
			
			var result = space_state.intersect_point(parameters)
		
		# 2. Se clicamos em algo...

			if result:
				print("Clique detectado em objeto físico")
				var target = result[0].collider

				# 3. Verificar se é um item coletável (usando Meta igual ao vídeo)
				if not target.has_meta("item_data") and target.get_parent().has_meta("item_data"):
					target = target.get_parent()

					if target.has_meta("item_data"):
						var item_pego =target.get_meta("item_data")
						# 4. Achar o primeiro slot vazio (Exatamente como na imagem)
						
						for slot in %GridContainer.get_children():
							
							if slot.item ==null: # Se o slot já tem item, pula pro próximo	
								# 5. Colocar o item no inventário e deletar do mundo
								slot.item = item_pego
								slot.update_ui()
								target.queue_free()
								print("Item coletado!") # Remove o item do chão
								return 
