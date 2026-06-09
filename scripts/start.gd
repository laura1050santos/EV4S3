extends Control
# No script da sua CENA (ex: Level1.gd)
@onready var canvas = Inventario.get_node("canvasLayer")
func _ready() -> void:
	canvas.hide()
	
func _on_jogar_pressed():
	canvas.show()
	get_tree().change_scene_to_file("res://scenes/fase1/ParedeNorte.tscn")

func _on_sair_pressed():
	get_tree().quit()

func _on_creditos_pressed():
	get_tree().change_scene_to_file("res://scenes/telaInicial/creditos.tscn")
	
func _on_configuracao_pressed():
	get_tree().change_scene_to_file("res://scenes/telaInicial/configuracao.tscn")


func _on_continuar_pressed() -> void:
	pass # Replace with function body.
