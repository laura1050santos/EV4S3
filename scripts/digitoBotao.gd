extends TextureButton

@export var digit_textures: Array[Texture2D] = [preload("res://assets/numeros/0.png"),
		preload("res://assets/numeros/1.png"),
		preload("res://assets/numeros/2.png"),
		preload("res://assets/numeros/3.png"),
		preload("res://assets/numeros/4.png"),
		preload("res://assets/numeros/5.png"),
		preload("res://assets/numeros/6.png"),
		preload("res://assets/numeros/7.png"),
		preload("res://assets/numeros/8.png"),
		preload("res://assets/numeros/9.png")]  # arraste as 10 imagens (0-9) no Inspector, na ordem certa

var current_digit: int = 0

func _ready() -> void:
	update_texture()
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	current_digit = (current_digit + 1) % 10  # vai de 0 a 9 e volta pra 0
	update_texture()

func update_texture() -> void:
	texture_normal = digit_textures[current_digit]
