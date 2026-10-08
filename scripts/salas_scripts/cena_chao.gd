extends "res://scripts/salas_scripts/salas_manager.gd"

func _ready():
	var chao = Cenarios.get_cena("chao")
	if chao:
		var sprite = load(chao["sprite"])
		print(chao,' ',sprite)
		$Sprite2D.texture= sprite
		
	GlobalSingleton.ultima_cena =  get_tree().current_scene.scene_file_path
	var nome_desta_cena = self.name # O nome do nó raiz desta cena
	Objetos.garantir_padrao(nome_desta_cena)
	var objetos = Objetos.get_objetos_cena(nome_desta_cena)
	iniciar_itens_cena(nome_desta_cena, objetos)
	

	var placa = get_tree().root.get_node("CenaChao/placa")
	if placa :
		print("placa mae na cena")
		placa.visible = false
		var area = placa.get_node("Area2D/CollisionShape2D")
		area.disabled= true
	#precisa arrumar a Placa Mãe
