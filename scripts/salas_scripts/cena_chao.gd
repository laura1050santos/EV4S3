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
	get_node("Sprite2D").z_index=1
	if $ChaoAberto.visible == false:
		$placa/Area2D/CollisionShape2D.set_deferred("disabled", true)
