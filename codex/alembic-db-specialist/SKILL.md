---
name: alembic-db-specialist
description: Define SQLAlchemy 2.0 models, manage Alembic migrations and write idempotent seed scripts. Use when the activity requires creating or updating ORM models, generating or applying migrations, or populating initial data for any module in the workspace.
---

# Alembic DB Specialist

## Objetivo

Padronizar a definicao de modelos ORM, o ciclo de migrations com Alembic e scripts de seed idemportentes para todos os modulos do workspace.

## Uso

1. Usar para definir modelos SQLAlchemy 2.0 com tipos corretos, relacionamentos e constraints.
2. Usar para inicializar Alembic (`alembic init`), configurar `env.py` com `DATABASE_URL` do `.env` e gerar a primeira migration.
3. Usar para gerar migrations (`alembic revision --autogenerate`) e aplicar (`alembic upgrade head`).
4. Usar para garantir que migrations sao idemportentes: `upgrade head` executado duas vezes nao duplica estrutura.
5. Usar para escrever scripts de seed (`scripts/seed.py`) que verificam existencia antes de inserir.
6. Usar para configurar suporte a SQLite (local/Docker) e PostgreSQL (PaaS) via `DATABASE_URL`.
7. Usar para escrever testes de migration: banco limpo -> `upgrade head` -> verificacao de schema.

## Limites

1. Nao substitui `fastapi-specialist` para estrutura da aplicacao.
2. Nao define logica de negocio; limita-se a estrutura de dados e migracao.
3. Nao executa migrations em banco de producao sem confirmacao explicita no plano.
4. Nao mistura dados de seed com logica de migration; seed e sempre script separado.

## Padroes obrigatorios

1. `DATABASE_URL` lida do `.env` via `python-dotenv`; nunca hardcoded.
2. Migration inicial nomeada `0001_init.py`; subsequentes com prefixo numerico sequencial.
3. Todo seed deve ser idemportente: `if not db.query(Model).filter_by(campo=valor).first(): db.add(...)`.
4. `alembic downgrade base` deve remover todas as tabelas sem erro.
5. Modelos ORM em `app/models.py`; schemas Pydantic em `app/schemas.py` (nunca misturar).

## Dependencias operacionais

1. `python-specialist` para logica Python geral.
2. `fastapi-specialist` para integracao com a aplicacao.
3. `maintain-activities` para status e evidencia.

## Correlacao Obrigatoria de Skills

1. Antes de qualquer mudanca persistente, executar `route-skills-by-context`.
2. Registrar na sessao ativa: skill executora, skills de apoio, motivo da escolha.
3. Sem esse registro, manter atividade como `bloqueado`.
