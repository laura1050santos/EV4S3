extends Node2D

@onready var label = get_node("Label")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_ponto_pressed() -> void:
	if label.text == "sua mensagem irá aparecer aqui":
		label.text = "."
	else: 
		label.text = label.text+ "."
	verificar_mensagem(label)

func _on_traco_pressed() -> void:
	if label.text == "sua mensagem irá aparecer aqui":
		label.text = "-"
	else: 
		label.text = label.text+ "-"
	verificar_mensagem(label)
	
func _on_reset_pressed() -> void:
	label.text = "" 
	verificar_mensagem(label)# Replace with function body.
	
func verificar_mensagem(label):
	var mensagem_correta= "-.-."
	if label.text == mensagem_correta:
		label.text ="Mensagem decodificada com sucesso"
		$traco.queue_free()
		$reset.queue_free()
		$ponto.queue_free()
