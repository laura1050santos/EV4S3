extends Panel


func _process(delta: float) -> void:
	#muda o cursor ao arrastar um item 
	if Input.get_current_cursor_shape()== CURSOR_FORBIDDEN:
		DisplayServer.cursor_set_shape(DisplayServer.CURSOR_ARROW)
var data_bk
#(copia de segurança do item) 

func _notification(what: int) -> void:
	#avisa o sistema sobre o item estar sendo arrastado 
	
	if what == Node.NOTIFICATION_DRAG_BEGIN:
		data_bk = get_viewport().gui_get_drag_data()	
		#get_viewport - acessa a interface ativa do jogo
		# gui_get_drag_data - retorna o que está sendo arrastado
	if what == Node.NOTIFICATION_DRAG_END:
		#mostra o item caso a função principal falhe
		if not is_drag_successful():
			if data_bk:
				data_bk.icon.show()
				data_bk = null
