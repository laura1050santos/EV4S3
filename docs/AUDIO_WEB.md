# Áudio Web — correções de 03/11/2026

## Causas verificadas

- fita.mp3 forçava Playback Type Stream na cena e repetia pelo sinal finished. Sem threads, a mixagem de streams pode apresentar maior latência/engasgos no navegador.
- Os dois MP3s de ambiente estavam importados com loop=false. A propriedade parameters/looping dos players não ativava o loop do recurso AudioStreamMP3.
- O toc-toc era construído com FileAccess sobre o MP3 bruto. A exportação utiliza recursos de áudio importados/remapeados, portanto a carga foi substituída por preload.

## Mudanças

- Sample explícito na Web e players MP3 configurados antes de play; loops no recurso e nas opções de importação.
- Fita em AudioStreamPlayer sem atenuação espacial; mantém volume, delay do encaixe e cancelamento ao retirar.
- AudioManager inicia a trilha apropriada também em Continuar/fases 3 e 4, evita faixas sobrepostas, mantém a música durante o frame sem current_scene da troca de sala e tenta retomar após foco/interação se tiver parado.
- Toc-toc usa recurso importado, preservando atraso, volume e estados da porta. Não toca na seleção de fases nem depois de ver a porta com a chave; saves que já registraram o aviso não são reiniciados.

## Validação

110 verificações sem falhas: audio_web (19), audio_commit (10), efeitos_audio (12), recuperacao (50), setas (19). Os loops foram iniciados perto do fim e permaneceram em reprodução depois do encerramento do arquivo. Os testes usam APPDATA temporário dentro de .godot/audio_test_userdata, sem trocar o banco do jogador.

Exportação Web Release concluída, com Extensions Support ligado e threads desligadas, e ZIP verificado quanto à integridade e index.html na raiz. Artefato: .godot/EV4S3-web-audio.zip.

O teste do navegador não pôde ser concluído: o ambiente de execução recusou a conexão ao servidor local com EACCES. Portanto, não foi feita validação auditiva no navegador/itch.io. É necessário substituir o ZIP antigo no itch.io e conferir a fita, loops de ambiente/PC e toc-toc em uma partida em que a porta ainda não foi vista.

Referências técnicas: https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html#Audio-playback e https://docs.godotengine.org/en/stable/classes/class_audiostreammp3.html.
