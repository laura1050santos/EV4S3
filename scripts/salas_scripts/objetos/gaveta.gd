extends Area2D
@onready var gaveta_1 = $"../Gaveta1Aquario"


# Called when the node enters the scene tree for the first time.
func _ready():
	gaveta_1.visible = GlobalSingleton.gaveta_1
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
