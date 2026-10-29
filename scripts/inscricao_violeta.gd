extends Node2D

@export_multiline var texto: String = "TINTA INVISÍVEL"
@onready var inscricao: Label = $Texto

func _ready() -> void:
	inscricao.text = texto
	inscricao.light_mask = 2
	var tinta := CanvasItemMaterial.new()
	tinta.light_mode = CanvasItemMaterial.LIGHT_MODE_LIGHT_ONLY
	inscricao.material = tinta
	hide()

func _process(_delta: float) -> void:
	var luz = get_tree().root.get_node_or_null("LuzDaLanterna")
	visible = luz != null and not luz.is_queued_for_deletion() and luz.enabled and luz.visible and luz.modo_violeta
