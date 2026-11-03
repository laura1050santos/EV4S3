extends "res://scripts/salas_scripts/salas_manager.gd"
const SALA_CUCO_FECHADO = preload("res://assets/cenarios/salaestar_cucofechado.png")
const SALA_CUCO_ABERTO = preload("res://assets/cenarios/salaestar.png")
@onready var som_cuckoo = $cuckoo/listenerCuckoo/Cuckoo

func _ready():
	$Sprite2D.texture = SALA_CUCO_ABERTO if bool(Progresso.carregar("cuco_compartimento_aberto", false)) else SALA_CUCO_FECHADO
	GlobalSingleton.ultima_cena =  get_tree().current_scene.scene_file_path
	var nome_desta_cena = self.name # O nome do nó raiz desta cena
	Objetos.garantir_padrao(nome_desta_cena)
	var objetos = Objetos.get_objetos_cena(nome_desta_cena)
	iniciar_itens_cena(nome_desta_cena, objetos)


func _on_cuckoo_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		get_viewport().set_input_as_handled()
		get_tree().change_scene_to_file("res://scenes/fase3/zoom_cuco.tscn")
	 # Replace with function body.
