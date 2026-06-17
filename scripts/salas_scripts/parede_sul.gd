extends "res://scripts/salas_scripts/salas_manager.gd"

func _ready():
	var nome_desta_cena = self.name # O nome do nó raiz desta cena
	
	var itens_iniciais=[
		#itens que começam na cena
	
	]
	iniciar_itens_cena(nome_desta_cena, itens_iniciais)
	
@onready var meu_sprite = $Gaveta1Aquario
func _on_gaveta_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	# Verifica se o evento foi um clique do botão esquerdo do mouse
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		# Verifica se o botão foi pressionado (e não solto)
		if event.pressed:
			GlobalSingleton.sprite_visivel = not GlobalSingleton.sprite_visivel
			
			# 2. Aplica o novo estado visualmente no sprite
			meu_sprite.visible = GlobalSingleton.sprite_visivel
			print("Sprite ativado!")
			pass
