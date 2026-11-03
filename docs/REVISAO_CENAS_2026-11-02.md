# Revisão de enquadramento e configurações — 02/11/2026

Foram inventariadas e carregadas as 62 cenas .tscn. As 18 cenas de exploração/puzzles foram instanciadas no Godot para conferir o enquadramento, o botão de configurações e sua abertura/fechamento. Componentes de interface foram avaliados no contexto em que são usados; não receberam fundos nem engrenagens adicionais.

## Padrão aplicado

- Jogo: resolução lógica explícita 1152 × 648 e proporção preservada no redimensionamento. Artes completas de 1920 × 1080 usam centro (576, 324) e escala (0.6, 0.6).
- Alinhados fundos e camadas correspondentes das paredes, teto/câmera, chão, lixeira, buraco, gabinete, telégrafo e toca-fitas; corrigido também o enquadramento do fundo dos créditos e do roteador.
- Os controles e a área de encaixe do telégrafo acompanharam a correção de posição da arte. Objetos coletáveis e suas posições salvas não foram migrados.
- A mala aberta era desenhada com 1457 pixels de largura, ultrapassando a tela. Agora ocupa o quadro da mala com proporção preservada e recorte no limite da área, sem interceptar cliques do roteador.
- Computador: mantida a resolução virtual 1815 × 932, distinta do cenário externo. Corrigidos os limites dos Controls principais e o tamanho do subviewport no zoom do monitor. O artigo de Vigenère fica abaixo das abas, como os outros sites. O aviso sem internet também foi reduzido e centralizado para permanecer dentro da tela do monitor.
- A cópia antiga do desktop em fase1 agora reutiliza a cena atual, evitando uma versão que não acompanhava os novos botões do menu.

## Botões de configurações

Faltavam nestas seis cenas jogáveis; foram acrescentados usando o componente existente:

- res://scenes/fase1/zoom_pc.tscn
- res://scenes/fase1/zoom_monitor.tscn
- res://scenes/fase1/zoom_tele.tscn
- res://scenes/fase2/zoomMala.tscn
- res://scenes/fase2/zoom_tocafitas.tscn
- res://scenes/fase2/puzzleRoteador.tscn

Os botões das 18 cenas agora ficam em (16, 16), com o mesmo tamanho herdado e acima da arte. Os dois zooms do buraco tinham configurações como filho de uma seta deslocada; passaram a usar um botão independente no local padrão. A lixeira também tinha deslocamento próprio, corrigido.

Os menus de seleção de fases e créditos continuam sem uma engrenagem própria: têm retorno ao menu principal. As telas internas do PC usam o botão do cenário do monitor; componentes, autoloads e a janela de configurações não precisam duplicá-lo.

## Inventário completo

