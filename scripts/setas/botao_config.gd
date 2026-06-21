extends Node2D
@onready var configMenu = preload("res://scenes/telaInicial/configuracao.tscn")



func _on_button_pressed() -> void:
	var menu = get_node_or_null("menu")
	if not menu :
		print(menu)
		menu = configMenu.instantiate()
		add_child(menu)
	 
	# Replace with function body.
