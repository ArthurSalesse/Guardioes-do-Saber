# Projeto Godot 2D

## Ambiente e resolução

Versão de referência: Godot 4.7.2 Standard e templates da mesma versão.
O renderizador Compatibility permite exportar para WebGL 2.0.

A resolução-base é 1280×720, com janela redimensionável e mínimo de 640×360.
O modo `canvas_items` mantém a interface renderizada na resolução da janela;
o aspecto `keep` preserva 16:9 e acrescenta barras quando necessário.
Containers e âncoras centralizam as telas. O canvas web acompanha a janela
do navegador, mantendo essa política de proporção.

## Cenas e navegação

- `scenes/main.tscn`: ponto de entrada com o controlador `scripts/navigation.gd`.
- `scenes/menu.tscn`: título e botão Iniciar.
- `scenes/game.tscn`: área de exploração com `World`, personagem e HUD.
- `scenes/forest.tscn`: mapa com TileMapLayer, progresso e pontos de interação.
- `scenes/player.tscn`: personagem reutilizável com CharacterBody2D e Camera2D.

As telas emitem `navigate` com uma rota (`menu` ou `game`). O controlador
substitui a tela ativa de forma adiada, libera a anterior e ignora rotas
inválidas ou repetidas. O menu define o foco inicial em Iniciar; no jogo, Tab
permite selecionar Voltar ao menu. Ainda não há missões implementadas.

## Movimentação e cenário (issue #5)

As ações `move_left`, `move_right`, `move_up` e `move_down` estão no Input Map
com teclas físicas WASD e setas. A velocidade é de 240 unidades por segundo,
independente da taxa de quadros, usando `_physics_process` e `move_and_slide`.
O movimento é cardinal: quando duas direções perpendiculares são pressionadas,
o maior eixo prevalece e empates priorizam o horizontal. Não há diagonal nem
aumento de velocidade. Teclas opostas no mesmo eixo se anulam.

O personagem usa modo de movimento flutuante e colisor circular nos pés.
A camada 1 contém cenário; a camada 2 contém o jogador. Desde a issue #6,
o mapa usa tiles de 32 unidades, bordas sólidas, bosques, rio e barreiras de
progresso. Consulte [mapa e progresso](MAPA.md) para layout e integração.

A câmera acompanha o jogador, limitada a (0, 0)–(1920, 1080), sem mostrar o
exterior do cenário na resolução-base. O HUD fica em CanvasLayer, fixo na tela.
O personagem é desenhado em código, com braços e pernas alternados enquanto
se move, pose ociosa ao parar e orientação visual conforme a direção.
A caminhada para também quando o personagem está bloqueado por uma parede.
Esses gráficos são provisórios e não exigem assets externos.

O teste `tests/movement_test.gd` exercita movimento nos quatro sentidos,
parada, animação, ausência de diagonal/ganho de velocidade, colisão com
obstáculo e bordas e limites da câmera. Execute com:

```sh
godot --headless --path game --script res://tests/movement_test.gd
```

A feature #5 parte das anteriores, ainda não integradas em `develop` ao
iniciar esta implementação. Integre as features anteriores antes desta.

Na issue #5 passaram a importação no Godot 4.7.2, os testes de navegação e
movimentação e a exportação release Web. No Chromium 159 via Playwright,
foram conferidos WASD, setas, colisão, acompanhamento da câmera, apresentação
em 1280×720 e 640×360 e retorno ao menu após redimensionar, sem erros no
console. Os arquivos de `build/` são excluídos da exportação para evitar
incluir artefatos gerados no próprio pacote.

## Exportação Web

O preset `Web` em `game/export_presets.cfg` é versionado e não contém segredos.
Exporta para `game/build/web/index.html`, com threads e extensões desativadas.
Não exige cabeçalhos de isolamento COOP/COEP. Os arquivos gerados e caches
são ignorados pelo Git; os testes também são excluídos do pacote exportado.

Os comandos de importação, teste, exportação e servidor local estão no
[README](../README.md). Em hospedagem, publique todos os arquivos gerados
juntos e sirva `.wasm` como `application/wasm`. Use HTTPS fora de localhost.

## Validação

Na implementação da issue #2, foram executados com sucesso no Godot 4.7.2:
importação headless, teste de navegação, inicialização da cena principal e
exportação release Web. A exportação foi servida por HTTP local e aberta no
Chromium 159 via Playwright com renderização por software. Foram conferidos
carregamento sem erros de console/HTTP, Iniciar por clique, retorno por Enter
e capturas em 1280×720, 640×360 e 900×900 (com barras). Isso não substitui
testes futuros em dispositivos móveis e outros navegadores.

A branch `feature/2-projeto-godot` inclui a estrutura da issue #1, ainda
pendente de integração quando esta implementação foi iniciada. Integre a
issue #1 em `develop` antes de integrar a issue #2.

O teste `tests/navigation_test.gd` verifica a abertura do menu, os sinais dos
botões, três ciclos de ida e volta, ausência de telas duplicadas e rotas
inválidas. O processo retorna código diferente de zero em caso de falha.

Checklist manual após servir a exportação:

1. Verificar o título e acionar Iniciar.
2. Mover o guardião com WASD e setas, testar obstáculos e bordas e observar
   caminhada, parada e acompanhamento da câmera. Acionar Voltar ao menu.
3. Repetir usando Tab e Enter/Espaço.
4. Redimensionar em 1280×720, 640×360 e uma proporção diferente de 16:9;
   verificar centralização, barras e botões acessíveis.
5. Verificar o console do navegador e as respostas HTTP dos arquivos exportados.

Referências: [resoluções](https://docs.godotengine.org/en/stable/tutorials/rendering/multiple_resolutions.html)
e [exportação web](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html).
