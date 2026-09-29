extends "res://scripts/salas_scripts/salas_manager.gd"

func _ready():
	GlobalSingleton.ultima_cena =  get_tree().current_scene.scene_file_path
	var nome_desta_cena = self.name # O nome do nó raiz desta cena
	var objetos = Objetos.get_objetos_cena(nome_desta_cena)
	iniciar_itens_cena(nome_desta_cena, objetos)
	 
	

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
				var lampada = get_node("lampadaNova")
				lampada.texture = preload("res://assets/itens/lampadatetoacesa.png")
				flan.z_index= 1
	
func lampada_arrumada():
	var lamp = get_node_or_null("lampadaNova")
	var flan = get_node_or_null("flan")
	if lamp and flan:
		if lamp.position == Vector2(575, 273) and flan.position == Vector2(575, 273):
				var lampada = Enigmas.get_nome("lampada")
				if lampada["resolvido"] == 0 :
					Enigmas.atualizar_enigma("lampada", 1)
					Objetos.atualizar_objeto("lampada", "res://recursos/lampada.tres",Objetos.pos_para_json(575, 273),"CenaTeto")
					Objetos.atualizar_objeto("flan", "res://recursos/flan.tres",Objetos.pos_para_json(575, 273),"CenaTeto")
