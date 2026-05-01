extends Node

# Lista de dicionários: [{ "data": Resource, "pos": Vector2 }, ...]
var itens_no_mundo = []

# Função para registrar um item novo no mundo
func registrar_item(item_resource, posicao,nome_da_cena):
	if item_resource:
		var novo_item = {
			"data": item_resource,
			"pos": posicao,
			"cena": nome_da_cena # Guardamos em qual cena ele deve existir
		}
		itens_no_mundo.append(novo_item)
# Função para remover quando for coletado
func remover_item(item_data):
	for i in range(itens_no_mundo.size()):
		if itens_no_mundo[i].data == item_data:
			itens_no_mundo.remove_at(i)
			break
