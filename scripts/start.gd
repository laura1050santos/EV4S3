extends Control

@onready var canvas = Inventario.get_node("canvasLayer")
@onready var label = get_node("Label")

func _ready() -> void:
	canvas.hide()
	
func _on_jogar_pressed():
	get_tree().change_scene_to_file("res://scenes/telaInicial/selecao_fases.tscn")

func _on_sair_pressed():
	get_tree().quit()

func _on_creditos_pressed():
	get_tree().change_scene_to_file("res://scenes/telaInicial/creditos.tscn")
	
func _on_configuracao_pressed():
	get_tree().change_scene_to_file("res://scenes/telaInicial/configuracao.tscn")


func _on_continuar_pressed() -> void:
	if SaveManager.carregar():
		label.text = "Nenhum save encontrado"
		label.show()
		await get_tree().create_timer(1.0).timeout

		label.hide()
