
extends Control

const WORLD_ITEM = preload("res://scenes/worldItem.tscn")
func _ready():
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	for info in GlobalSingleton.itens_no_mundo:
		var node = preload("res://scenes/worldItem.tscn").instantiate()
		node.set_meta("item_data", info.data)
		# Se o seu worldItem for um Sprite2D:
		node.texture = info.data.icon 

		add_child(node)
		node.global_position = info.pos


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
	var item_para_dropar = data.item
	var node = WORLD_ITEM.instantiate()
	node.set_meta("item_data", item_para_dropar)
	node.texture = item_para_dropar.icon
	
	get_tree().current_scene.add_child(node)
	node.global_position = get_global_mouse_position() 
	# colocar funcção para arrastar o item diretamente pra a posição e cena original
	
	# PEGANDO O NOME DA CENA ATUAL
	var nome_cena_atual = get_tree().current_scene.name
	
	# PASSANDO O NOME PARA O SINGLETON
	GlobalSingleton.registrar_item(item_para_dropar, node.global_position, nome_cena_atual)
	
	data.item = null
	data.update_ui()


func _input(event: InputEvent)-> void:
	#criar função par adicionar uma area para poder calcular se o mouse pegou nessa area ou não
	if event is InputEventMouseButton and event.double_click :
			var space_state = get_world_2d().direct_space_state
			var parameters = PhysicsPointQueryParameters2D.new()
			parameters.position = get_global_mouse_position()
			parameters.collide_with_areas = true # Para detectar Area2D
			var result = space_state.intersect_point(parameters)
			
			if result:
				var target = result[0].collider
				# 3. Verificar se é um item coletável (usando Meta igual ao vídeo)
				if not target.has_meta("item_data") and target.get_parent().has_meta("item_data"):
					target = target.get_parent()
					if target.has_meta("item_data"):
						# ... dentro do seu if target.has_meta("item_data"):
						var item_pego = target.get_meta("item_data")
						
						for slot in %GridContainer.get_children():
							if slot.item == null:
								slot.item = item_pego
								slot.update_ui()

								# REMOVER DO SINGLETON
								GlobalSingleton.remover_item(item_pego)

								target.queue_free()
								return
