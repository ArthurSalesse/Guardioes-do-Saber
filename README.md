# Guardiões do Saber

Repositório do jogo Godot e de seu backend Python.

## Estrutura

- `game/`: projeto e recursos do jogo.
- `backend/`: código e dependências do backend Python.
- `docs/`: documentação técnica e de contribuição.

## Requisitos do MVP

O MVP planejado é uma aventura 2D top-down para crianças de 7 a 10 anos,
ambientada na Floresta dos Números, com três missões de adição e subtração.
Consulte a [documentação de requisitos e conteúdo pedagógico](docs/REQUISITOS.md)
para escopo, missões, eventos, indicadores, acessibilidade e privacidade.
O mapeamento definitivo da BNCC e a aprovação da equipe permanecem pendentes.

## Execução

O jogo possui um menu e uma área de exploração com personagem e colisões. O backend Django REST
Framework utiliza PostgreSQL e oferece um endpoint de saúde.

### Jogo

Instale o **Godot 4.7.2 Standard** (GDScript). Importe `game/project.godot`
pelo gerenciador de projetos e pressione **F5**, ou execute na raiz:

```sh
godot --path game
```

Use **Iniciar** para abrir a tela do jogo e **Voltar ao menu** para retornar.
Movimente o guardião com **WASD** ou **setas**, em quatro direções. O cenário
possui obstáculos e bordas sólidas, com câmera acompanhando o personagem.
Os botões também aceitam navegação por Tab e ativação por Enter/Espaço.
O projeto 2D usa o renderizador Compatibility, base 1280×720 e escala
proporcional com barras nas proporções diferentes de 16:9.

### Testar e exportar para HTML5

Instale os templates de exportação **4.7.2** no Godot em **Editor → Manage
Export Templates**. Na raiz do repositório:

```sh
godot --headless --path game --editor --import --quit
godot --headless --path game --script res://tests/navigation_test.gd
godot --headless --path game --script res://tests/movement_test.gd
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

Instale **Python 3.12 ou superior** (validado com 3.14), PostgreSQL 17 ou Docker
com Compose. Na raiz do repositório:

```sh
python3 -m venv backend/.venv
source backend/.venv/bin/activate
python -m pip install -r backend/requirements.txt
cp backend/.env.example backend/.env
docker compose --env-file backend/.env -f backend/compose.yaml up -d --wait
python backend/manage.py migrate
python backend/manage.py runserver 127.0.0.1:8001
```

No Windows (PowerShell):

```powershell
py -m venv backend/.venv
backend\.venv\Scripts\Activate.ps1
python -m pip install -r backend/requirements.txt
Copy-Item backend/.env.example backend/.env
docker compose --env-file backend/.env -f backend/compose.yaml up -d --wait
python backend/manage.py migrate
python backend/manage.py runserver 127.0.0.1:8001
```

O Compose inicia apenas o banco. Se já tiver PostgreSQL, configure suas
credenciais em `backend/.env` e pule o comando do Compose. Use um banco vazio
dedicado ao projeto. O jogo web permanece na porta 8000 e a API usa 8001.

Confira `http://127.0.0.1:8001/api/health/`: retorna HTTP 200 com
`{"status":"ok","database":"ok"}` quando o banco responde e HTTP 503 quando
está indisponível.

Com o ambiente virtual ativo, valide com:

```sh
python backend/manage.py check
python backend/manage.py test health
```

Os testes de integração precisam de PostgreSQL e permissão de criar o banco
de teste. Consulte [configuração do backend](docs/BACKEND.md) para variáveis,
CORS e testes sem banco.

## Contribuição

Seguimos Git Flow: `main` contém versões estáveis, `develop` integra o
desenvolvimento e `feature/*` recebe novas funcionalidades. Alterações são
integradas por Pull Requests. Consulte o [fluxo de contribuição](docs/CONTRIBUTING.md).

## Licença

Consulte [LICENSE](LICENSE).
