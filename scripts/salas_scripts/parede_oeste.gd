extends "res://scripts/salas_scripts/salas_manager.gd"


func _ready():
	GlobalSingleton.ultima_cena =  get_tree().current_scene.scene_file_path
	var nome_desta_cena = self.name # O nome do nó raiz desta cena
	var objetos = Objetos.get_objetos_cena(nome_desta_cena)
	iniciar_itens_cena(nome_desta_cena, objetos)
	 