| Cena | Uso | Configurações antes | Situação atual |
|---|---|---|---|
| `scenes/Computador_Telas/arquivo_secreto.tscn` | Interface / componente do PC | Não | Usa configurações do monitor |
| `scenes/Computador_Telas/arquivo_zip.tscn` | Interface / componente do PC | Não | Usa configurações do monitor |
| `scenes/Computador_Telas/botão_fechar.tscn` | Interface / componente do PC | Não | Usa configurações do monitor |
| `scenes/Computador_Telas/item_email.tscn` | Interface / componente do PC | Não | Usa configurações do monitor |
| `scenes/Computador_Telas/janela_arquivo.tscn` | Interface / componente do PC | Não | Usa configurações do monitor |
| `scenes/Computador_Telas/mensageiro.tscn` | Interface / componente do PC | Não | Usa configurações do monitor |
| `scenes/Computador_Telas/node_2d.tscn` | Cena auxiliar / legado | Não | Sem botão próprio; não é uma sala navegável |
| `scenes/Computador_Telas/pagina_artigo.tscn` | Interface / componente do PC | Não | Usa configurações do monitor |
| `scenes/Computador_Telas/pasta_pessoal.tscn` | Interface / componente do PC | Não | Usa configurações do monitor |
| `scenes/Computador_Telas/pasta_recuperados.tscn` | Interface / componente do PC | Não | Usa configurações do monitor |
| `scenes/Computador_Telas/pasta_tecnico.tscn` | Interface / componente do PC | Não | Usa configurações do monitor |
| `scenes/Computador_Telas/recuperador.tscn` | Interface / componente do PC | Não | Usa configurações do monitor |
| `scenes/Computador_Telas/registro_recuperado.tscn` | Interface / componente do PC | Não | Usa configurações do monitor |
| `scenes/Computador_Telas/tela_boot.tscn` | Interface / componente do PC | Não | Usa configurações do monitor |
| `scenes/Computador_Telas/tela_email.tscn` | Interface / componente do PC | Não | Usa configurações do monitor |
| `scenes/Computador_Telas/tela_inicial.tscn` | Interface / componente do PC | Não | Usa configurações do monitor |
| `scenes/Computador_Telas/tela_navegador.tscn` | Interface / componente do PC | Não | Usa configurações do monitor |
| `scenes/Computador_Telas/tela_pastas.tscn` | Interface / componente do PC | Não | Usa configurações do monitor |
| `scenes/Computador_Telas/tela_senha.tscn` | Interface / componente do PC | Não | Usa configurações do monitor |
| `scenes/Computador_Telas/visualizador_arquivo.tscn` | Interface / componente do PC | Não | Usa configurações do monitor |
| `scenes/audio/AudioManager.tscn` | Componente / serviço | Não | Não se aplica |
| `scenes/escuro.tscn` | Componente / serviço | Não | Não se aplica |
| `scenes/fase1/ParedeLeste.tscn` | Exploração / puzzle | Sim | Presente, padronizado e testado |
| `scenes/fase1/ParedeNorte.tscn` | Exploração / puzzle | Sim | Presente, padronizado e testado |
| `scenes/fase1/ParedeOeste.tscn` | Exploração / puzzle | Sim | Presente, padronizado e testado |
| `scenes/fase1/ParedeSul.tscn` | Exploração / puzzle | Sim | Presente, padronizado e testado |
| `scenes/fase1/buraco_abertoZoom.tscn` | Exploração / puzzle | Sim | Presente, padronizado e testado |
| `scenes/fase1/carta_relogio.tscn` | Cena auxiliar / legado | Não | Sem botão próprio; não é uma sala navegável |
| `scenes/fase1/cena_chao.tscn` | Exploração / puzzle | Sim | Presente, padronizado e testado |
| `scenes/fase1/cena_teto.tscn` | Exploração / puzzle | Sim | Presente, padronizado e testado |
| `scenes/fase1/lixeiraZoom.tscn` | Exploração / puzzle | Sim | Presente, padronizado e testado |
| `scenes/fase1/pc_control.tscn` | Cena auxiliar / legado | Não | Sem botão próprio; não é uma sala navegável |
| `scenes/fase1/sub_viewport_container.tscn` | Interface / componente do PC | Não | Usa configurações do monitor |
| `scenes/fase1/tela_inicial.tscn` | Cena auxiliar / legado | Não | Sem botão próprio; não é uma sala navegável |
| `scenes/fase1/zoom_buraco.tscn` | Exploração / puzzle | Sim | Presente, padronizado e testado |
| `scenes/fase1/zoom_monitor.tscn` | Exploração / puzzle | Não | Presente, padronizado e testado |
| `scenes/fase1/zoom_pc.tscn` | Exploração / puzzle | Não | Presente, padronizado e testado |
| `scenes/fase1/zoom_tele.tscn` | Exploração / puzzle | Não | Presente, padronizado e testado |
| `scenes/fase2/puzzleRoteador.tscn` | Exploração / puzzle | Não | Presente, padronizado e testado |
| `scenes/fase2/zoomMala.tscn` | Exploração / puzzle | Não | Presente, padronizado e testado |
| `scenes/fase2/zoom_postIt.tscn` | Exploração / puzzle | Sim | Presente, padronizado e testado |
| `scenes/fase2/zoom_tocafitas.tscn` | Exploração / puzzle | Não | Presente, padronizado e testado |
| `scenes/fase3/calendario_fisico.tscn` | Componente / serviço | Não | Não se aplica |
| `scenes/fase3/zoom_cuco.tscn` | Exploração / puzzle | Sim | Presente, padronizado e testado |
| `scenes/fase3/zoom_quadro.tscn` | Exploração / puzzle | Sim | Presente, padronizado e testado |
| `scenes/inscricao_violeta.tscn` | Componente / serviço | Não | Não se aplica |
| `scenes/inventario/inspecao_item.tscn` | Componente / serviço | Não | Não se aplica |
| `scenes/inventario/inventario.tscn` | Componente / serviço | Não | Não se aplica |
| `scenes/inventario/worldItem.tscn` | Componente / serviço | Não | Não se aplica |
| `scenes/luzlanterna.tscn` | Componente / serviço | Não | Não se aplica |
| `scenes/salas_manager.tscn` | Componente / serviço | Não | Não se aplica |
| `scenes/setas/SetaDireita.tscn` | Componente / serviço | Não | Não se aplica |
| `scenes/setas/SetaEsquerda.tscn` | Componente / serviço | Não | Não se aplica |
| `scenes/setas/botaoConfig.tscn` | Componente / serviço | Não | Não se aplica |
| `scenes/setas/setaBaixo.tscn` | Componente / serviço | Não | Não se aplica |
| `scenes/setas/setaCima.tscn` | Componente / serviço | Não | Não se aplica |
| `scenes/telaInicial/configuracao.tscn` | Componente / serviço | Não | Não se aplica |
| `scenes/telaInicial/creditos.tscn` | Menu | Não | Sem botão próprio; retorno ao menu principal |
| `scenes/telaInicial/selecao_fases.tscn` | Menu | Não | Sem botão próprio; retorno ao menu principal |
| `scenes/telaInicial/start.tscn` | Menu principal | Sim | Presente |
| `scenes/transicao_fase.tscn` | Componente / serviço | Não | Não se aplica |
| `scenes/world_environment.tscn` | Componente / serviço | Não | Não se aplica |

## Verificação

428 verificações passaram em 9 testes: enquadramento/configurações (164, incluindo 62 cargas e as 18 salas), setas (19), navegador (17), e-mails (47), recuperação/Messenger (46), guias do PC (29), quadro/fotos (50), cuco (33) e SD (23).

Os testes que alteram estado usam SQLite em transação e rollback. O teste de enquadramento inclui os estados fechado e aberto da mala e confirma que o progresso salvo permanece igual. A validação mede limites, escalas e funcionamento; não substitui a avaliação artística das imagens pelo autor.
