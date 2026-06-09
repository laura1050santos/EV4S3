extends "res://scripts/salas_scripts/salas_manager.gd"
func _ready():
	var nome_desta_cena = self.name # O nome do nó raiz desta cena

	var itens_iniciais=[

{

"item": preload("res://recursos/lanterna.tres"),

"pos": Vector2(500, 550),

"cena": nome_desta_cena

},
#itens que começam na cena
]
	iniciar_itens_cena(nome_desta_cena, itens_iniciais)

	
	

		
