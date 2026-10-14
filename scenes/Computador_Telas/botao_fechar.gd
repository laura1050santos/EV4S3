extends Button

func _ready() -> void:
	pressed.connect(_fechar)

func _fechar() -> void:
	get_parent().hide()
