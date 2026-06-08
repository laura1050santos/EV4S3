extends Sprite2D

@onready var escuro = $"."
var lampadaConsertada = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	escuro.hide()
	#pass # Replace with function body.
	
func ligarEDesligar():
	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if lampadaConsertada:
		escuro.show()
