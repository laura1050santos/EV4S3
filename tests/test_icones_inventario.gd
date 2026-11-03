extends SceneTree
var verificacoes: int = 0
var falhas: int = 0
func _initialize() -> void:
	_run.call_deferred()
func conferir(valor: bool, descricao: String) -> void:
	verificacoes += 1
	if not valor:
		falhas += 1
		push_error(descricao)
func _run() -> void:
	await process_frame
	await process_frame
	var slots = root.get_node("Inventario/canvasLayer/inventory/GridContainer").get_children()
	for slot in slots:
		var original = slot.item
		for recurso in ["ChaveMala", "lanterna", "FitaCassete", "fotos/FotoAugusto", "roteador"]:
			slot.item = load("res://recursos/" + recurso + ".tres")
			await process_frame
			conferir(slot.icon.scale == Vector2.ONE and slot.icon.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_CENTERED, "Ícone preserva proporção: " + recurso)
			conferir(slot.get_global_rect().encloses(slot.icon.get_global_rect()), "Ícone cabe no espaço: " + recurso)
		slot.item = null
		conferir(slot.tooltip_text.is_empty() and not slot.icon.visible, "Espaço vazio não mantém nome nem imagem")
		slot.item = original
	print("ICONES_INVENTARIO: ", verificacoes, " verificações; ", falhas, " falhas.")
	quit(0 if falhas == 0 else 1)
