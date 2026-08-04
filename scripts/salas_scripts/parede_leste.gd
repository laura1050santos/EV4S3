extends "res://scripts/salas_scripts/salas_manager.gd"
func _ready():
	GlobalSingleton.ultima_cena =  get_tree().current_scene.scene_file_path
	var nome_desta_cena = self.name # O nome do nó raiz desta cena

	var itens_iniciais=[

		{
		"item": preload("res://recursos/lanterna.tres"),
		"pos": Vector2(500, 550),
		"cena": nome_desta_cena
		},
		{
		"item": preload("res://recursos/chaveDeFenda.tres"),
		"pos": Vector2(770, 470),
		"cena": nome_desta_cena
		},
#itens que começam na cena
]
	iniciar_itens_cena(nome_desta_cena, itens_iniciais)

	
	

		


func _on_pc_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	get_tree().change_scene_to_file("res://scenes/fase1/zoom_monitor.tscn") # Replace with function body.


func _on_monitor_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	get_tree().change_scene_to_file("res://scenes/fase1/zoom_monitor.tscn") # Replace with function body.
