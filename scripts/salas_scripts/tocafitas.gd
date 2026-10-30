extends "res://scripts/salas_scripts/salas_manager.gd"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalSingleton.registrar_cena_atual(scene_file_path)
	var nome_desta_cena = self.name # O nome do nó raiz desta cena
	Objetos.garantir_padrao(nome_desta_cena)
	var objetos = Objetos.get_objetos_cena(nome_desta_cena) # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
