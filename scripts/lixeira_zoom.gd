extends "res://scripts/salas_scripts/salas_manager.gd"
@onready var som_lixeira_abrindo = $som_lixeira_abrindo

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalSingleton.ultima_cena = get_tree().current_scene.scene_file_path
	var nome_desta_cena = self.name # O nome do nó raiz desta cena
	Objetos.garantir_padrao(nome_desta_cena)
	var objetos = Objetos.get_objetos_cena(nome_desta_cena)
	iniciar_itens_cena(nome_desta_cena, objetos)
#itens que começam na cena
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
			som_lixeira_abrindo.play()
			var gpu = get_node_or_null("gpu")
			if gpu:
				gpu.visible = true
				var collision = gpu.get_node("Area2D/CollisionShape2D")
				collision.disabled = false
				Cenarios.atualizar_cenario("zoomLixeira","res://assets/itens/lixeirapertoaberta.png")
		
