# Guardiões do Saber

Repositório do jogo Godot e de seu backend Python.

## Estrutura

- `game/`: projeto e recursos do jogo.
- `backend/`: código e dependências do backend Python.
- `docs/`: documentação técnica e de contribuição.

## Execução

O jogo possui um menu e uma tela inicial com navegação. O backend ainda não
possui dependências ou servidor executável.

### Jogo

Instale o **Godot 4.7.2 Standard** (GDScript). Importe `game/project.godot`
pelo gerenciador de projetos e pressione **F5**, ou execute na raiz:

```sh
godot --path game
```

Use **Iniciar** para abrir a tela do jogo e **Voltar ao menu** para retornar.
Os botões também aceitam navegação por Tab e ativação por Enter/Espaço.
O projeto 2D usa o renderizador Compatibility, base 1280×720 e escala
proporcional com barras nas proporções diferentes de 16:9.

### Testar e exportar para HTML5

Instale os templates de exportação **4.7.2** no Godot em **Editor → Manage
Export Templates**. Na raiz do repositório:

```sh
godot --headless --path game --editor --import --quit
godot --headless --path game --script res://tests/navigation_test.gd
mkdir -p game/build/web
godot --headless --path game --export-release Web build/web/index.html
python3 -m http.server 8000 --directory game/build/web
```

Abra `http://localhost:8000` em um navegador com WebGL 2.0. O servidor deve
continuar ativo durante o teste. Não abra o HTML diretamente via `file://`.
No Windows, crie `game/build/web` pelo explorador ou PowerShell e use `py`
no lugar de `python3`.

Consulte [configuração e validação do Godot](docs/GODOT.md) para detalhes.

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
