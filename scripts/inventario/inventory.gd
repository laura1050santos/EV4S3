extends Panel


func _process(delta: float) -> void:
	#muda o cursor ao arrastar um item 
	if Input.get_current_cursor_shape()== CURSOR_FORBIDDEN:
		DisplayServer.cursor_set_shape(DisplayServer.CURSOR_ARROW)
var data_bk
#(copia de segurança do item) 

func _notification(what: int) -> void:

	if what == Node.NOTIFICATION_DRAG_BEGIN:
		data_bk = get_viewport().gui_get_drag_data()

	if what == Node.NOTIFICATION_DRAG_END:

		if not is_drag_successful():

			if data_bk is Object and is_instance_valid(data_bk):
				var icone = data_bk.get("icon")
				if icone is CanvasItem:
					icone.show()
		data_bk = null
