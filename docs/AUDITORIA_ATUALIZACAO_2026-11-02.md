# Auditoria da atualização — 02/11/2026

## Origem da diferença

- HEAD recebido: `015b467` (novos áudios e ajustes de cenas).
- O reflog registra reset e pulls por fast-forward. Isso, sozinho, não prova que o último commit apagou os arquivos locais.
- O GitHub Desktop guardou as alterações anteriores em `stash@{0}`, objeto `4ab809ece71f678bc8ebe6164726562f28be64bd`, com base em `339ffbc`. Ele inclui os arquivos novos e o banco anterior. O stash foi mantido intacto, sem apply/pop global.
- O diretório de trabalho estava sem Messenger, recuperador, registro recuperado, cartão SD, zoom do cuco e testes recentes; os e-mails e seu visualizador tinham voltado aos quatro recursos antigos.

## Recuperação e integração realizadas

| Área | Diferença encontrada | Resultado |
|---|---|---|
| E-mails | Quatro recursos antigos, imagens antigas, sem zoom/rolagem e escolha no centro | Seis imagens novas 01 a 06, assuntos correspondentes, rolagem/zoom, área até a parte inferior e escolha à esquerda |
| Messenger | Ausente no computador e no menu Iniciar | Restaurado com histórico, minimização, persistência e gatilho ao fechar registro lido |
| ZIP/recuperação | ZIP apenas com imagem antiga; programa ausente | Foto do cuco e recuperador restaurados; exige BACKUP-03 inserido no PC |
| Cuco | Clique apenas tocava som | Zoom e ajuste dos ponteiros restaurados; compartimento ao meio-dia, SD e mudança visual da sala |
| Gabinete | Sem leitor SD; acesso bloqueado após fase 1 | Leitor e acesso posterior restaurados; mantidos os IDs e ajustes recebidos da cena |
| Pesquisa | Último commit removeu os termos de busca dos quatro recursos de sites | Termos restaurados sem substituir conteúdo, estilos ou UIDs recebidos |
| Lixeira | Marcadores de conflito já presentes no HEAD impediam carregar a cena | Conflito resolvido mantendo listener e caminho usados pelo script novo |
| Vigenère | Recurso com CRLF falhava na validação SHA-256 | Normalização de quebras Windows/Linux; cifra, senha e conteúdo preservados |
| Áudio | Novos sons, AudioManager e listeners | Preservados; recuperação do alerta de phishing chama play e mantém áudio sem atenuação no subviewport |

As imagens novas mantêm os nomes e o conteúdo fornecidos. `01_fatura_mensal` e `02_senha_alterada` ainda têm assunto e corpo cruzados; o título da lista segue o assunto visível da imagem. Os dois são classificados como legítimos, conforme aprovação anterior. Os demais quatro são phishing.

As imagens novas já têm texto maior e margens adequadas: não utilizam o recorte AtlasTexture anterior. Abrem ajustadas à largura, com rolagem vertical e opção de ampliar. A ordem e a classificação dos quatro índices antigos foram preservadas para compatibilidade com o save.

Foram excluídos os três JPGs antigos de e-mail e seus arquivos .import. As seis versões intermediárias legitimo/phishing não foram trazidas do stash. `foto.png` permanece porque também é utilizado nos arquivos pessoais e como ícone do ZIP.

## Banco e limites

- Banco atual mantido em `res://data.db`; não foi substituído pelo banco do stash.
- Estado encontrado no banco atual: Fase 1, nenhuma fase concluída, última cena `res://scenes/telaInicial/start.tscn`.
- Estado no banco preservado do stash: Fase 3, fases 1 e 2 concluídas, última cena `res://scenes/fase1/zoom_monitor.tscn`.
- Não foi conectada a conclusão do Messenger à Fase 4 e não foi criado o PIN: essas eram etapas futuras, não funcionalidades perdidas.
- Recurso legado `recursos/RelogioCuco.tres` aponta para duas imagens ausentes, mas não é referenciado pelos scripts/cenas/recursos atuais. O puzzle usa `zoom_cuco.tscn`; o legado foi apenas registrado.
- A inicialização do banco ainda imprime os avisos antigos de UNIQUE em Arrays/Cenarios; não pertencem à integração atual.

## Validação

330 verificações, sem falhas nas execuções finais:

| Sistema | Verificações |
|---|---:|
| E-mails | 47 |
| Recuperação e Messenger | 46 |
| Cuco | 33 |
| SD no gabinete | 23 |
| ZIP | 17 |
| Documento secreto | 18 |
| Efeitos de áudio | 12 |
| Vigenère | 42 |
| Quadro/fotos | 50 |
| Guias do gabinete | 29 |
| Pesquisa no navegador | 13 |

Os testes de estado usam transações SQLite e rollback. Nenhum commit foi criado, nenhum stash foi removido e nenhum push foi realizado.
