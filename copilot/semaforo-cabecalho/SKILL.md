---
name: semaforo-cabecalho
description: Gerencia o framework Semaforo v3 — atualizar codigo-fonte, regenerar parquet, versionar e deployar o cabecalho Delta no Databricks. Usar quando alterar libs do framework, criar nova versao, resolver colisao de ordens, ou orientar o fluxo de deploy local -> Volumes -> tabela Delta -> loader.
---

# Semaforo Cabecalho

## Objetivo

Manter o ciclo de vida do framework Semaforo armazenado em tabela Delta: fontes Python -> parquet -> tabela -> notebook loader.

## Estrutura do projeto

```
C:\codes\pv\semaforo\cabecalho\
  MANUAL.md                                  <- referencia completa
  scripts\
    gerar-arquivo-cabecalho.py               <- extrai blocos dos fontes Python
    regenerar-cabecalho.ps1                  <- ponto de entrada local
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

1. Alterar fontes Python e rodar `.\scripts\regenerar-cabecalho.ps1 -Versao vX.Y`.
2. Fazer upload do parquet para `/Volumes/libs/dev/libs_dev/semaforo_cabecalho/`.
3. Executar `x.admin.popular-tabela-cabecalho` no Databricks.
4. Testar com notebook que faz `%run x.cabecalho.v3.delta`.
5. Se nova versao: atualizar `_SF_VERSAO` no loader e fazer deploy.

## Regras de ordem dos blocos

- `ordem = ordem_base * 10` para o bloco de imports do modulo.
- Cada classe/funcao seguinte recebe `ordem_base * 10 + i + 1`.
- `createobj` (ordem_base=9) gera ate ordem 102 (13 definicoes) — proximo modulo deve ter ordem_base >= 11.
- Ordens atuais: dmldetect=1, dtAt=2, ctx=3, tabbasic=4, tabver=5, tbstruct=6, env=7, semafbase=8, createobj=9, skphelp=15, monit=20, execmultfunc=25, cabecalho=30, init=1000-1003.
- Ao adicionar modulo novo, verificar colisao: `ordem_base * 10` nao pode cair dentro de `[prev_base*10, prev_base*10 + num_defs_prev]`.

## Imports relativos

Codigo exec'd fora de pacote — `from .x import y` sao removidos automaticamente por `remover_imports_relativos()`. Todas as classes ficam no mesmo `globals()` e se enxergam diretamente.

## Blocos init (ordens 1000-1003)

Executados por ultimo, dependem de todas as classes ja definidas:
- 1000: instancia `SemaforoApp`, registra em `builtins`
- 1001: `GetTags`, `TestarSeSemaforoEstaInstalado`, `IniciarObjPadroes`
- 1002: importa libs de operacao, expande `objparameters` para `globals()`
- 1003: deriva `db_cat_control`

## Limites

1. Nao alterar ordens existentes de blocos sem verificar impacto nos 126+ notebooks dependentes.
2. Nao commitar parquet/CSV no git (arquivos grandes, geraveis localmente).
3. Nao rodar `x.admin.popular-tabela-cabecalho` em `prd` sem validar em `dev` primeiro.
4. Nao remover bloco sem confirmar que nenhum notebook referencia o simbolo diretamente.

## Dependencias operacionais

1. `databricks-notebook-pattern` para criar notebooks que consomem o cabecalho.
2. `maintain-git` para commit e sync apos alteracoes nos fontes.
3. `maintain-planner` para mudancas de versao que afetam multiplos containers.

## Referencias

1. `MANUAL.md`: fluxo completo de deploy e rollback.
2. `DEPLOY.md`: analise das opcoes de instalacao (A/B/C/D) e justificativa da escolha D.
