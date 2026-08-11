extends "res://scripts/salas_scripts/salas_manager.gd"

func _ready():
	var nome_desta_cena = self.name # O nome do nó raiz desta cena

	var itens_iniciais=[
		{ "item": preload("res://recursos/placaMae.tres"),
		"pos":Vector2(600,400),
		"cena":nome_desta_cena,
		},#itens que começam na cena
	]
	iniciar_itens_cena(nome_desta_cena, itens_iniciais)
	
		
	var placa = get_tree().root.get_node("CenaChao/placa")
	if placa :
		print("placa mae na cena")
		placa.visible = false
		var area = placa.get_node("Area2D/CollisionShape2D")
		area.disabled= true
	#precisa arrumar a Placa Mãe
