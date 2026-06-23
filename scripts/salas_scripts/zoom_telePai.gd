extends Node2D

@onready var label = get_node("Label")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_ponto_pressed() -> void:
	if label.text == "sua mensagem irá aparecer aqui":
		label.text = "."
	else: 
		label.text = label.text+ "."

func _on_traco_pressed() -> void:
	if label.text == "sua mensagem irá aparecer aqui":
		label.text = "-"# Replace with function body.
	else:
		label.text = label.text+"-"


func _on_reset_pressed() -> void:
	label.text == "" # Replace with function body.
