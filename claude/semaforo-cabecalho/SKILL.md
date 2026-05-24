---
name: semaforo-cabecalho
description: Gerencia o framework Semaforo v3 — atualizar codigo-fonte, regenerar parquet e versionar/deployar o cabecalho Delta no Databricks. Delega a geracao do parquet para `code-parquet-builder` via `config/semaforo.json`. Use quando alterar libs do framework, criar nova versao, resolver colisao de ordens ou orientar o fluxo de deploy local para Volumes, tabela Delta e loader.
---

# Semaforo Cabecalho

## Objetivo

Manter o ciclo de vida do framework Semaforo armazenado em tabela Delta: fontes Python -> parquet -> tabela -> notebook loader.

## Estrutura do projeto

```
C:\codes\pv\semaforo\cabecalho\
  MANUAL.md
  DEPLOY.md
  scripts\
    regenerar-cabecalho.ps1                  <- legado, mantido para compatibilidade
    output\tb_semaforo_cabecalho_v*.parquet  <- artefato para upload
  x.Parameters\
    x.cabecalho.v3.delta.py                  <- loader (deploy no Databricks)
    x.cabecalho.v2.py                        <- versao inline (backup)
  x.admin\
    x.admin.popular-tabela-cabecalho.py      <- popula a tabela Delta
```

Fontes do framework:

```
C:\codes\pv\semaforo\plan\ativo\referencias\python\
  lib_createobj\  <- dmldetect, dtAtualizado, contexttag, tabbasic, tabver,
                     tbstruct, env_semaforo, semafbase, createobj, skphelp,
                     monit, execmultfunc
  cabecalho.py    <- SemaforoGrid, PrintManager, HelperManager,
                     SemaforoInstaller, SemaforoApp
```

## Uso

1. Editar fontes Python em `C:\codes\pv\semaforo\plan\ativo\referencias\python`.
2. Rodar `scripts/regenerar-cabecalho.ps1 -Versao vX.Y` (wrapper local) — ele invoca `code-parquet-builder` com `config/semaforo.json`.
3. Upload do parquet para `/Volumes/libs/dev/libs_dev/semaforo_cabecalho/`.
4. Executar `x.admin.popular-tabela-cabecalho` no Databricks.
5. Testar com notebook que faz `%run x.cabecalho.v3.delta`.
6. Se nova versao: atualizar `_SF_VERSAO` no loader e fazer deploy.

## Arquitetura de geracao

A skill **nao implementa** a logica de extracao AST. Delega para `code-parquet-builder`:

- `config/semaforo.json` declara: versao, `base_python`, `output_dir`, `tabela`, `filtros: ["lib_createobj"]`, lista ordenada de `fontes` e `init_blocos`.
- `scripts/regenerar-cabecalho.ps1` invoca `C:\codes\skills\generators\code-parquet-builder\scripts\build-code-parquet.ps1 -Config config/semaforo.json -Versao vX.Y`.

## Regras de ordem dos blocos

- `ordem = ordem_base * 10` para o bloco de imports do modulo.
- Cada classe/funcao seguinte recebe `ordem_base * 10 + i + 1`.
- `createobj` (ordem_base=9) gera ate ordem 102 (13 definicoes) — proximo modulo deve ter ordem_base >= 11.
- Ordens atuais: dmldetect=1, dtAtualizado=2, contexttag=3, tabbasic=4, tabver=5, tbstruct=6, env_semaforo=7, semafbase=8, createobj=9, skphelp=15, monit=20, execmultfunc=25, cabecalho=30, init=1000-1003.
- Ao adicionar modulo novo, verificar colisao: `ordem_base * 10` nao pode cair dentro de `[prev_base*10, prev_base*10 + num_defs_prev]`.

## Imports filtrados

`code-parquet-builder` aplica filtros automaticamente:

- `from .x import y` e `from . import y` (relativos).
- `from lib_createobj...` e `import lib_createobj` (absolutos), porque tudo e exec'd no mesmo `globals()` no Databricks.

## Blocos init (ordens 1000-1003)

Executados por ultimo, dependem de todas as classes ja definidas. Definidos em `config/semaforo.json` -> `init_blocos`:

- 1000: instancia `SemaforoApp`, registra em `builtins`
- 1001: `GetTags`, `TestarSeSemaforoEstaInstalado`, `IniciarObjPadroes`
- 1002: importa libs de operacao, expande `objparameters` para `globals()`
- 1003: deriva `db_cat_control`

## Limites

1. Nao alterar ordens existentes de blocos sem verificar impacto nos 126+ notebooks dependentes.
2. Nao commitar parquet/CSV no git (arquivos grandes, geraveis localmente).
3. Nao rodar `x.admin.popular-tabela-cabecalho` em `prd` sem validar em `dev` primeiro.
4. Nao remover bloco sem confirmar que nenhum notebook referencia o simbolo diretamente.
5. Nao reimplementar logica de extracao AST aqui; alteracoes do motor vao em `code-parquet-builder`.

## Dependencias operacionais

1. `code-parquet-builder` (geracao parametrizada do parquet).
2. `databricks-notebook-pattern` para criar notebooks que consomem o cabecalho.
3. `maintain-git` para commit e sync apos alteracoes nos fontes.
4. `maintain-planner` para mudancas de versao que afetam multiplos containers.

## Scripts

1. `scripts/regenerar-cabecalho.ps1`: wrapper local que invoca `code-parquet-builder` com `config/semaforo.json`.

## Referencias

1. `C:\codes\pv\semaforo\cabecalho\MANUAL.md`: fluxo completo de deploy e rollback.
2. `C:\codes\pv\semaforo\cabecalho\DEPLOY.md`: analise das opcoes de instalacao (A/B/C/D) e justificativa.
