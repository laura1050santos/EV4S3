extends SalasManager

const Slot = preload("res://scripts/quadro_foto_slot.gd")
const Tinta = preload("res://scenes/inscricao_violeta.tscn")
@export var tamanho_foto: Vector2 = Vector2(116, 138)
@export var espaco_entre_fotos: float = 20.0
var fotos: Array[itemData] = [null, null, null, null]
var espacos: Array[Panel] = []

func _ready() -> void:
	GlobalSingleton.registrar_cena_atual(scene_file_path)
	iniciar_itens_cena(name, Objetos.get_objetos_cena(name))
	for indice in range(4):
		var caminho: String = Objetos.get_recurso_em_estacao("quadro_foto_" + str(indice))
		if not caminho.is_empty() and ResourceLoader.exists(caminho):
			var foto = load(caminho)
			if aceita_foto(foto):
				fotos[indice] = foto
		var espaco := Panel.new()
		espaco.set_script(Slot)
		espaco.quadro = self
		espaco.indice = indice
		espaco.position = Vector2(indice * (tamanho_foto.x + espaco_entre_fotos), 0)
		espaco.size = tamanho_foto
		var estilo := StyleBoxFlat.new()
		estilo.bg_color = Color(0.96, 0.91, 0.8, 0.06)
		estilo.border_color = Color(0.96, 0.91, 0.8, 0.25)
		estilo.set_border_width_all(1)
		espaco.add_theme_stylebox_override("panel", estilo)
		$Conteudo/AreaFotos.add_child(espaco)
		espacos.append(espaco)
		var imagem := TextureRect.new()
		imagem.name = "Imagem"
		imagem.position = Vector2(5, 5)
		imagem.size = tamanho_foto - Vector2(10, 10)
		imagem.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		imagem.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		imagem.mouse_filter = Control.MOUSE_FILTER_IGNORE
		espaco.add_child(imagem)
		var tinta = Tinta.instantiate()
		tinta.name = "Tinta"
		tinta.texto = ""
		tinta.position = imagem.position
		espaco.add_child(tinta)
		var letra: Label = tinta.get_node("Texto")
		letra.size = imagem.size
		letra.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		letra.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		letra.add_theme_font_size_override("font_size", 64)
	_atualizar()
	Progresso.salvar("calendario_examinado", true)

func aceita_foto(item: itemData) -> bool:
	if item == null:
		return false
	for info in Objetos.FOTOS_FAMILIA.values():
		if info.recurso == item.resource_path:
			return true
	return false

func fixar_foto(origem: Control, indice: int) -> bool:
	var foto: itemData = origem.get("item")
	if indice < 0 or indice >= 4 or not aceita_foto(foto) or fotos.has(foto):
		return false
	var anterior: itemData = fotos[indice]
	fotos[indice] = foto
	origem.item = anterior
	origem.update_ui()
	if anterior != null:
		Objetos.marcar_coletado_por_recurso(anterior.resource_path)
	_salvar()
	return true

func trocar_fotos(origem: int, destino: int) -> void:
	if origem < 0 or origem >= 4 or destino < 0 or destino >= 4:
		return
	var anterior: itemData = fotos[destino]
	fotos[destino] = fotos[origem]
	fotos[origem] = anterior
	_salvar()

func retirar_foto(indice: int, destino: Control = null) -> bool:
	if indice < 0 or indice >= 4 or fotos[indice] == null:
		return false
	var foto: itemData = fotos[indice]
	if destino != null:
		if destino.item != null:
			return false
		destino.item = foto
		destino.update_ui()
	else:
		var inventario = get_tree().get_first_node_in_group("world_drop_area")
		if inventario == null or not inventario.guardar_no_inventario(foto):
			return false
	Objetos.marcar_coletado_por_recurso(foto.resource_path)
	fotos[indice] = null
	_salvar()
	return true

func _salvar() -> void:
	for indice in range(4):
		if fotos[indice] != null:
			Objetos.guardar_em_estacao(fotos[indice].resource_path, "quadro_foto_" + str(indice))
	_atualizar()

func _atualizar() -> void:
	for indice in range(4):
		var foto: itemData = fotos[indice]
		var espaco: Panel = espacos[indice]
		espaco.get_node("Imagem").texture = foto.icon if foto != null else null
		espaco.get_node("Tinta/Texto").text = foto.letra_violeta if foto != null else ""
