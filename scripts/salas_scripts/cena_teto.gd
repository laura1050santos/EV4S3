extends "res://scripts/salas_scripts/salas_manager.gd"
func _ready():
	var nome_desta_cena = self.name # O nome do nó raiz desta cena

	var itens_iniciais=[

{
"item": preload("res://recursos/flan.tres"),
"pos": Vector2(570, 380),

"cena": nome_desta_cena
},
#itens que começam na cena
]
	iniciar_itens_cena(nome_desta_cena, itens_iniciais)
	
func _on_area_lampada_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	var lampada = get_node_or_null("LampadaNova")
	if lampada:
		lampada.position = Vector2(575,250)
		print(lampada, "interruptor deve funcionar agr")
	else:
		print("lampada não encontrada")#ativar o interruptor
