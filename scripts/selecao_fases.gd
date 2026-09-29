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

# Dicionário definindo o ponto de partida padrão/inicial de cada fase
const CENAS_INICIAIS = {
	1: "res://scenes/fase1/ParedeNorte.tscn", # Ajuste o caminho exato da sua cena inicial da Fase 1
	2: "res://scenes/fase1/zoom_pc.tscn", # Ajuste o caminho exato da Fase 2 se necessário
	3: "res://scenes/fase3/parede_norte.tscn",
	4: "res://scenes/fase4/parede_norte.tscn"
}

func ir_para_fase(numero_fase: int):
	if numero_fase > GlobalSingleton.fase_liberada:
		return

	var caminho: String = ""

	# Para a Fase 1, força sempre a cena de início
	if numero_fase == 1:
		caminho = CENAS_INICIAIS[1]
	else:
		# Para as outras fases, tenta carregar a última cena visitada; se não existir, usa a inicial da fase
		if GlobalSingleton.ultima_cena_por_fase.has(numero_fase) and GlobalSingleton.ultima_cena_por_fase[numero_fase] != "":
			caminho = GlobalSingleton.ultima_cena_por_fase[numero_fase]
		else:
			caminho = CENAS_INICIAIS.get(numero_fase, "res://scenes/fase1/parede_norte.tscn")

	get_tree().change_scene_to_file(caminho)
	SaveManager.apagar_save()
	canvas.show()

func _on_fase_1_botao_pressed():
	ir_para_fase(1)

func _on_fase_2_botao_pressed():
	ir_para_fase(2)

func _on_fase_3_botao_pressed():
	ir_para_fase(3)

func _on_fase_4_botao_pressed():
	ir_para_fase(4)
	
func _on_sair_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/telaInicial/start.tscn")
