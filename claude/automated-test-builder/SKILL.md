---
name: automated-test-builder
description: Build automated test suites for workspace modules following AAA (Arrange-Act-Assert) and BDD patterns with pytest and Playwright. Use when the activity requires creating test scenarios, test cases, shared reusable functions, parametrized tests, E2E smoke tests, or organizing suites in C:\codes\tools\test_aut.
---

# Automated Test Builder

## Objetivo

Construir suites de testes automatizados reutilizaveis para os modulos do workspace, seguindo os padroes AAA (Arrange-Act-Assert) e BDD, com dados separados da logica, parametrizacao e execucao individual ou em lote.

## Uso

1. Usar para criar cenarios de teste (`scenarios/`): descricao do que deve ser validado em linguagem de negocio.
2. Usar para criar casos de teste (`test_cases/`): implementacao usando funcoes de `shared/actions.py`.
3. Usar para criar dados de teste (`test_data/`): fixtures e datasets separados da logica de execucao.
4. Usar para implementar funcoes reutilizaveis (`shared/actions.py`): `realizar_login`, `criar_artefato`, `publicar_artefato`, `selecionar_topico` etc.
5. Usar para configurar marcadores pytest (`unit`, `integration`, `e2e`, `sci`, `config`, `suggest`, `plan`, `docker`).
6. Usar para implementar testes E2E com Playwright headless.
7. Usar para organizar suites por modulo em `tools/test_aut/suites/{modulo}/`.
8. Usar para configurar relatorio de execucao em `reports/` com sucesso, falha e tempo por cenario.

## Limites

1. Nao implementa logica de negocio; apenas valida comportamento esperado.
2. Nao duplica logica de teste entre suites de modulos diferentes; usa `shared/` para funcoes comuns.
3. Nao altera codigo de producao; apenas cria ou ajusta testes.
4. Nao substitui a skill dona do modulo testado para implementacao de correcoes.
5. Testes unitarios usam banco em memoria (`:memory:`); nunca banco de producao.

## Padroes obrigatorios

1. Cada funcao executa exatamente uma acao (Single Responsibility).
2. Funcoes sao parametrizaveis para multiplos cenarios (Data Driven Testing).
3. Estrutura AAA explicita: Arrange (preparar), Act (executar), Assert (verificar).
4. `pytest --collect-only` deve retornar sem erro de importacao em toda suite.
5. Testes de integracao usam banco SQLite temporario (`tmp_path` do pytest); nunca banco compartilhado.
6. Testes E2E usam `playwright install chromium` como prerequisito e rodam com `--headless`.
7. **Gate de cobertura:** `pytest --cov={modulo} --cov-fail-under=80` e obrigatorio antes de marcar qualquer atividade como concluida. Sem esse gate, atividade permanece em andamento.
8. **Cenarios de instalacao de IA** (`@pytest.mark.ia_install`) sao os primeiros cenarios a implementar em qualquer modulo que use provedores de IA. Parametrizados por provedor; dados em `test_data/providers.json`.

## Fixture de banco SQLite em memoria (padrao conftest.py)

```python
import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool
from app.database import Base, get_db
from app.main import app
from app.seed_data import seed_database

@pytest.fixture()
def db_session():
    engine = create_engine(
        "sqlite:///:memory:",
        future=True,
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    Base.metadata.create_all(bind=engine)
    factory = sessionmaker(bind=engine, future=True)
    with factory() as session:
        seed_database(session)
        yield session

@pytest.fixture()
def client(db_session):
    from fastapi.testclient import TestClient
    def override():
        yield db_session
    app.dependency_overrides[get_db] = override
    with TestClient(app) as c:
        yield c
    app.dependency_overrides.clear()
```

## Fixture com tmp_path para testes de filesystem

```python
def test_sync_filesystem(db_session, tmp_path):
    # Arrange: criar estrutura de diretorios
    (tmp_path / "pv" / "semaforo").mkdir(parents=True)
    (tmp_path / "pv" / "plan").mkdir()   # deve ser ignorado

    # Act
    result = sync_project_tree_from_filesystem(db_session, tmp_path, ["pv"])

    # Assert
    assert result["upserted"] == 1     # so semaforo, nao plan
    assert result["sem_alteracao"] == 0

    # Idempotencia
    result2 = sync_project_tree_from_filesystem(db_session, tmp_path, ["pv"])
    assert result2["upserted"] == 0
    assert result2["sem_alteracao"] == 1
```

## Marcadores pytest usados no projeto all_IA

```ini
# pytest.ini
[pytest]
markers =
    unit: testes unitarios isolados (banco em memoria)
    integration: testes com banco SQLite de teste
    e2e: testes Playwright headless
    ia_install: verifica conexao real com provedor de IA
    ia_smart: cenarios de IA adaptativa por historico
    sci: suite do SCI (artifact-engine, flows)
    docker: requer Docker disponivel
```

## Estrutura padrao de suite

```
test_aut/suites/{modulo}/
  scenarios/   <- descricoes de cenarios em linguagem de negocio
  test_data/   <- dados de entrada e saidas esperadas
  test_cases/  <- implementacao dos casos usando shared/actions.py
```

## Marcadores pytest por tipo

| Marcador | Quando usar |
|---|---|
| `unit` | Logica isolada com banco em memoria |
| `integration` | Fluxo fim-a-fim com banco de teste |
| `e2e` | Interface via Playwright headless |
| `sci` | Suite do SCI (artifact-engine, flows) |
| `docker` | Requer Docker disponivel no ambiente |

## Dependencias operacionais

1. `python-specialist` para logica de teste em Python.
2. `fastapi-specialist` para testes de API com TestClient.
3. `maintain-activities` para status e evidencia.

## Correlacao Obrigatoria de Skills

1. Antes de qualquer mudanca persistente, executar `route-skills-by-context`.
2. Registrar na sessao ativa: skill executora, skills de apoio, motivo da escolha.
3. Sem esse registro, manter atividade como `bloqueado`.
