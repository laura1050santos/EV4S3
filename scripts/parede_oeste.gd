extends Node2D

func _ready():
	var nome_desta_cena = self.name # O nome do nó raiz desta cena
	
	for info in GlobalSingleton.itens_no_mundo:
		# SÓ INSTANCIA SE A CENA FOR A CORRETA
		if info.cena == nome_desta_cena:
			var node = preload("res://scenes/worldItem.tscn").instantiate()
			node.set_meta("item_data", info.data)
			node.texture = info.data.icon 
			
			add_child(node)
			node.global_position = info.pos
