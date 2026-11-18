# Backend Django REST Framework

## Ambiente

Use Python 3.12+ e PostgreSQL 17. As dependências diretas ficam em
`backend/requirements.in`; as versões resolvidas e validadas ficam em
`backend/requirements.txt`. O ambiente `backend/.venv` não é versionado.
Para atualizar as dependências, instale `requirements.in` em um ambiente
virtual limpo, valide os testes e gere novamente o lock com `pip freeze`.

O projeto usa Django 5.2 LTS, DRF, django-cors-headers, psycopg 3 e
python-dotenv. Os pontos de entrada WSGI e ASGI ficam em `backend/config`.
Os comandos para instalar, iniciar o banco e executar estão no [README](../README.md).

## Variáveis de ambiente

Copie `backend/.env.example` para `backend/.env`. O Django carrega esse arquivo
independentemente do diretório de execução. Variáveis já definidas no processo
têm precedência. O arquivo real é ignorado pelo Git.

| Variável | Uso |
| --- | --- |
| `DJANGO_SECRET_KEY` | Obrigatória; chave local de exemplo deve ser substituída em publicação. |
| `DJANGO_DEBUG` | `true` ativa debug; padrão sem configuração é `false`. |
| `DJANGO_ALLOWED_HOSTS` | Hosts permitidos separados por vírgula, sem esquema ou porta. |
| `POSTGRES_DB` | Nome do banco (padrão `guardioes`). |
| `POSTGRES_USER` | Usuário do banco (padrão `guardioes`). |
| `POSTGRES_PASSWORD` | Senha; obrigatória para inicializar o Compose. |
| `POSTGRES_HOST` | Host do banco (padrão `127.0.0.1`). |
| `POSTGRES_PORT` | Porta do banco (padrão `5432`). |
| `POSTGRES_SSLMODE` | Modo SSL do psycopg, padrão `prefer`; ajuste conforme o provedor. |
| `CORS_ALLOWED_ORIGINS` | Origens completas separadas por vírgula, com esquema e porta. |

O Compose é uma opção de banco local e publica a porta apenas em loopback.
O volume `postgres_data` mantém os dados após `docker compose down`; não
altere usuário/senha de um banco existente esperando que o Compose os recrie.
Use as mesmas opções `--env-file` e `-f` do README para parar o serviço com `down`.

## CORS e API

As origens locais permitidas são `http://localhost:8000` e
`http://127.0.0.1:8000`, onde o jogo exportado é servido. O backend roda na
porta 8001 para evitar conflito. Em hospedagem, configure a origem HTTPS real
do jogo e o host da API; não use `*`. CORS aplica-se a `/api/` e não habilita
cookies entre origens. CORS controla leitura por navegadores, não autenticação.

O DRF exige autenticação por padrão nas futuras views. `GET /api/health/`
é explicitamente público, sem autenticação e retorna JSON:

- HTTP 200: `{"status":"ok","database":"ok"}`.
- HTTP 503: `{"status":"unavailable","database":"unavailable"}`.

O endpoint executa `SELECT 1` e funciona como readiness do banco, sem validar
o estado das migrações. O tempo limite de conexão é de três segundos. As
respostas incluem `Cache-Control: no-store` e não revelam erros ou credenciais.
Outros métodos de escrita retornam 405. Não há recursos de gameplay nesta etapa.

## Validação

Na raiz, com o ambiente virtual ativo:

```sh
python backend/manage.py check
python backend/manage.py test health
python backend/manage.py makemigrations --check --dry-run
python -m pip check
```

O usuário precisa de permissão `CREATEDB` para criar e remover `test_<POSTGRES_DB>`.
O usuário inicial do container local tem essa permissão. Não execute os testes
com credenciais de produção. Para testar saúde e CORS sem PostgreSQL:

```sh
python backend/manage.py test health.tests.HealthTests
```

Há seis testes sem banco (200, 503, ausência de informações sensíveis, origens
permitidas/negadas, preflight e método inválido) e um teste de conexão real.

A branch da issue #3 inclui as issues #1 e #2, ainda pendentes em `develop`
no início desta implementação. Integre-as na ordem antes de integrar esta feature.

Na implementação foram aprovados os sete testes em Python 3.14 com PostgreSQL
17 temporário, as migrações, `check`, `makemigrations --check --dry-run`,
`pip check` e a validação do Compose. Também foram confirmados por HTTP real
o status 200 com o banco disponível e 503 após encerrá-lo, ambos com o
cabeçalho CORS da origem local do jogo. O banco temporário foi removido.

Referências: [Django](https://docs.djangoproject.com/en/5.2/),
[DRF](https://www.django-rest-framework.org/) e
[CORS](https://github.com/adamchainz/django-cors-headers).
