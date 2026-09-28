extends Node2D


func iniciar_itens_cena(nome_desta_cena, itens):
	for info in itens:
		var recurso = info["item"]
		var posicao = info["pos"]
		spawnar_itens(
			recurso,
			posicao
		)
	GlobalSingleton.registrar_transicao(scene_file_path)
func spawnar_itens(item_ou_caminho, posicao):
    # Aceita tanto String (caminho) quanto Resource (objeto já carregado)
    var recurso: Resource
    if item_ou_caminho is Resource:
        recurso = item_ou_caminho
    else:
        recurso = load(item_ou_caminho)

    if not recurso:
        print("ERRO: recurso nulo")
        return

    var node = preload(
        "res://scenes/inventario/worldItem.tscn"
    ).instantiate()
	node.set_meta("item_data", recurso)

	node.name = recurso.item_name
if recurso.item_ativo:
    node.texture = recurso.ativo_icon
else:
    node.texture = recurso.icon

add_child(node)

node.global_position = posicao

ativar_item_ao_resconstruir(
    recurso,
    node
)

func ativar_item_ao_resconstruir(item, node):
	match item.item_name:

		"lanterna":
			itemData.ativar_luz(
itemData.ativar_luz(
    item,
    node,
    node.global_position
)
			)


func adicionar_item_na_sala(recurso, posicao):
GlobalSingleton.registrar_item(recurso, posicao, self.name)
# Instancia fisicamente na tela
spawnar_itens(recurso, posicao)
