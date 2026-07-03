extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_pressed() -> void:
	var conf = get_node("configuracao")
	if conf.visible == true:
		print ("node visivel")
		conf.visible = false
	elif conf.visible == false: 
		print ("node invisivel")
		conf.visible = true # Replace with function body.
