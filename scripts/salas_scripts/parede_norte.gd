extends "res://scripts/salas_scripts/salas_manager.gd"
@onready var meu_sprite = $interruptor

func _ready():
	var nome_desta_cena = self.name # O nome do nó raiz desta cena

	var itens_iniciais=[
		{ "item": preload("res://recursos/Mala.tres"),
		"pos":Vector2(750,490),
		"cena":nome_desta_cena,
		},#itens que começam na cena
	]
	iniciar_itens_cena(nome_desta_cena, itens_iniciais)
 	


func _on_area_interruptor_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:
		for i in GlobalSingleton.itens_no_mundo:
			print(i)
		
		GlobalSingleton.interruptor_acesso = !GlobalSingleton.interruptor_acesso

		meu_sprite.visible = GlobalSingleton.interruptor_acesso

		print("Interruptor:", GlobalSingleton.interruptor_acesso)

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event:
		for info in GlobalSingleton.itens_no_mundo:
			var nome_item = (info.get("data").item_name)
			if nome_item == "":
				get_tree().change_scene_to_file("res://scenes/start.tscn")
			 # Replace with function body.
