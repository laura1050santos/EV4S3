extends "res://scripts/salas_scripts/salas_manager.gd"

var SetaBaixo = $SetaBaixo
var SetaCima = $setaCima

func _ready():
	SetaBaixo.connect()
	var nome_desta_cena = self.name # O nome do nó raiz desta cena

	var itens_iniciais=[]
	iniciar_itens_cena(nome_desta_cena, itens_iniciais)
