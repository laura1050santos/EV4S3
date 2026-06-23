extends Node2D
# salas_manager.gd

	
func iniciar_itens_cena(nome_desta_cena, itens_inciais):
	if not GlobalSingleton.cena_ja_foi_registrada(nome_desta_cena):
		for info in itens_inciais:
			GlobalSingleton.registrar_item(info.item, info.pos, nome_desta_cena)
		
		GlobalSingleton.registrar_cena_visitada(nome_desta_cena)
			
	for info in GlobalSingleton.itens_no_mundo:
		if info.cena == nome_desta_cena:
			#precisa saber se o item estava ativo
			spawnar_itens(info.data, info.pos)
			
	GlobalSingleton.registrar_transicao(scene_file_path)
	
	#GlobalSingleton.registrar_transicao(scene_file_path) travou de rodar com esse erro:
	# Invalid call. Nonexistent function 'registrar_transicao' in base 'Node (Global_singleton.gd)'. 

func spawnar_itens(recurso, posicao):
	var node = preload("res://scenes/inventario/worldItem.tscn").instantiate()
	node.set_meta("item_data", recurso)
	
	if recurso.item_ativo:
		node.texture = recurso.ativo_icon
	else:
		node.texture = recurso.icon 
	
	add_child(node)
	node.global_position = posicao
	ativar_item_ao_resconstruir(recurso,node)

	
func ativar_item_ao_resconstruir(item,node):
	match item.item_name:
		"lanterna":
			itemData.ativar_luz(
				item, node,node.global_position
			)

# Qualquer um pode chamar essa função para dropar/criar um item nesta sala
func adicionar_item_na_sala(recurso, posicao):
	GlobalSingleton.registrar_item(recurso, posicao, self.name)
	# 2. Instancia fisicamente na tela
	spawnar_itens(recurso, posicao)
	
