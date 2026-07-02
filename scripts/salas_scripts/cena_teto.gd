extends "res://scripts/salas_scripts/salas_manager.gd"
func _ready():
	var nome_desta_cena = self.name # O nome do nó raiz desta cena

	var itens_iniciais=[
{
"item": preload("res://recursos/LampadaQuebrada.tres"),
"pos": Vector2(575, 275),
"cena": nome_desta_cena
},
{
"item": preload("res://recursos/flan.tres"),
"pos": Vector2(575, 275),
"cena": nome_desta_cena
},
#itens que começam na cena
]
	iniciar_itens_cena(nome_desta_cena, itens_iniciais)
	

func _on_area_lampada_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if has_node("LampadaNova") and !has_node("Quebrada"):
		var lampadaNova = get_node("LampadaNova")
		lampadaNova.position= Vector2(575, 275)
		print("lampada trocada")
		
	
		 # Replace with function body.
