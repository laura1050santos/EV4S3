extends Control

const WORLD_ITEM = preload("res://scenes/inventario/worldItem.tscn")


func _ready():
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_to_group("world_drop_area")


func _notification(what):
	if what == NOTIFICATION_DRAG_BEGIN:
		mouse_filter = Control.MOUSE_FILTER_STOP

	elif what == NOTIFICATION_DRAG_END:
		mouse_filter = Control.MOUSE_FILTER_PASS


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return true


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var item_para_dropar = data.item

	if item_para_dropar == null:
		return

	print("word_drop -> Item dropado")


	# =====================================================
	# TENTAR COLOCAR EM ESTAÇÃO
	# =====================================================

	var estacao = estacao_sob_mouse()

	if estacao != null:
		if estacao.colocar_item(item_para_dropar):
			data.item = null
			data.update_ui()
			return


	# =====================================================
	# SOLTAR NO MUNDO
	# =====================================================

	var node = WORLD_ITEM.instantiate()

	node.set_meta(
		"item_data",
		item_para_dropar
	)

	node.name = item_para_dropar.item_name


	if item_para_dropar.item_ativo:
		node.texture = item_para_dropar.ativo_icon
	else:
		node.texture = item_para_dropar.icon


	get_tree().current_scene.add_child(node)

	node.global_position = get_global_mouse_position()


	var nome_cena_atual = (
		get_tree().current_scene.name
	)


	Objetos.soltar_por_recurso(
		item_para_dropar.resource_path,
		node.global_position,
		nome_cena_atual
	)


	data.item = null
	data.update_ui()


# =========================================================
# USAR ITEM
# =========================================================

func usar_item(
	item: itemData,
	node: Node
):
	if item == null:
		return


	print(
		"word_drop_area -> Item clicado com botão direito no cenário: ",
		item.item_name
	)


	item.item_ativo = !item.item_ativo


	var lst = [
		"lanterna",
		"chave de fenda"
	]


	if item.item_ativo:
		GlobalSingleton.item_mao = item

		print(
			"word_drop_area -> ITEM EQUIPADO: ",
			item.item_name
		)

		node.texture = item.ativo_icon


		if item.item_name in lst:
			# ATENÇÃO:
			# Este trecho ainda será revisado depois.
			GlobalSingleton.remover_item(item)

			var root = get_tree().root

			node.reparent(root)

			node.z_index = 1
			node.name = item.item_name
			node.global_position = Vector2(
				750,
				590
			)


			if item.item_name == "lanterna":
				itemData.ativar_luz(
					item,
					node,
					node.global_position
				)


	else:
		GlobalSingleton.item_mao = null

		node.texture = item.icon


		if item.item_name == "lanterna":
			itemData.desligar_luz(
				item,
				node
			)


	for info in GlobalSingleton.itens_no_mundo:
		if info["data"] == item.resource_path:
			item.item_ativo = item.item_ativo


# =========================================================
# INPUT
# =========================================================

func _input(event: InputEvent) -> void:

	if (
		event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_RIGHT
		and event.pressed
	):
		var target = verify()

		if target != null:
			usar_item(
				target.item,
				target.node
			)


	if (
		event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_LEFT
		and event.pressed
	):
		var result = verify()

		if result == null:
			return


		var item_pego = result.item
		var node_pego = result.node


		for slot in %GridContainer.get_children():

			if slot.item == null:

				if item_pego.item_name == "lanterna":
					item_pego.item_ativo = false

					itemData.desligar_luz(
						item_pego,
						node_pego
					)


				slot.item = item_pego
				slot.update_ui()


				GlobalSingleton.remover_item(
					item_pego
				)


				node_pego.queue_free()

				return


# =========================================================
# VERIFICAR ITEM NO MUNDO
# =========================================================

func verify() -> Variant:
	var space_state = (
		get_world_2d().direct_space_state
	)


	var parameters = (
		PhysicsPointQueryParameters2D.new()
	)


	parameters.position = (
		get_global_mouse_position()
	)

	parameters.collide_with_areas = true


	var result = (
		space_state.intersect_point(
			parameters
		)
	)


	if result:
		var target = result[0].collider


		if (
			not target.has_meta("item_data")
			and
			target.get_parent().has_meta("item_data")
		):
			target = target.get_parent()


		if target.has_meta("item_data"):
			return {
				"item":
					target.get_meta("item_data"),

				"node":
					target
			}


	return null


# =========================================================
# ESTAÇÃO
# =========================================================

func estacao_sob_mouse() -> Node:
	var params = (
		PhysicsPointQueryParameters2D.new()
	)


	params.position = (
		get_global_mouse_position()
	)

	params.collide_with_areas = true


	for r in (
		get_world_2d()
		.direct_space_state
		.intersect_point(params)
	):

		if r.collider.is_in_group(
			"estacao"
		):
			return r.collider


	return null


# =========================================================
# INVENTÁRIO
# =========================================================

func guardar_no_inventario(
	item: itemData
) -> bool:

	if item == null:
		return false


	# Evita inserir o mesmo recurso duas vezes.
	if inventario_possui_item(item):
		print(
			"Item já está no inventário: ",
			item.item_name
		)

		return true


	for slot in %GridContainer.get_children():

		if slot.item == null:
			slot.item = item
			slot.update_ui()

			return true


	print(
		"Inventário cheio. Não foi possível guardar: ",
		item.item_name
	)

	return false


# =========================================================
# VERIFICAR DUPLICAÇÃO
# =========================================================

func inventario_possui_item(
	item: itemData
) -> bool:

	if item == null:
		return false


	for slot in %GridContainer.get_children():

		if slot.item == null:
			continue


		if (
			slot.item.resource_path
			==
			item.resource_path
		):
			return true


	return false


# =========================================================
# LIMPAR INVENTÁRIO
# =========================================================

func limpar_inventario() -> void:

	print(
		"=== LIMPANDO INVENTÁRIO ==="
	)


	for slot in %GridContainer.get_children():

		slot.item = null
		slot.update_ui()


	GlobalSingleton.item_mao = null


	print(
		"Inventário limpo."
	)


# =========================================================
# CARREGAR INVENTÁRIO DO SQLITE
# =========================================================

func carregar_inventario_do_banco() -> void:

	print(
		"=== CARREGANDO INVENTÁRIO DO SQLITE ==="
	)


	# Primeiro remove qualquer resíduo
	# que tenha ficado no Autoload.
	limpar_inventario()


	var itens_coletados = (
		Objetos.get_objetos_coletados()
	)


	print(
		"Itens coletados encontrados: ",
		itens_coletados.size()
	)


	for info in itens_coletados:

		if not info.has("item"):
			continue


		var item: itemData = info["item"]


		var sucesso = guardar_no_inventario(
			item
		)


		if not sucesso:
			push_warning(
				"Não foi possível restaurar "
				+ item.item_name
				+ " no inventário."
			)

			break


	print(
		"Inventário restaurado."
	)
