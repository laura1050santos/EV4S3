class_name SalasManager
extends Node2D

func iniciar_itens_cena(nome_desta_cena, itens):
	# 1. remove os nós de itens já existentes nesta cena
	for n in get_tree().get_nodes_in_group("itens_cena"):
		n.queue_free()

	# 2. remove do singleton as entradas desta cena
	GlobalSingleton.itens_no_mundo = GlobalSingleton.itens_no_mundo.filter(
		func(i): return i.cena != nome_desta_cena
	)

	# 3. cria de novo
	for info in itens:
		spawnar_itens(info["item"], info["pos"])

	GlobalSingleton.registrar_transicao(scene_file_path)

func spawnar_itens(item_ou_caminho, posicao):
	var recurso: Resource
	if item_ou_caminho is Resource:
		recurso = item_ou_caminho
	else:
		recurso = load(item_ou_caminho)

	if not recurso:
		print("Salas_Manager -> ERRO: recurso nulo")
		return null

	# Já existe um item com esse nome nesta cena? Não cria outro.
	if has_node(NodePath(recurso.item_name)):
		return get_node(NodePath(recurso.item_name))

	var node = preload("res://scenes/inventario/worldItem.tscn").instantiate()
	node.set_meta("item_data", recurso)
	node.name = recurso.item_name

	if recurso.item_ativo:
		node.texture = recurso.ativo_icon
	else:
		node.texture = recurso.icon

	add_child(node)
	node.global_position = posicao

	ativar_item_ao_resconstruir(recurso, node)
	return node
	
func ativar_item_ao_resconstruir(item, node):
	match item.item_name:
		"lanterna":
			# Chama no próprio objeto 'item' que foi passado como parâmetro
			if item.has_method("ativar_luz"):
				item.ativar_luz(item, node, node.global_position)

func adicionar_item_na_sala(recurso, posicao):
	GlobalSingleton.registrar_item(recurso, posicao, self.name)
	# Instancia fisicamente na tela
	spawnar_itens(recurso, posicao)
