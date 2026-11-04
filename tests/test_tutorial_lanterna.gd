extends SceneTree
var falhas: int = 0
var verificacoes: int = 0
func _initialize() -> void:
    _run.call_deferred()
func conferir(condicao: bool, descricao: String) -> void:
    verificacoes += 1
    if not condicao:
        falhas += 1
        push_error(descricao)
func _run() -> void:
    await process_frame
    await process_frame
    var banco = root.get_node("Database").db
    var progresso = load("res://BDD/Progresso.gd")
    banco.query("SELECT * FROM Progresso ORDER BY chave;")
    var antes = banco.get_query_result().duplicate(true)
    banco.query("BEGIN TRANSACTION;")
    progresso.salvar("tutorial_lanterna_etapa", 0)
    progresso.salvar("tutorial_lanterna_coletada", false)
    progresso.salvar("tutorial_lanterna_utilizada", false)
    progresso.salvar("tutorial_lanterna_modo_aprendido", false)
    var tutorial = root.get_node("GlobalSingleton/TutorialLanterna")
    tutorial.restaurar()
    var cena = Node2D.new()
    cena.scene_file_path = "res://scenes/fase1/ParedeNorte.tscn"
    root.add_child(cena)
    current_scene = cena
    await process_frame
    conferir(not tutorial.visible, "Dica oculta antes do tutorial")
    tutorial.iniciar()
    await create_timer(0.7).timeout
    conferir(tutorial.etapa == 1 and tutorial.visible and not tutorial.texto.text.contains("botão esquerdo"), "Fora do local da lanterna aparece apenas a dica de procurar")
    conferir(tutorial.texto.anchor_top == 0 and tutorial.texto.offset_top == 24, "Dicas posicionadas na parte superior")
    var lanterna = load("res://recursos/lanterna.tres")
    var visual_lanterna = Sprite2D.new()
    visual_lanterna.set_meta("item_data", lanterna)
    cena.add_child(visual_lanterna)
    await process_frame
    await process_frame
    await create_timer(0.7).timeout
    conferir(tutorial.texto.text.contains("botão esquerdo"), "Dica de pegar aparece no cenário onde a lanterna está")
    conferir(tutorial.seta.visible and tutorial.mouse.visible and tutorial.tipo_exibido == "pegar", "Arte de clique esquerdo e seta aparecem junto da lanterna")
    var posicao_seta = tutorial.seta.position
    await create_timer(0.12).timeout
    conferir(not tutorial.seta.position.is_equal_approx(posicao_seta), "Seta de coleta se move na direção vertical")
    visual_lanterna.hide()
    await process_frame
    await process_frame
    await create_timer(0.7).timeout
    conferir(not tutorial.texto.text.contains("botão esquerdo"), "Lanterna oculta não revela dica de coleta")
    visual_lanterna.queue_free()
    var slot = root.get_node("Inventario/canvasLayer/inventory/GridContainer").get_child(0)
    var item_anterior = slot.item
    slot.item = lanterna
    root.get_node("GlobalSingleton").remover_item(lanterna)
    await process_frame
    await process_frame
    await create_timer(0.7).timeout
    conferir(tutorial.etapa == 2 and tutorial.texto.text.contains("Arraste"), "Coleta avança para devolver ao cenário")
    conferir(tutorial.tipo_exibido == "inventario" and tutorial.seta.visible, "Seta aponta para o slot que contém a lanterna")
    var texto_anterior = tutorial.texto.text
    tutorial.registrar_devolucao()
    conferir(tutorial.texto.text == texto_anterior, "Dica anterior permanece enquanto faz fade-out")
    await create_timer(0.7).timeout
    conferir(tutorial.etapa == 3 and tutorial.texto.text.contains("botão direito"), "Devolução avança para uso ou exame")
    var estado_ativo = lanterna.item_ativo
    lanterna.item_ativo = false
    conferir(tutorial.tipo_exibido == "usar_inventario" and tutorial.mouse.visible, "Mouse direito aparece ao lado da lanterna no inventário")
    var clique = InputEventMouseButton.new()
    clique.button_index = MOUSE_BUTTON_RIGHT
    clique.pressed = true
    slot._gui_input(clique)
    conferir(lanterna.item_ativo and slot.item == lanterna and root.has_node("LuzDaLanterna"), "Botão direito acende lanterna sem retirá-la do inventário")
    conferir(tutorial.etapa == 4, "Uso no inventário libera dica exclusiva de F")
    await create_timer(0.7).timeout
    conferir(tutorial.visible and tutorial.texto.modulate.a > 0.99, "Acender lanterna exibe dica com fade-in")
    conferir(tutorial.texto.get_theme_font("font").resource_path == "res://assets/Myfont-Regular.ttf", "Fonte personalizada aplicada")
    tutorial.restaurar()
    conferir(tutorial.pendente, "Partida retomada mantém dica não aprendida")
    cena.scene_file_path = "res://scenes/telaInicial/start.tscn"
    await process_frame
    await process_frame
    conferir(not tutorial.visible, "Dica não cobre o menu")
    cena.scene_file_path = "res://scenes/fase1/ParedeNorte.tscn"
    await create_timer(0.7).timeout
    conferir(tutorial.visible, "Dica retorna ao jogo enquanto pendente")
    var luz = root.get_node("LuzDaLanterna")
    var campo = LineEdit.new()
    cena.add_child(campo)
    campo.grab_focus()
    await process_frame
    var evento = InputEventKey.new()
    evento.pressed = true
    evento.keycode = KEY_F
    luz._unhandled_key_input(evento)
    conferir(not luz.modo_violeta and tutorial.pendente, "Digitar F em campo de texto não conclui tutorial")
    campo.release_focus()
    luz._unhandled_key_input(evento)
    await create_timer(0.4).timeout
    conferir(luz.modo_violeta and not tutorial.visible, "Alternar de fato com F esconde dica em fade-out")
    conferir(bool(progresso.carregar("tutorial_lanterna_modo_aprendido", false)), "Aprendizado salvo no SQLite")
    tutorial.registrar_uso()
    await process_frame
    conferir(not tutorial.pendente and not tutorial.visible, "Usar novamente não repete tutorial aprendido")
    tutorial.restaurar()
    conferir(not tutorial.pendente, "Aprendizado restaurado ao continuar")
    progresso.resetar()
    tutorial.restaurar()
    conferir(not tutorial.visible and not tutorial.pendente, "Novo jogo limpa tutorial da partida anterior")
    tutorial.registrar_uso()
    conferir(tutorial.pendente, "Nova partida permite aprender novamente")
    slot._gui_input(clique)
    await process_frame
    conferir(not lanterna.item_ativo and not root.has_node("LuzDaLanterna"), "Botão direito também apaga lanterna no inventário")
    slot.item = item_anterior
    lanterna.item_ativo = estado_ativo
    cena.queue_free()
    await process_frame
    banco.query("ROLLBACK;")
    banco.query("SELECT * FROM Progresso ORDER BY chave;")
    conferir(antes == banco.get_query_result(), "Progresso original preservado")
    tutorial.restaurar()
    print("TUTORIAL_LANTERNA: ", verificacoes, " verificações; ", falhas, " falhas.")
    quit(0 if falhas == 0 else 1)
