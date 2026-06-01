---
name: fastapi-specialist
description: Design, implement and test FastAPI applications in the workspace. Use when the activity requires creating FastAPI routers, middleware, Jinja2 templates, dependency injection, OpenAPI configuration, or testing with TestClient and pytest-asyncio.
---

# FastAPI Specialist

## Objetivo

Padronizar a implementacao de aplicacoes FastAPI no workspace: estrutura de routers, configuracao de middlewares, templates Jinja2, validacao com Pydantic, testes com TestClient e boas praticas de producao.

## Uso

1. Usar para criar ou revisar estrutura de aplicacao FastAPI (`main.py`, `routers/`, `schemas.py`, `config.py`).
2. Usar para configurar Jinja2 como template engine servido pelo FastAPI (MVP 0 sem build step).
3. Usar para implementar middleware de autenticacao, CORS e rate limit.
4. Usar para definir dependency injection com `Depends()` para sessao de banco e autenticacao.
5. Usar para escrever testes com `TestClient` e `pytest-asyncio`.
6. Usar para configurar OpenAPI (`/docs`) e garantir documentacao atualizada por contrato.
7. Usar para configurar startup/shutdown events e health check padronizado (`GET /health`).
8. Usar como apoio tecnico de framework para skills donas de dominio (ia-gateway-specialist, sci-content-flow).

## Limites

1. Nao substitui `python-specialist` para scripts Python genericos.
2. Nao substitui `alembic-db-specialist` para definicao de modelos e migrations.
3. Nao substitui `ia-gateway-specialist` para logica de roteamento de IAs.
4. Nao executa mudanca persistente sem plano e atividade correspondente.
5. Nao faz deploy nem configuracao de infraestrutura; limita-se ao codigo da aplicacao.

## Padroes obrigatorios

1. Porta configuravel via variavel de ambiente `PORT` (padrao `8000`).
2. App nao sobe se variaveis obrigatorias (`DATABASE_URL`, `SECRET_KEY`) estiverem ausentes.
3. `GET /health` retorna `{"status": "ok", "db": "ok", "version": "x.y.z"}`.
4. Routers registrados em `main.py` via `app.include_router()` com prefixo e tags.
5. Schemas Pydantic separados em `schemas.py`; nao misturar com modelos ORM.
6. Testes usam banco SQLite em memoria (`:memory:`) via fixture de `conftest.py`.

## Dependencias operacionais

1. `python-specialist` para logica Python geral.
2. `alembic-db-specialist` para banco de dados.
3. `maintain-activities` para status e evidencia de cada atividade.

## Correlacao Obrigatoria de Skills

1. Antes de qualquer mudanca persistente, executar `route-skills-by-context`.
2. Registrar na sessao ativa: skill executora, skills de apoio, motivo da escolha.
3. Sem esse registro, manter atividade como `bloqueado`.
