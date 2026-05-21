---
name: auditar-cartao-pix-juros
description: Auditar faturas e extratos de cartao com foco em PIX, juros, IOF, mora e multa, gerando evidencias por arquivo para detectar possiveis cobrancas indevidas.
---

# Auditar Cartao PIX Juros

## Objetivo

Produzir analise tecnica rastreavel de cobrancas de cartao e extrato, priorizando PIX e encargos financeiros.

## Uso

1. Usar quando houver pedido de investigacao de cobrancas de cartao, extrato, juros, IOF, mora ou multa.
2. Consolidar dados de faturas e extrato por ciclo para comparar valor solicitado, encargos e pagamentos.
3. Extrair e listar todos os PIX por fatura, sem filtro de valor, com totais e recorrencia.
4. Comparar taxa de juros do rotativo versus taxa maxima contratual quando as duas aparecerem na mesma fatura.
5. Classificar saida em `confirmado`, `indicio` e `nao procede`, com evidencia textual por arquivo.
6. Gerar relatorios em `analise/` com resumo executivo e base tecnica em JSON.

## Limites

1. Nao afirmar cobranca indevida sem evidencia objetiva de linha/valor/taxa.
2. Nao ignorar possiveis ruidos de OCR; sempre depurar alertas para reduzir falso positivo.
3. Nao substituir memoria de calculo oficial do banco quando ela for obrigatoria para confirmacao final.
4. Nao alterar documentos originais de fatura ou extrato.

## Fluxo

1. Ler `C:\codes\AGENTS.md` e validar chamado ativo.
2. Inventariar faturas/extratos e mapear periodo coberto.
3. Extrair taxas, valores e eventos PIX por fatura.
4. Reconciliar fatura x extrato (debito direto e pagamentos fracionados quando aplicavel).
5. Aplicar regras de alerta e depois depurar para lista robusta.
6. Entregar relatorio final com evidencias e impacto financeiro estimado.
