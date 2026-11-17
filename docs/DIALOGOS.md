# Interação e diálogos (issue #7)

## Controles e comportamento

Ao entrar no alcance de um ponto interativo, o mais próximo recebe um anel
branco e o HUD apresenta seu nome e a tecla **E**. A indicação combina forma
e texto, sem depender apenas da cor. A verificação usa o alcance físico da
Area2D e a camada do jogador; interações fora do alcance são recusadas.

Pressionar E abre a primeira página do diálogo. A interface apresenta título,
texto completo, contador de páginas e botões com foco de teclado:

- **E** ou **Próximo**: avança uma página; na última, **Concluir** encerra a leitura.
- **Esc** ou **Fechar**: encerra a qualquer momento.
- **Tab**, **Enter/Espaço**: escolhe e ativa os botões da interface.
- **Ouvir de novo**: repete a narração da página, quando disponível.

O texto aparece inteiro, sem exigir leitura rápida ou temporizadores. Ao
fechar, interagir novamente começa pela primeira página. Durante a leitura,
o movimento, outras interações e o botão de voltar ao menu ficam suspensos.
Fechar restaura esses controles. Ler, avançar ou concluir um diálogo não
conclui missões e não modifica os bloqueios do mapa.

## Conteúdo editável e áudio opcional

`scripts/instruction_page.gd` é um Resource com `text` (multilinha) e `audio`
(AudioStream opcional). Os arquivos `dialogues/*.tres` contêm três páginas
curtas para a clareira, Tobi, Flora e a caverna. Eles estão associados ao campo
`dialogue_pages` dos pontos em `scenes/forest.tscn`.

Para editar, abra o `.tres` no Inspector e altere Text. Para acrescentar uma
página, duplique um desses recursos, edite-o e adicione-o à lista do ponto.
Para incluir narração, importe uma gravação e atribua o AudioStream ao campo
Audio. O texto deve continuar disponível mesmo que haja áudio.

Os recursos atuais não incluem gravações. Por isso, **Ouvir de novo** fica
desativado. Com AudioStream atribuído, a página tenta reproduzi-lo ao abrir,
e o botão permite repetir. Ao avançar ou fechar, o áudio anterior é interrompido.
Na web, a leitura é aberta por gesto do usuário; se o navegador bloquear o
áudio, o botão permite tentar novamente sem impedir a leitura.

## Integração

`world.gd` escolhe o ponto próximo e emite `dialogue_requested(title, pages)`.
Para pontos sem páginas cadastradas, cria uma página usando `instruction`.
Pontos de missões concluídas recebem uma mensagem de conclusão; a caverna
preserva a orientação sobre seus pré-requisitos quando necessário.

`game.gd` conecta esse sinal a `HUD/Dialogue.show_dialogue(title, pages)` e usa
`opened`/`closed` para suspender/restaurar controles. O controlador recusa
abertura sobreposta e conteúdo vazio. `page_changed(index)` permite futuras
integrações por página. `interaction_requested(point_id)` continua disponível
para conectar futuros controladores de missão.

## Validação

```sh
godot --headless --path game --editor --import --quit
godot --headless --path game --script res://tests/dialogue_test.gd
godot --headless --path game --script res://tests/forest_test.gd
godot --headless --path game --script res://tests/movement_test.gd
godot --headless --path game --script res://tests/navigation_test.gd
```

O teste de diálogo exercita o evento real de teclado E, avanço sem pular a
primeira página, Esc, botões, repetição, indicador de proximidade, movimento
suspenso, restauração dos controles, conteúdo vazio e áudio opcional.
O teste usa um AudioStreamWAV sintético para verificar reprodução, repetição
e interrupção; ele não valida qualidade de narração.

Na implementação da issue #7 passaram os quatro testes no Godot 4.7.2 e a
exportação release Web. No Chromium 159 via Playwright foram conferidos E,
Enter, Esc, releitura e abertura do diálogo de Tobi após caminhar, além da
apresentação em 1280×720 e 640×360, sem erros no console. A reprodução de
áudio foi validada no teste do controlador; não há narração gravada no jogo.

A feature parte das anteriores, ainda pendentes em `develop` no início da
implementação. Integre-as antes desta.
