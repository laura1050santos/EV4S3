extends Control


@onready var canvas = Inventario.get_node("canvasLayer")
@onready var label = get_node("Label")

const CENA_SELECAO_FASES := "res://scenes/telaInicial/selecao_fases.tscn"

func _ready() -> void:
	canvas.hide()

# =========================================================
# NOVO JOGO
# =========================================================

func _on_jogar_pressed() -> void:
	SaveManager.novo_jogo()
	get_tree().change_scene_to_file(CENA_SELECAO_FASES)


# =========================================================
# CONTINUAR
# =========================================================

func _on_continuar_pressed() -> void:
	if not Progresso.existe_partida():
		label.text = "Nenhum save encontrado"
		label.show()
		await get_tree().create_timer(1.0).timeout
		label.hide()
		return

	SaveManager.carregar()


# =========================================================
# MENU
# =========================================================

func _on_sair_pressed() -> void:
	get_tree().quit()


func _on_creditos_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/telaInicial/creditos.tscn")


func _on_configuracao_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/telaInicial/configuracao.tscn")
