---
name: databricks-notebook-pattern
description: Cria e revisa notebooks Databricks seguindo a arquitetura padrao do ambiente — cabecalho Semaforo, declaracao de dependencias, padroes de carga incremental (MERGE) e full (INSERT), finalizacao com lib_normalizar. Usar sempre que criar um notebook novo ou revisar conformidade de existente com o padrao da plataforma.
---

# Databricks Notebook Pattern

## Objetivo

Garantir que notebooks Databricks sigam a arquitetura padrao do ambiente — estrutura de celulas, cabecalho Semaforo, declaracao de dependencias, padroes Delta e finalizacao correta.

## Estrutura padrao de um notebook

```python
# Databricks notebook source
# MAGIC %md
# MAGIC # NOME_DA_TABELA
# MAGIC Descricao do que o notebook faz e qual o tipo de carga.

# COMMAND ----------

# DBTITLE 1,Cabecalho e parametros padrao
# MAGIC %run "/projetos/pv/01semaforo.cabecalho/x.Parameters/x.cabecalho.v3.delta"

# COMMAND ----------

# MAGIC %run "../x.tools/x.project_functions"

# COMMAND ----------

# DBTITLE 1,Declarar dependencias de entrada
lib_dependencia.public.informar.IncluirDependencia_Fonte(f"{db_cat_trusted}.tb_origem", objparameters)

# COMMAND ----------

# DBTITLE 1,Configurar variaveis do notebook
tableDestino = 'tb_destino'
campoParticao = 'year'
...

# COMMAND ----------

# DBTITLE 1,Verificar tipo de carga (full ou incremental)
_cargaFull = not lib_operacionalizar.catalog.check.check_table_exist(
    f'{db_cat_trusted}.{tableDestino}'
)

# COMMAND ----------

# DBTITLE 1,Criar estrutura da tabela se nao existir
spark.sql(f"""
    CREATE TABLE IF NOT EXISTS {db_cat_trusted}.{tableDestino} (
        ...
    )
    USING delta
    PARTITIONED BY (year, month)
""")

# COMMAND ----------

# DBTITLE 1,Carga dos dados
# INSERT INTO para full; MERGE INTO para incremental

# COMMAND ----------

# DBTITLE 1,Declarar objetos criados
lib_dependencia.public.informar.IncluirDependencia_ObjCriado(
    f"{db_cat_trusted}.{tableDestino}", objparameters
)

# COMMAND ----------

# DBTITLE 1,Finalizar notebook
lib_normalizar.public.informar.InformarNotebookFinalizarComSucesso(
    'A1.FinalizadoSucesso', objparameters, True
)
```

## Regras obrigatorias

1. Primeira linha sempre `# Databricks notebook source`.
2. Separador entre celulas sempre `# COMMAND ----------`.
3. Cabecalho Semaforo sempre na primeira celula de codigo, antes de qualquer import ou logica.
4. Toda tabela lida deve ser declarada com `IncluirDependencia_Fonte`.
5. Toda tabela criada/atualizada deve ser declarada com `IncluirDependencia_ObjCriado`.
6. Ultima celula sempre `InformarNotebookFinalizarComSucesso`.
7. `CREATE TABLE IF NOT EXISTS` com `USING delta` — nunca criar tabela sem o IF NOT EXISTS.
8. Carga incremental usa `MERGE INTO` com chave primaria explicita.
9. Carga full usa `INSERT INTO` — nunca `overwrite` em tabela Delta sem alinhamento com o time.

## Variaveis disponiveis apos o cabecalho

Apos `%run x.cabecalho.v3.delta`, estas variaveis estao no globals():

