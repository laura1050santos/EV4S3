extends "res://scripts/salas_scripts/salas_manager.gd"
const ID_SALA := "sul"
@export var posicao_fio_gaveta := Vector2(735, 403)
@export var rotacao_fio_gaveta: float = -32.0
@export var posicao_papel_gaveta := Vector2(728, 454)
@export var rotacao_papel_gaveta: float = 12.0

var gavetas_controller: GavetasController
var node = preload("res://scenes/inventario/worldItem.tscn")

@onready var lanterna: Node = get_tree().root.get_node_or_null("lanterna")
@onready var processador

@onready var gavetas_sprites := {
	"1": $Gaveta1Aquario,
	"2": $Gaveta2Aquario,
	"3": $Gaveta3Aquario
}

@onready var gavetas_areas := {
	"1": $Area2D,
	"2": $Area2D2,
	"3": $Area2D3
}

@onready var som_gaveta_abrindo = $abrindoGaveta
@onready var som_gaveta_fechando = $fechandoGaveta

func _ready() -> void:
	var cena = Cenarios.get_cena("sul")
	if cena:
		$cena.texture = load(cena["sprite"])

	var config_menu = get_node("BotaoConfig/configuracao")
	config_menu.volMax.connect(ativar_enigma_som)

	GlobalSingleton.ultima_cena = get_tree().current_scene.scene_file_path
	GlobalSingleton.registrar_cena_atual(get_tree().current_scene.scene_file_path)

	#Objetos
	var nome_desta_cena = self.name
	Objetos.garantir_padrao(nome_desta_cena)
	var objetos = Objetos.get_objetos_cena(nome_desta_cena)
	iniciar_itens_cena(nome_desta_cena, objetos)

	#Objetos nas gavetas -------
	gavetas_controller = GavetasController.new()
	add_child(gavetas_controller)
	gavetas_controller.configurar(ID_SALA, gavetas_sprites, gavetas_areas)
	gavetas_controller.gaveta_alterada.connect(_on_gaveta_alterada)

	for id in GlobalSingleton.gavetas[ID_SALA].keys():
		if GlobalSingleton.gavetas[ID_SALA][id]:
			_mostrar_itens_gaveta(id)
	#------------------------------

	processador = get_tree().root.get_node_or_null("Sul/processador")

	var aquario = Enigmas.get_nome("aquario")
	if aquario != null and aquario["resolvido"] == 0:
		if processador != null:
			processador.visible = false
			var area = processador.get_node_or_null("Area2D/CollisionShape2D")
			if area != null:
				area.disabled = true


# Gavetas-----------------
func spawnar_itens(item_ou_caminho, posicao):
	var visual = super.spawnar_itens(item_ou_caminho, posicao)
	if visual != null and visual.has_meta("item_data"):
		var item: itemData = visual.get_meta("item_data")
		if item.resource_path == "res://recursos/FioDecodificador.tres":
			visual.scale = Vector2(0.35, 0.35)
			visual.z_index = 4
			var forma := RectangleShape2D.new()
			forma.size = Vector2(330, 80)
			visual.get_node("Area2D/CollisionShape2D").shape = forma
	return visual


func _on_gaveta_alterada(id: String, aberta: bool) -> void:
	if aberta:
		_mostrar_itens_gaveta(id)
		som_gaveta_abrindo.play()
	else:
		_esconder_itens_gaveta(id)
		som_gaveta_fechando.play()
func _container_id(id: String) -> String:
	return ID_SALA + "_gvt_" + id

func _mostrar_itens_gaveta(id: String) -> void:
	var objetos = Objetos.get_objetos_container(self.name, _container_id(id))
	for info in objetos:
		var visual = spawnar_itens(info["item"], info["pos"])
		if visual == null:
			continue
		var item: itemData = info["item"]
		match item.resource_path:
			"res://recursos/FioDecodificador.tres":
				visual.position = posicao_fio_gaveta
				visual.rotation_degrees = rotacao_fio_gaveta
				visual.z_index = $Gaveta1Aquario.z_index - 1
			"res://recursos/PapelMorseAlcapao.tres":
				# Recorta apenas para a gaveta: o recurso original continua intacto.
				var textura := AtlasTexture.new()
				textura.atlas = item.icon
				textura.region = Rect2(466, 453, 100, 56)
				visual.texture = textura
				visual.position = posicao_papel_gaveta
				visual.rotation_degrees = rotacao_papel_gaveta
				visual.z_index = $Gaveta2Aquario.z_index - 1
				var forma := RectangleShape2D.new()
				forma.size = Vector2(100, 56)
				visual.get_node("Area2D/CollisionShape2D").shape = forma

func _esconder_itens_gaveta(id: String) -> void:
	var objetos = Objetos.get_objetos_container(self.name, _container_id(id))
	for info in objetos:
		var node = get_node_or_null(NodePath(info["item"].item_name))
		if node != null:
			node.queue_free()

# ----------------------------------

func ativar_enigma_som() -> void:
	var aquario = Enigmas.get_nome("aquario")
	if aquario == null:
		return
	if aquario["resolvido"] == 0:
		Enigmas.atualizar_enigma("aquario", 1)
		$SomVidroQuebrando.play()
		Cenarios.atualizar_cenario("sul", "res://assets/cenarios/aquarioquebrado(1).png")
		$cena.texture = preload("res://assets/cenarios/aquarioquebrado(1).png")


func _input(_event: InputEvent) -> void:
	if lanterna:
		$cena.texture = preload("res://assets/cenarios/salaaquarioseta.png")
		var colisao_buraco = get_node_or_null("buraco/colisaoBuraco")
		if colisao_buraco != null:
			colisao_buraco.disabled = false

	var aquario = Enigmas.get_nome("aquario")
	if aquario == null:
		return
	if aquario["resolvido"] == 1:
		$cena.texture = preload("res://assets/cenarios/aquarioquebrado(1).png")


func _on_area_cabeca_quebrada_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
		return
	if processador == null:
		return
	if processador.visible:
		return

	processador.visible = true

	var area = processador.get_node_or_null("Area2D/CollisionShape2D")
	if area != null:
		area.disabled = false
	
