# Gerenciador de missões (issue #8)

## Estados e ciclo de vida

`MissionManager` é um autoload registrado em `game/project.godot`, com estado
compartilhado pelas cenas durante a execução do jogo. As missões são
`bridge` (A Ponte Quebrada), `mill` (O Moinho Encantado) e `crystal` (O Cristal
Perdido), nessa ordem.

| Estado | Significado | Próxima transição |
| --- | --- | --- |
| `State.NOT_STARTED` | Não iniciada | `start_mission(id)` se a anterior estiver concluída |
| `State.ACTIVE` | Ativa | `complete_mission(id)` após validar o desafio |
| `State.COMPLETED` | Concluída | Nenhuma até recomeçar a aventura |

No início, todas as missões estão não iniciadas. Interagir com o ponto da
primeira missão disponível chama `start_mission`; repetir a conversa apenas
relê as instruções. Uma missão ativa não pode ser iniciada novamente. Não
há conclusão automática por ler ou fechar o diálogo.

`complete_mission` só aceita uma missão ativa. O futuro controlador do puzzle
deve chamá-lo após confirmar a resolução. IDs desconhecidos, repetições e
transições fora de ordem retornam `false` sem mudar o estado ou emitir eventos.
`get_state` retorna `-1` para um ID desconhecido.

## Integração com mapa e interface

O nó `World/Progress` é um adaptador: delega ao singleton e repassa o sinal
`changed` para o mapa. A ponte abre após `bridge`; o portão da caverna abre
após `mill`. Ao recriar o mapa, ele consulta os estados e restaura as passagens.

O painel **Suas missões** apresenta os três estados e atualiza a cada mudança.
Ao voltar ao menu com progresso, **Continuar aventura** recria o mapa sem
perder estados ou eventos. A posição do jogador volta à clareira, mantendo
as passagens abertas. **Recomeçar aventura** chama `new_session()` e limpa
o progresso e o histórico antes de entrar no mapa.

Essa persistência é em memória: fechar o jogo ou recarregar a página encerra
a sessão. Não há gravação em disco, armazenamento do navegador, restauração
após fechamento nem sincronização com o backend nesta issue.

## Eventos de missão

As transições aceitas emitem `mission_started(id)` ou `mission_completed(id)`,
além de `changed`. O sinal `event_recorded(event)` entrega o registro completo
para futura integração com a coleta de resultados.

```json
{
  "id": "<session_id>:1",
  "session_id": "<identificador aleatório da aventura>",
  "type": "MISSION_STARTED",
  "mission_id": "bridge",
  "occurred_at": "2026-11-17T14:00:00Z"
}
```

O tipo de encerramento é `MISSION_COMPLETED`. Cada registro tem identificador
único dentro da sessão, momento UTC obtido do relógio do dispositivo e ID da
missão. O `session_id` local é gerado com 16 bytes aleatórios; ele não é código
de acesso, credencial nem identificador de uma sessão autenticada do backend.
Nenhum nome ou dado pessoal do aluno é incluído.

`get_events()` retorna cópias profundas do histórico; o sinal também entrega
uma cópia para evitar alterações externas no registro interno. Repetir uma
transição recusada não duplica eventos. Ao recomeçar, estados e histórico são
limpos e o identificador da sessão é renovado. Os eventos de sessão e puzzle,
as métricas de tentativas e o envio à API ficam para suas próprias implementações.

## Exemplo para futuros desafios

```gdscript
# A interação com Tobi já iniciou bridge.
if resposta_validada and MissionManager.get_state(&"bridge") == MissionManager.State.ACTIVE:
    MissionManager.complete_mission(&"bridge")
```

Não exponha esse comando em botões de depuração ao jogador. Esta issue não
implementa os puzzles educativos e, portanto, não oferece um atalho para
concluir missões na interface.

## Validação

```sh
godot --headless --path game --script res://tests/mission_test.gd
godot --headless --path game --script res://tests/forest_test.gd
godot --headless --path game --script res://tests/dialogue_test.gd
godot --headless --path game --script res://tests/movement_test.gd
godot --headless --path game --script res://tests/navigation_test.gd
```

O teste do gerenciador cobre estados, pré-requisitos, transições repetidas,
eventos e sinais, cópias do histórico, início pela interação, atualização do
HUD, ida ao menu, continuidade com passagem aberta e reinício com bloqueios.

Na implementação da issue #8 passaram os cinco testes no Godot 4.7.2 e a
exportação release Web. No Chromium 159 via Playwright foram conferidos o
início da missão ao conversar com Tobi, seu estado no painel, continuar pelo
menu e recomeçar, em 1280×720 e 640×360, sem erros no console. As conclusões,
os eventos e a restauração de passagens abertas foram exercitados pelos testes
do gerenciador e de física; os puzzles permanecem fora desta implementação.

A feature parte das anteriores, ainda pendentes em `develop` no início da
implementação. Integre-as antes desta.
