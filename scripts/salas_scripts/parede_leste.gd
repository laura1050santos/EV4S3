extends "res://scripts/salas_scripts/salas_manager.gd"
func _ready():
	var nome_desta_cena = self.name # O nome do nó raiz desta cena
<<<<<<< Updated upstream

	var itens_iniciais=[

		{
		"item": preload("res://recursos/lanterna.tres"),
		"pos": Vector2(500, 550),
		"cena": nome_desta_cena
		},
#itens que começam na cena
]
	iniciar_itens_cena(nome_desta_cena, itens_iniciais)

	
	
=======
	#var objetos = Objetos.get_objetos_cena(nome_desta_cena)
	Objetos.garantir_padrao(nome_desta_cena)
	var objetos = Objetos.get_objetos_cena(nome_desta_cena)
	iniciar_itens_cena(nome_desta_cena, objetos)
>>>>>>> Stashed changes

		
