extends "res://scripts/salas_scripts/salas_manager.gd"

var SetaBaixo = $SetaBaixo
var SetaCima = $setaCima

func _ready():
<<<<<<< HEAD
	SetaBaixo.connect()
=======
	GlobalSingleton.ultima_cena = get_tree().current_scene.scene_file_path
>>>>>>> fcc3b7aa233e096bc105973ab7b747efa7fdf661
	var nome_desta_cena = self.name # O nome do nó raiz desta cena

	var itens_iniciais=[]
	iniciar_itens_cena(nome_desta_cena, itens_iniciais)
