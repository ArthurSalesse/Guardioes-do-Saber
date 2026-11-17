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
- `scenes/game.tscn`: tela provisória e nó `World` (Node2D) para o futuro jogo.

As telas emitem `navigate` com uma rota (`menu` ou `game`). O controlador
substitui a tela ativa de forma adiada, libera a anterior e ignora rotas
inválidas ou repetidas. Cada tela define o foco inicial do seu botão.
Não há gameplay implementado nesta etapa.

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
2. Verificar a tela provisória e acionar Voltar ao menu.
3. Repetir usando Tab e Enter/Espaço.
4. Redimensionar em 1280×720, 640×360 e uma proporção diferente de 16:9;
   verificar centralização, barras e botões acessíveis.
5. Verificar o console do navegador e as respostas HTTP dos arquivos exportados.

Referências: [resoluções](https://docs.godotengine.org/en/stable/tutorials/rendering/multiple_resolutions.html)
e [exportação web](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html).
