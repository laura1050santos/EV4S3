extends Control

@export var tela_senha: PackedScene
@export var tela_inicial: PackedScene
@export var tela_navegador: PackedScene

var tela_atual: Control = null

func _ready():
	ir_para(tela_senha)  # o PC sempre começa pedindo senha

func ir_para(cena: PackedScene):
	if tela_atual:
		tela_atual.queue_free()
	tela_atual = cena.instantiate()
	add_child(tela_atual)
