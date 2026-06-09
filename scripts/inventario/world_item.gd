extends Sprite2D

# Dentro de world_item.gd
func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:	
#o Codigo detecta outro objeto aqui
	var meus_dados = get_meta("item_data") if has_meta("item_data") else null
	# Varre a lista de DICIONÁRIOS no Singleton
	for info_item in GlobalSingleton.itens_no_mundo:
		# info_item é um dicionário: {"data": Resource, "pos": Vector2, "cena": String}
		
		# Compara o Resource para garantir que não é o mesmo item que foi clicado
		if info_item.data != meus_dados: 
			print("Achei os dados de OUTRO item registrado!")
			print("Nome do Resource do item: ", info_item.data.resource_path.get_file()) 
			print("Ele está salvo na cena: ", info_item.cena)
			print("A posição salva dele é: ", info_item.pos)
			
	#o Codigo detecta interação com o mouse aqui
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("Cliquei em mim mesmo: ", name)
