
extends Control

const WORLD_ITEM = preload("res://scenes/worldItem.tscn")
func _ready():
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	for info in GlobalSingleton.itens_no_mundo:
		var node = WORLD_ITEM.instantiate()
		node.set_meta("item_data", info.data)
		
		if node is Sprite2D:
			node.texture = info.data.icon 
			
			# Forma correta de checar se o nó de colisão existe na estrutura interna:
			if node.has_node("Area2D/CollisionShape2D"):
				print("A colisão do item recarregado está presente!")
				
		# Dica: Em vez de add_child(node) que adiciona na UI, 
		# adicione na cena do mundo para a física funcionar melhor:
		get_tree().current_scene.add_child(node)
		node.global_position = info.posS


func _notification(what):
	# Quando um "Drag" começa no jogo, a gente ativa a área de drop
	if what == NOTIFICATION_DRAG_BEGIN:
		mouse_filter = Control.MOUSE_FILTER_STOP
	# Quando o "Drag" termina, a gente volta a ignorar
	elif what == NOTIFICATION_DRAG_END:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return true
	
#tirar o item do inventario:
func _drop_data(at_position: Vector2, data: Variant) -> void:
	var item_para_dropar = data.item
	var node = WORLD_ITEM.instantiate()
	node.set_meta("item_data", item_para_dropar)
	if node is Sprite2D:
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

#colocar o item no inventario
# colocar o item no inventario
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			
			# CORREÇÃO: Pega o mundo 2D a partir da cena atual do jogo, não do Control
			var cena_atual = get_tree().current_scene
			if not cena_atual.is_inside_tree(): return
			
			var world_2d = cena_atual.get_world_2d()
			if not world_2d: return
			
			var space_state = world_2d.direct_space_state
			var parameters = PhysicsPointQueryParameters2D.new()
			parameters.position = get_global_mouse_position()
			parameters.collide_with_areas = true  # Detectar nossa Area2D
			parameters.collide_with_bodies = false # Evita colidir com o chão/paredes
			
			var result = space_state.intersect_point(parameters)
			
			if not result.is_empty():
				# O collider retornado pelo intersect_point é a Area2D
				var area_clicada = result[0].collider
				var item_raiz = area_clicada
				
				# Baseado no seu print da árvore: Sprite2D (raiz) -> Area2D
				# Se clicamos na Area2D, o meta "item_data" está no pai (Sprite2D)
				if not item_raiz.has_meta("item_data") and item_raiz.get_parent() != null:
					item_raiz = item_raiz.get_parent()
				
				if item_raiz.has_meta("item_data"):
					var item_pego = item_raiz.get_meta("item_data")
					
					# Procura um slot vazio no inventário
					for slot in %GridContainer.get_children():
						if slot.item == null:
							slot.item = item_pego
							slot.update_ui()

							# REMOVER DO SINGLETON
							GlobalSingleton.remover_item(item_pego)

							# Deleta o nó do mundo de forma segura
							item_raiz.queue_free()
							return # Item guardado, interrompe o processo
func _on_corpo_detectado(Node2D)->void:
	print("teste")
	pass
