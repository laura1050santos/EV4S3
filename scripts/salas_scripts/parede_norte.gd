extends "res://scripts/salas_scripts/salas_manager.gd"
func _ready():
	GlobalSingleton.ultima_cena =  get_tree().current_scene.scene_file_path
	var nome_desta_cena = self.name # O nome do nó raiz desta cena

	var itens_iniciais=[
		{ "item": preload("res://recursos/Mala.tres"),
		"pos":Vector2(750,590),
		"cena":nome_desta_cena,
		},#itens que começam na cena
	]
	iniciar_itens_cena(nome_desta_cena, itens_iniciais)
 	


func interruptor_ativar():
	var LuzLampada = load("res://scenes/escuro.tscn").instantiate()
	print(LuzLampada.get_parent())
	var root = get_tree().root
	if root.get_node_or_null("Escuro/LuzLampada"):
		var luzNoRoot = root.get_node_or_null("Escuro/LuzLampada")
		if luzNoRoot.enabled == true:
			luzNoRoot.enabled =false
		else:
			luzNoRoot.enabled = true
	else:
		root.add_child(LuzLampada)
		LuzLampada= LuzLampada.get_child(1)
		LuzLampada.enabled= true
		print(LuzLampada.get_parent())
	
	
func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event:
		for info in GlobalSingleton.itens_no_mundo:
			var recurso = load(info.get("data"))
			var nome_item = recurso.item_name
			
			if nome_item == "RelogioCuco":
				get_tree().change_scene_to_file("res://scenes/start.tscn")
			 # Replace with function body.


func _on_area_interruptor_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if GlobalSingleton.enigma_luz_resolvido == true:
			interruptor_ativar()
