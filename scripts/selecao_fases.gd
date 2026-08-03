extends Control

@onready var botoes = [
	$Fase1Botao,
	$Fase2Botao,
	$Fase3Botao,
	$Fase4Botao
]
@onready var canvas = Inventario.get_node("canvasLayer")

func _ready():
	atualizar_botoes()
	canvas.hide()

func atualizar_botoes():
	for i in range(botoes.size()):
		var numero_fase = i + 1
		var botao = botoes[i]
		var liberada = numero_fase <= GlobalSingleton.fase_liberada
		var concluida = GlobalSingleton.fases_concluidas[i]

		botao.disabled = not liberada

		if concluida:
			botao.text = "Fase %d ✓" % numero_fase
		elif liberada:
			botao.text = "Fase %d" % numero_fase
		else:
			botao.text = "Fase %d 🔒" % numero_fase

func ir_para_fase(numero_fase: int):
	if numero_fase > GlobalSingleton.fase_liberada:
		return
	var caminho = GlobalSingleton.ultima_cena_por_fase[numero_fase]
	get_tree().change_scene_to_file(caminho)
	# Não precisa chamar SaveManager.salvar() aqui: o registro da cena
	# acontece sozinho no _ready() do salas_manager.gd assim que a cena carregar.

func _on_fase_1_botao_pressed():
	ir_para_fase(1)
	canvas.show()

func _on_fase_2_botao_pressed():
	ir_para_fase(2)

func _on_fase_3_botao_pressed():
	ir_para_fase(3)

func _on_fase_4_botao_pressed():
	ir_para_fase(4)
