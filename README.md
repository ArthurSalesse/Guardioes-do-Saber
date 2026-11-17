# Guardiões do Saber

Repositório do jogo Godot e de seu backend Python.

## Estrutura

- `game/`: projeto e recursos do jogo.
- `backend/`: código e dependências do backend Python.
- `docs/`: documentação técnica e de contribuição.

## Execução

O repositório está na etapa de estruturação. Ainda não existem um projeto
`game/project.godot`, dependências Python ou um servidor executável.
Os passos abaixo preparam o ambiente para as próximas implementações.

### Jogo

Instale o Godot. A versão será definida quando o projeto for criado.
Quando `game/project.godot` estiver disponível, importe esse arquivo pelo
gerenciador de projetos do Godot, abra o projeto e pressione **F6** para
executar a cena atual ou **F5** para executar a cena principal configurada.

### Backend

Instale Python 3 e crie um ambiente virtual a partir da raiz do repositório:

```sh
python3 -m venv backend/.venv
source backend/.venv/bin/activate
```

No Windows (PowerShell):

```powershell
py -m venv backend/.venv
backend\.venv\Scripts\Activate.ps1
```

Ainda não há pacotes para instalar nem comando de inicialização do backend.
Essas instruções serão adicionadas junto com sua implementação.

## Contribuição

Seguimos Git Flow: `main` contém versões estáveis, `develop` integra o
desenvolvimento e `feature/*` recebe novas funcionalidades. Alterações são
integradas por Pull Requests. Consulte o [fluxo de contribuição](docs/CONTRIBUTING.md).

## Licença

Consulte [LICENSE](LICENSE).
