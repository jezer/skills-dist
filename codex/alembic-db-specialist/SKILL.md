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

## Padrao obrigatorio de rebuild (drop/recreate/seed)

**Regra:** nunca assumir estado parcial do banco. Antes de confiar nos dados, reconstruir do zero.

O script de rebuild fica em `backend/scripts/rebuild/rebuild.py` e e o padrao para:
- Ambiente de desenvolvimento local
- CI/CD antes de testes de integracao
- Reset apos mudancas de schema em desenvolvimento
- Onboarding de nova maquina

**Sequencia obrigatoria:**
```
1. Base.metadata.drop_all(engine)          # remove todas as tabelas
2. Base.metadata.create_all(engine)        # recria a partir dos modelos
3. alembic stamp head                       # sincroniza tracking de migrations
4. seed_database(db)                        # insere dados iniciais (idemportente)
5. sync_all(db, settings)                  # popula dados do workspace
```

**Como executar:**
```powershell
# Windows
.\backend\scripts\rebuild\rebuild.ps1

# Linux/Mac
bash backend/scripts/rebuild/rebuild.sh

# Python direto (de dentro de backend/)
python scripts/rebuild/rebuild.py

# Makefile
make rebuild

# Sem sync do workspace
python scripts/rebuild/rebuild.py --no-sync
```

**Por que create_all em vez de alembic upgrade head no rebuild:**
- `Base.metadata.create_all` e atomico e confiavel; nao depende de subprocess nem de PATH
- `alembic upgrade head` apos drop pode ter issues de transacao com PostgreSQL DDL
- `alembic stamp head` mantem o tracking de migrations funcionando para o futuro
- Em producao, onde nao e possivel dropar, usar `alembic upgrade head` normalmente

**JSON com BOM (PowerShell):** usar `encoding="utf-8-sig"` em todas as leituras de JSON
gerados pelo PowerShell (`Out-File`, `ConvertTo-Json | Set-Content`). O utf-8-sig e
compativel com UTF-8 sem BOM e com UTF-8 BOM.

## Dependencias operacionais

1. `python-specialist` para logica Python geral.
2. `fastapi-specialist` para integracao com a aplicacao.
3. `maintain-activities` para status e evidencia.

## Correlacao Obrigatoria de Skills

1. Antes de qualquer mudanca persistente, executar `route-skills-by-context`.
2. Registrar na sessao ativa: skill executora, skills de apoio, motivo da escolha.
3. Sem esse registro, manter atividade como `bloqueado`.
