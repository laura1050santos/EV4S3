extends Area2D
@onready var meu_sprite = $"../Gaveta1Aquario"

# Called when the node enters the scene tree for the first time.
func _ready():
	meu_sprite.visible = GlobalSingleton.sprite_visivel
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
