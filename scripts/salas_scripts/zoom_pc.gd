extends "res://scripts/salas_scripts/salas_manager.gd"

func _ready():
	GlobalSingleton.ultima_cena =  get_tree().current_scene.scene_file_path
	var nome_desta_cena = self.name # O nome do nó raiz desta cena

	var itens_iniciais=[
	]
	iniciar_itens_cena(nome_desta_cena, itens_iniciais)
 	

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if InputEventMouseButton and event.is_pressed():		
		var chave =  get_node_or_null("chave")
		if chave:
			$GabinetePc.queue_free()
		
		

func _on_slot_gpu_area_entered(area: Area2D) -> void:
	var objeto_detectado = area.get_parent()
	if objeto_detectado is Sprite2D and objeto_detectado.name == "gpu":
 # Replace with function body.
		objeto_detectado.global_position= Vector2(656,277)


func _on_slot_processador_area_entered(area: Area2D) -> void:
		var objeto_detectado = area.get_parent() 
		if objeto_detectado is Sprite2D and objeto_detectado.name == "processador":

			objeto_detectado.global_position= Vector2(524,395)
 # Replace with function body.


func _on_slot_placa_mae_area_entered(area: Area2D) -> void:
	print("SLA")
	var objeto_detectado = area.get_parent() 
	
	if objeto_detectado is Sprite2D and objeto_detectado.name == "PlacaMae":
		objeto_detectado.global_position = Vector2(362,266)
