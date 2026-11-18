# Floresta dos Números (issue #6)

## Estrutura

`game/scenes/forest.tscn` é instanciada como `World` na cena do jogo. O layout
determinístico é preenchido por `world.gd` em duas TileMapLayers: `Ground`
(chão, caminhos e ponte, sem colisão) e `Obstacles` (árvores, pedras, rio e
portões, com colisão). O atlas SVG original `assets/forest_tiles.svg` contém
sete tiles de 32×32. O TileSet e os polígonos de colisão são criados no início
da cena; o mapa aparece ao executar, sem depender de arquivos gerados locais.

O mapa tem 60×34 células (1920×1088 unidades). A câmera mantém os limites
1920×1080 para conservar a resolução e esconder os oito pixels inferiores
da borda sólida. O jogador começa em (288, 544), na clareira à esquerda.

| Região | Localização | Acesso |
| --- | --- | --- |
| Clareira inicial | Oeste do rio; sinal em (352, 544) | Livre no início |
| Ponte / Tobi | Rio nas colunas 20–21; travessia nas linhas 16–17; Tobi em (544, 544) | Travessia após `bridge` |
| Moinho / Flora | Região central; Flora em (1056, 416) | Após a travessia da ponte |
| Caverna | Região leste; sinal em (1632, 544) | Após `mill`, pelo portão na coluna 40, linhas 16–17 |

O rio e a barreira de pedras se estendem de borda a borda. As únicas passagens
são os dois trechos controlados pelo progresso. Os caminhos têm 64 unidades
de largura, compatíveis com o colisor do personagem. Bosques e edifícios
possuem colisões; os sinais de interação são atravessáveis.

## Interação

Cada sinal usa `scenes/interaction_point.tscn`, uma Area2D com alcance de
90 unidades, máscara da camada do jogador, título e instrução. O sinal mais
próximo em alcance é selecionado. O HUD mostra a tecla **E** e o nome do local;
pressionar E abre a janela de diálogo e emite `interaction_requested(point_id)`
e `dialogue_requested(title, pages)`. Um anel branco destaca o ponto ativo,
além do texto de ação no HUD. Fora do alcance não há interação. A leitura pode
ser repetida ao fechar o diálogo e interagir novamente com o mesmo ponto.

Os IDs são `welcome`, `bridge`, `mill` e `crystal`. O sinal permite conectar
futuras telas de missão. A issue #7 acrescenta os diálogos curtos descritos em
[Diálogos e instruções](DIALOGOS.md). Nesta etapa não há puzzles nem persistência
de progresso no backend.

## Integração de progresso

`World/Progress` delega para o autoload `MissionManager`. Expõe
`is_completed(id)`, `start_mission(id)` e `complete_mission(id)`. A interação
com o ponto de uma missão disponível inicia essa missão. Os futuros
controladores devem chamar `complete_mission` apenas após validar o desafio
de uma missão ativa:

```gdscript
# Exemplo de integração futura, após resposta validada do desafio da ponte:
var accepted: bool = $World/Progress.complete_mission(&"bridge")
```

A ordem é `bridge` → `mill` → `crystal`. IDs desconhecidos, conclusões
repetidas e conclusões sem início retornam `false`, sem emitir mudanças.
Uma missão só pode iniciar após a conclusão da anterior.
Uma conclusão aceita emite `changed` e atualiza os tiles visuais e as colisões:

- `bridge`: remove a barreira sobre a ponte e permite chegar ao moinho.
- `mill`: abre o portão na barreira de pedras e permite chegar à caverna.
- `crystal`: registra a conclusão final, sem adicionar outro bloqueio.

As atualizações de colisão do TileMapLayer são aplicadas pelo motor ao final
do frame. Desde a issue #8, o estado vive no MissionManager e sobrevive à
troca de cenas. Voltar ao menu e continuar restaura as passagens já abertas;
recomeçar explicitamente limpa os estados e fecha os bloqueios. Não há botão, tecla ou interação que conclua
automaticamente missões. Os testes chamam essa API para verificar as passagens
antes da implementação dos puzzles. Consulte [estados e eventos](MISSOES.md).

## Validação

```sh
godot --headless --path game --editor --import --quit
godot --headless --path game --script res://tests/forest_test.gd
godot --headless --path game --script res://tests/movement_test.gd
godot --headless --path game --script res://tests/navigation_test.gd
```

O teste do mapa verifica dimensões, regiões alcançáveis por busca nas células,
interação próxima/distante, ordem de missões, repetição de conclusão, colisão
real antes/depois dos desbloqueios, continuidade ao recriar o mapa e limpeza
ao recomeçar uma aventura.
Os testes de movimento e navegação continuam cobrindo o personagem e o menu.

Na implementação da issue #6 passaram os três testes no Godot 4.7.2 e a
exportação release Web. No Chromium 159 via Playwright foram conferidos o
mapa renderizado, orientações da clareira e de Tobi pela tecla E, movimento
por WASD/setas, bloqueio da ponte e apresentação em 1280×720 e 640×360, sem
erros no console. A abertura das passagens foi validada nos testes de física;
os puzzles que chamarão a API de progresso ainda serão implementados.

Esta feature parte das issues anteriores, ainda pendentes em `develop` quando
foi iniciada. Integre as features anteriores antes desta.

Referência: [TileMapLayer na documentação do Godot](https://docs.godotengine.org/en/stable/classes/class_tilemaplayer.html).
