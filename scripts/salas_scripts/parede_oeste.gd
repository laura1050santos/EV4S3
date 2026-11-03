extends "res://scripts/salas_scripts/salas_manager.gd"
@onready var som_cuckoo = $cuckoo/listenerCuckoo/Cuckoo

func _ready():
	GlobalSingleton.ultima_cena =  get_tree().current_scene.scene_file_path
	var nome_desta_cena = self.name # O nome do nó raiz desta cena
	Objetos.garantir_padrao(nome_desta_cena)
	var objetos = Objetos.get_objetos_cena(nome_desta_cena)
	iniciar_itens_cena(nome_desta_cena, objetos)


func _on_cuckoo_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		som_cuckoo.play(1.4)
	 # Replace with function body.
