extends "res://scripts/salas_scripts/salas_manager.gd"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalSingleton.ultima_cena =  get_tree().current_scene.scene_file_path
	var nome_desta_cena = self.name # O nome do nó raiz desta cena

	var itens_iniciais=[
		{ "item": preload("res://recursos/gpu.tres"),
		"pos":Vector2(570,406),
		"cena":nome_desta_cena,
		}

#itens que começam na cena
]
	iniciar_itens_cena(nome_desta_cena, itens_iniciais)
	var gpu = get_node_or_null("gpu")
	if gpu:
		gpu.visible = false
		var collision = gpu.get_node("Area2D/CollisionShape2D")
		collision.disabled = true
 # Replace with function body.

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if InputEventMouseButton and event.is_pressed():		
		var chave =  get_node_or_null("chave")
		if chave:
			$lixeiraAberta.visible= true
			var gpu = get_node_or_null("gpu")
			if gpu:
				gpu.visible = true
				var collision = gpu.get_node("Area2D/CollisionShape2D")
				collision.disabled = false
		
