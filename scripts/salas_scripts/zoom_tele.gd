extends Area2D

signal seta_clicada
@export_file("*.tscn") var destino_cena:String

func _ready():
	self.input_event.connect(_inout_event)
func _inout_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		trocar()
func trocar():
	if destino_cena==null or destino_cena=="":
		print("Campo vazio no inspetor")
		
	print("Tentando ir para: ", destino_cena)
	var erro = get_tree().call_deferred("change_scene_to_file", destino_cena)
	if erro==OK:
		print("erro ao carregar cena",erro)
	else:
		print("Erro")
