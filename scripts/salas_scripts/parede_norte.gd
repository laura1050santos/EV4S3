extends "res://scripts/salas_scripts/salas_manager.gd"
func _ready():
<<<<<<< HEAD
	
=======
	GlobalSingleton.ultima_cena = get_tree().current_scene.scene_file_path
>>>>>>> fcc3b7aa233e096bc105973ab7b747efa7fdf661
	var nome_desta_cena = self.name # O nome do nó raiz desta cena

	var itens_iniciais=[
		{ "item": preload("res://recursos/Mala.tres"),
		"pos":Vector2(750,590),
		"cena":nome_desta_cena,
		},#itens que começam na cena
	]
	iniciar_itens_cena(nome_desta_cena, itens_iniciais)
 	



func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event:
		for info in GlobalSingleton.itens_no_mundo:
			var nome_item = (info.get("data").item_name)
			var recurso = load(info.get("data"))
			var nome_item = recurso.item_name

			if nome_item == "RelogioCuco":
				get_tree().change_scene_to_file("res://scenes/start.tscn")
			 # Replace with function body.
