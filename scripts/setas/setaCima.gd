extends Area2D

signal seta_clicada
@export_file("*.tscn") var destino_cena:String

func _ready():
	self.input_event.connect(_inout_event)
func _inout_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		trocar()
func trocar():
	var destino := destino_cena

	if destino == "":
		destino = GlobalSingleton.obter_cena_anterior()

	print("Tentando ir para: ", destino)
	get_tree().change_scene_to_file(destino)
