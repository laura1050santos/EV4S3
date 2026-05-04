extends Node2D

func iniciar_itens_cena(nome_desta_cena,itens_inciais):
	if not GlobalSingleton.cena_ja_foi_registrada(nome_desta_cena):
		for info in itens_inciais:
			GlobalSingleton.registrar_item(info.item, info.pos, nome_desta_cena)
		
		GlobalSingleton.registrar_cena_visitada(nome_desta_cena)
			
	for info in GlobalSingleton.itens_no_mundo:
		if info.cena == nome_desta_cena:
			spawnar_itens(info.data, info.pos)
			

func spawnar_itens(recurso,posicao):
	var node = preload("res://scenes/worldItem.tscn").instantiate()
	node.set_meta("item_data", recurso)
	node.texture = recurso.icon 
	add_child(node)
	node.global_position = posicao
