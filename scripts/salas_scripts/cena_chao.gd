extends "res://scripts/salas_scripts/salas_manager.gd"
func _ready():
	var nome_desta_cena = self.name # O nome do nó raiz desta cena

	var itens_iniciais=[]
	iniciar_itens_cena(nome_desta_cena, itens_iniciais)
