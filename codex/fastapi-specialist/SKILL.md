---
name: fastapi-specialist
description: Design, implement and test FastAPI applications in the workspace. Use when the activity requires creating FastAPI routers, middleware, Jinja2 templates, dependency injection, lifespan events, StaticFiles, OpenAPI configuration, or testing with TestClient and pytest-asyncio.
metadata:
  camada: ferramenta
  escopo_negativo:
    - nao modela migrations de banco (alembic-db-specialist)
    - nao especializa por empresa (skill de atividade da cadeia)
  dependencias:
    - python-specialist
  saidas:
    - routers/services FastAPI com testes
---

# FastAPI Specialist

## Objetivo

Padronizar a implementacao de aplicacoes FastAPI no workspace: estrutura de routers,
middlewares, templates Jinja2, validacao com Pydantic, testes com TestClient e boas praticas.

## Quando usar

1. Criar ou revisar estrutura FastAPI (`main.py`, `routers/`, `schemas.py`, `config.py`).
2. Configurar Jinja2 como template engine servido pelo FastAPI (sem build step separado).
3. Implementar middleware (autenticacao, CORS, rate limit).
4. Definir dependency injection com `Depends()` para sessao de banco.
5. Escrever testes com `TestClient` e fixtures de banco em memoria.
6. Configurar eventos de ciclo de vida (startup, shutdown).
7. Servir assets estaticos (CSS, JS, imagens) com `StaticFiles`.

## Limites

1. Nao substitui `python-specialist` para scripts Python genericos.
2. Nao substitui `alembic-db-specialist` para modelos e migrations.
3. Nao substitui `ia-gateway-specialist` para logica de roteamento de IAs.
4. Nao faz deploy; limita-se ao codigo da aplicacao.
5. Fora do proposito desta skill, devolver ao `route-skills-by-context` (nao improvisar).

## Padroes obrigatorios

### Lifespan (substitui @app.on_event — deprecated desde FastAPI 0.103)

```python
from contextlib import asynccontextmanager
from fastapi import FastAPI

@asynccontextmanager
async def lifespan(app: FastAPI):
    # startup: popula dados, valida conexoes
    _sync_initial_data()
    yield
    # shutdown: fecha conexoes, limpa recursos

app = FastAPI(lifespan=lifespan)
```

### Health check padrao

```python
@app.get("/health", tags=["system"])
def health() -> dict[str, str]:
    check_database()
    return {"status": "ok", "db": "ok", "version": settings.version}
```

### StaticFiles + templates Jinja2

```python
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from pathlib import Path

_FRONTEND = Path(__file__).resolve().parents[2] / "frontend"
app.mount("/static", StaticFiles(directory=str(_FRONTEND / "static")), name="static")

templates = Jinja2Templates(directory=str(_FRONTEND / "templates"))

@router.get("/", response_class=HTMLResponse)
def index(request: Request) -> HTMLResponse:
    return templates.TemplateResponse("index.html", {"request": request})
```

### Configuracao via .env

```python
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    database_url: str
    secret_key: str
    port: int = 8000
    version: str = "0.1.0"
    allowed_origins: list[str] = ["http://localhost:8000"]

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

# Falha na inicializacao se DATABASE_URL ou SECRET_KEY ausentes
```

### Fixture de teste com banco SQLite em memoria

```python
# tests/conftest.py
import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

from app.database import Base, get_db
from app.main import app

@pytest.fixture()
def client():
    engine = create_engine(
        "sqlite:///:memory:",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
        future=True,
    )
    Base.metadata.create_all(bind=engine)
    factory = sessionmaker(bind=engine, future=True)

    def override_db():
        db = factory()
        try:
            yield db
        finally:
            db.close()

    app.dependency_overrides[get_db] = override_db
    with TestClient(app) as c:
        yield c
    app.dependency_overrides.clear()
```

### Middleware de API key

```python
from starlette.middleware.base import BaseHTTPMiddleware

class APIKeyMiddleware(BaseHTTPMiddleware):
    def __init__(self, app, api_key: str | None):
        super().__init__(app)
        self.api_key = api_key

    async def dispatch(self, request, call_next):
        if self.api_key and request.url.path not in ("/health", "/docs", "/openapi.json"):
            key = request.headers.get("X-API-Key")
            if key != self.api_key:
                return JSONResponse({"detail": "Unauthorized"}, status_code=401)
        return await call_next(request)
```

### Include routers em main.py

```python
# Prefixos e tags por domínio
app.include_router(context_router)        # sem prefixo — rotas raiz
app.include_router(context_admin_router)  # prefix="/context"
app.include_router(skills_router)         # prefix="/skills"
app.include_router(tokens_router)         # prefix="/tokens"
```

> **Ordem importa:** rotas literais (ex: `GET /skills/ia-index`) devem ser registradas
> ANTES de rotas parametrizadas (ex: `GET /skills/{nome}`) para evitar conflito de match.

## Padroes de codigo

1. Porta configuravel via variavel `PORT` (padrao `8000`).
2. App nao sobe sem `DATABASE_URL` e `SECRET_KEY`.
3. Schemas Pydantic em `schemas.py` ou inline no router; nunca misturar com ORM.
4. CORS configuravel via `ALLOWED_ORIGINS` no `.env`.
5. `TestClient` usa sempre banco SQLite em memoria — nunca o banco de producao.

## Dependencias operacionais

1. `python-specialist` para logica Python geral.
2. `alembic-db-specialist` para banco de dados.
3. `frontend-assets-specialist` para assets estaticos (WebP, favicon, etc.).
4. `maintain-activities` para status e evidencia.
