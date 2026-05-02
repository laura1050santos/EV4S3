extends Node2D

func _ready():

	var nome_desta_cena = self.name # O nome do nó raiz desta cena

	for info in GlobalSingleton.itens_no_mundo:
		# SÓ INSTANCIA SE A CENA FOR A CORRETA
		if info.cena == nome_desta_cena:
			var node = preload("res://scenes/worldItem.tscn").instantiate()
			node.set_meta("item_data", info.data)
			node.texture = info.data.icon 
			
			add_child(node)
			node.global_position = info.pos


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	#testando interações!!!
	if event:
		for info in GlobalSingleton.itens_no_mundo:
			var nome_item =(info.get("data").item_name)
			#se o nome do recurso que enconstou na porta for godot ele volta pro start
			#a logica funciona, é so mudar o objeto e o  nome do resurso
			if nome_item == "godot" :
				get_tree().change_scene_to_file("res://scenes/start.tscn")

					