| Variavel | Tipo | Descricao |
|---|---|---|
| `db_cat_trusted` | str | Catalog.schema da camada trusted |
| `db_cat_raw` | str | Catalog.schema da camada raw |
| `db_cat_control` | str | Catalog.schema da camada control |
| `objparameters` | dict | Parametros do semaforo (passado para lib_*) |
| `LogOnTable` | bool | Liga/desliga log em tabela |
| `DebugMode` | bool | Modo debug |
| `_Sf_app` | SemaforoApp | Instancia do framework |
| `lib_dependencia` | module | Declaracao de dependencias |
| `lib_normalizar` | module | Normalizacao e finalizacao |
| `lib_operacionalizar` | module | Operacoes catalog, check, etc. |
| `lib_incremental` | module | Cargas incrementais |

## Padroes de nomenclatura de colunas

Prefixos padrao ja adotados no ambiente:
- `nr_` — numero (nr_Pedido, nr_Guia)
- `cd_` — codigo (cd_Situacao, cd_Operadora)
- `fl_` — flag/indicador boolean ou S/N (fl_Opme, fl_Sexo)
- `id_` — chave surrogate de dimensao (id_TipoOrigem, id_Prestador)
- `dt_` — data/timestamp (dt_Inclusao, dt_Autorizacao)
- `nm_` — nome (nm_Prestador, nm_Associado)
- `vl_` — valor monetario ou numerico (vl_DiariaHdc)
- `ds_` — descricao textual (ds_Conselho)
- `hr_` — hora (hr_Internacao)
- `sg_` — sigla (sg_Conselho)
- `uf_` — UF (uf_CrmSolicitante)

## Padroes de carga incremental

```python
# Calcular periodo
from datetime import datetime, date
from dateutil.relativedelta import relativedelta

if not _cargaFull:
    _dtRefFinal = ((datetime.today() - relativedelta(days=1)).date()).strftime('%Y-%m-%d')
    _dtRef = spark.sql(
        f"SELECT max(dt_CargaAtualizacaoRaw) as ultdata FROM {db_cat_trusted}.{tableDestino}"
    ).collect()[0].ultdata
    _dtRef = calcular_data_inicio_incremental(
        data_ultima_carga=_dtRef,
        dias_retrocesso=1,
        data_padrao=date(2020, 1, 1),
        formatar=True,
    )
```

`calcular_data_inicio_incremental` vem de `x.tools/x.project_functions` e trata tabela vazia com fallback seguro.

## Pastas e nomenclatura de notebooks

Convenção de pastas por tipo de objeto:
```
container/
  A0.SETUP/           <- configuracoes e ferramentas
  A1.RAW_*/           <- carga raw (leitura de fonte)
  B1.INCR_*/          <- carga incremental trusted
  C1.DIM_*/           <- dimensoes
  D1.WORK_*/          <- tabelas work/intermediarias
  E1.FATO_*/          <- tabelas fato
  x.tools/            <- funcoes uteis compartilhadas no container
```

Nomenclatura de arquivo: `A1.trusted.CARGA_TB_NOME.py`, `A1.raw.RAW_CARGA_TB_NOME.py`.

## Limites

1. Nao alterar o path do cabecalho sem migrar todos os notebooks do container.
2. Nao usar `spark.read` diretamente em tabelas sem declarar `IncluirDependencia_Fonte`.
3. Nao usar `mode("overwrite")` em tabela Delta sem alinhamento — preferir MERGE ou DELETE+INSERT.
4. Nao criar funcoes uteis inline — colocar em `x.tools/x.project_functions`.
5. Nao hardcodar catalog/schema — sempre usar variaveis do `objparameters`.

## Dependencias operacionais

1. `semaforo-cabecalho` para atualizar o framework carregado pelo cabecalho.
2. `maintain-git` para commit apos criacao/alteracao de notebooks.
3. `maintain-planner` para mudancas estruturais que afetam multiplos notebooks.

## Referencias

1. Container de referencia: `C:\codes\cnu\11autorizacaodiario_v2.v1.a1`
2. Funcoes uteis de referencia: `x.tools/x.project_functions.py` no container acima
3. Cabecalho loader: `C:\codes\pv\semaforo\cabecalho\x.Parameters\x.cabecalho.v3.delta.py`
