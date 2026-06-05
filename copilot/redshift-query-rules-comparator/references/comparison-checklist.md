# Referencia rapida: comparacao de regras SQL

## Objetivo

Padronizar comparacao de regras de coluna entre duas queries Redshift.

## Entradas obrigatorias

1. Query antiga (`old`)
2. Query nova (`new`)
3. Apelidos para leitura do relatorio

## Saidas esperadas

1. Contagem de colunas apenas em um lado
2. Contagem de colunas com regra alterada
3. Lista detalhada com expressao antiga e nova por coluna
4. Log em `C:\codes\tools\csv_comparator\logs_sql_rules`

## Checklist de analise

1. Verificar mudanca em coluna de chave (`cliente_sap_id`, `payer_code` etc.).
2. Verificar mudanca em `CASE` com consolidacao/manual override.
3. Verificar mudanca em percentuais e faixas (`>=`, `>`, `between`).
4. Verificar mudanca em colunas finais de rebate/pontos.
5. Confirmar se diferenca e intencional antes de publicar.
