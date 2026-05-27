---
name: redshift-query-rules-comparator
description: Comparar regras de colunas entre duas queries SQL de Redshift com foco no bloco SELECT (alias e expressao), usando o projeto C:\codes\tools\csv_comparator para gerar diagnostico de diferencas e log auditavel. Use quando houver versoes old/v2/v3/v4 de view/query e for necessario identificar mudancas de regra por coluna antes de alterar dados ou publicar SQL.
---

# Redshift Query Rules Comparator

## Objetivo

Comparar duas queries SQL e apontar diferencas de regra por coluna, com resumo e log rastreavel.

## Fluxo rapido

1. Preparar caminho da query antiga e da query nova.
2. Definir apelidos de comparacao (ex.: `old`, `v4`).
3. Executar `scripts/run-query-rules-comparison.ps1`.
4. Ler o log e separar:
- colunas apenas em um lado
- colunas com regra alterada
- impacto de negocio da diferenca

## Script principal

Use `scripts/run-query-rules-comparison.ps1` para chamar o comparador oficial do projeto `C:\codes\tools\csv_comparator`.

Exemplo:

```powershell
.\scripts\run-query-rules-comparison.ps1 `
  -SqlOld "C:\codes\syg\...\query_old.sql" `
  -SqlNew "C:\codes\syg\...\query_v4.sql" `
  -LabelOld old `
  -LabelNew v4
```

## Interpretacao do resultado

1. `Colunas apenas em old/new`: regra adicionada/removida entre versoes.
2. `Colunas com regra alterada`: mesma coluna com expressao diferente.
3. Priorizar revisao quando mudar:
- chave de relacionamento (ex.: `cliente_sap_id`)
- `CASE` de consolidacao
- faixas percentuais/rebate
- filtros de origem (`WHERE`), quando refletidos em colunas derivadas

## Limites

1. Esta skill compara regras textuais de coluna no `SELECT`; nao executa query no banco.
2. Diferenca de formatacao simples pode aparecer como mudanca se alterar a expressao normalizada.
3. Para validacao de resultado numerico (linha/valor), complementar com `csv_comparator` de CSV.

## Correlacao de skills

1. Use junto de `redshift-sql-specialist` quando a analise fizer parte de diagnostico SQL completo.
2. Antes de mudanca persistente, registrar roteamento de skills na sessao ativa.
