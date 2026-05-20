---
name: redshift-sql-specialist
description: Investigar, diagnosticar e orientar correcoes SQL em Amazon Redshift com foco em views analiticas, regras percentuais, cast/conversao numerica, joins e validacao de resultados por amostra de negocio.
---

# Especialista Redshift SQL

## Objetivo

Apoiar investigacao tecnica e correcao de queries Redshift com rastreabilidade de causa raiz e impacto.

## Uso

1. Usar quando houver divergencia de resultados SQL versus regra de negocio.
2. Usar para revisar views complexas com CTEs, calculos percentuais e faixas de regra.
3. Usar antes de alterar SQL de producao quando houver validacao externa (ex.: Excel).

## Limites

1. Nao publicar mudanca sem plano e atividades.
2. Nao alterar contexto de dados fora do projeto dono.
3. Nao assumir sem validar unidade de medida de percentual e moeda.

## Checklist tecnico

1. Validar normalizacao de percentual (texto `%` para numerico) e escala final (ex.: `3` vs `3%`).
2. Validar faixas de comparacao (`>= inicio` e `< fim`) e casos `%`, `%>`, `K`, `K>`, `S.S%`, `S.S%>`.
3. Verificar divisoes por `100` e `1000` para garantir unidade correta.
4. Verificar `NULLIF` e divisao por zero em indicadores.
5. Validar output por amostra controlada com casos de negocio informados.


## Executor padrao SYG (contexto syg)

No contexto `syg`, usar o executor em `C:\codes\syg\redshift` para rodar queries com rastreabilidade.

### Chamada rapida via wrapper PowerShell

```powershell
# dry-run (valida sem conectar)
.\scripts\run-redshift-query.ps1 -Profile test -DryRun

# executar query e salvar resultado
.\scripts\run-redshift-query.ps1 -Profile test -QueryFile queries/smoke_test.sql -SaveResults

# diagnostico de rede
.\scripts\run-redshift-query.ps1 -Profile test -Diagnostic
```

### Parametros aceitos

| Parametro | Valores | Padrao |
|---|---|---|
| `-Profile` | `dev`, `test`, `prod` | `test` |
| `-QueryFile` | caminho relativo ao projeto | `queries/smoke_test.sql` |
| `-ConfigFile` | caminho JSON de perfis | secrets privados em `pv/particular` |
| `-SaveResults` | flag | off |
| `-DryRun` | flag | off |
| `-Diagnostic` | flag | off |

### Saida JSON (modo execute)

```json
{
  "status": "ok",
  "profile": "test",
  "executed_at": "2026-05-19T10:00:00",
  "elapsed_ms": 123.45,
  "rows_preview_count": 2,
  "columns": ["col1", "col2"],
  "rows_preview": [["v1", "v2"]],
  "saved_to": "results/20260519_100000_test_smoke_test.json"
}
```

### Limites de integracao

1. Executor limitado ao contexto `syg` — nao usar para outros projetos sem plano proprio.
2. Nao gravar credenciais em arquivos de resultado.
3. Perfil `prod` somente com atividade aprovada e plano registrado.

## Correlacao Obrigatoria de Skills

1. Antes de qualquer mudanca persistente, executar `route-skills-by-context`.
2. Registrar na sessao ativa:
- skill executora
- skills de apoio
- motivo da escolha
- validacao da escolha
3. Sem esse registro, manter atividade como `bloqueado`.
