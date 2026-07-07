extends "res://scripts/salas_scripts/salas_manager.gd"

func _ready():
	var nome_desta_cena = self.name # O nome do nó raiz desta cena

	var itens_iniciais=[
{
"item": preload("res://recursos/LampadaQuebrada.tres"),
"pos": Vector2(575, 273),
"cena": nome_desta_cena
},
{
"item": preload("res://recursos/flan.tres"),
"pos": Vector2(575, 273),
"cena": nome_desta_cena
},
#itens que começam na cena
]
	iniciar_itens_cena(nome_desta_cena, itens_iniciais)
	

func _on_area_lampada_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	var lst =["lampadaNova","flan","lampadaQuebrada"]
	arrumar_posicao(lst)
	lampada_arrumada()
	
func arrumar_posicao(lst):
	for a in lst:
		if has_node(a):
			var sl = get_node(a)
			sl.position =  Vector2(575, 273)
			if a == "flan" and has_node("lampadaNova"):
				var flan = get_node("flan")
				flan.z_index= 1
	
func lampada_arrumada():
	var lamp = get_node_or_null("lampadaNova")
	var flan = get_node_or_null("flan")
	if lamp and flan:
		if lamp.position == Vector2(575, 273) and flan.position == Vector2(575, 273):
			if not has_node("lampadaQuebrada"):
				GlobalSingleton.enigma_luz_resolvido = true
				
