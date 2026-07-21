extends Node

const CAMINHO_SAVE = "user://save.json"


func salvar():

	var dados = {
		"ultima_cena": GlobalSingleton.ultima_cena,
		"itens_no_mundo": GlobalSingleton.itens_no_mundo,
		"cenas_visitadas": GlobalSingleton.cenas_visitadas,

		"enigma_luz_resolvido": GlobalSingleton.enigma_luz_resolvido,

		"gaveta_1": GlobalSingleton.gaveta_1,
		"gaveta_2": GlobalSingleton.gaveta_2,
		"gaveta_3": GlobalSingleton.gaveta_3,

		"lixeiraAberta": GlobalSingleton.lixeiraAberta
	}


	var arquivo = FileAccess.open(CAMINHO_SAVE, FileAccess.WRITE)
	arquivo.store_string(JSON.stringify(dados))
	arquivo.close()

	print("Jogo salvo!")
	
	
func carregar():

	if not FileAccess.file_exists(CAMINHO_SAVE):
		print("Nenhum save encontrado")
		return


	var arquivo = FileAccess.open(CAMINHO_SAVE, FileAccess.READ)
	var dados = JSON.parse_string(arquivo.get_as_text())
	arquivo.close()


	GlobalSingleton.ultima_cena = dados["ultima_cena"]
	GlobalSingleton.itens_no_mundo = dados["itens_no_mundo"]
	GlobalSingleton.cenas_visitadas = dados["cenas_visitadas"]

	GlobalSingleton.enigma_luz_resolvido = dados["enigma_luz_resolvido"]

	GlobalSingleton.gaveta_1 = dados["gaveta_1"]
	GlobalSingleton.gaveta_2 = dados["gaveta_2"]
	GlobalSingleton.gaveta_3 = dados["gaveta_3"]

	GlobalSingleton.lixeiraAberta = dados["lixeiraAberta"]


	print("Save carregado!")

	get_tree().change_scene_to_file(GlobalSingleton.ultima_cena)
