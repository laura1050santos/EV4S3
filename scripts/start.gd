extends Control
# No script da sua CENA (ex: Level1.gd)
@onready var canvas = Inventario.get_node("canvasLayer")
<<<<<<< Updated upstream
=======
@onready var label = get_node("Label")
const CAMINHO_SAVE = "user://save.json"

>>>>>>> Stashed changes
func _ready() -> void:
	canvas.hide()
	
func _on_jogar_pressed():
<<<<<<< Updated upstream
	canvas.show()
	get_tree().change_scene_to_file("res://scenes/fase1/ParedeNorte.tscn")
=======
	get_tree().change_scene_to_file("res://scenes/telaInicial/selecao_fases.tscn")
>>>>>>> Stashed changes

func _on_sair_pressed():
	get_tree().quit()

func _on_creditos_pressed():
	get_tree().change_scene_to_file("res://scenes/telaInicial/creditos.tscn")
	
func _on_configuracao_pressed():
	get_tree().change_scene_to_file("res://scenes/telaInicial/configuracao.tscn")


func _on_continuar_pressed() -> void:
<<<<<<< Updated upstream
	pass # Replace with function body.
=======
	if not FileAccess.file_exists(CAMINHO_SAVE):
		label.text = "Nenhum save encontrado"
		label.show()
		await get_tree().create_timer(1.0).timeout
		label.hide()
		return
	else:
		SaveManager.carregar()
>>>>>>> Stashed changes
