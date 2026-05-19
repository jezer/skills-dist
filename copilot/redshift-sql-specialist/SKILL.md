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


## Correlacao Obrigatoria de Skills

1. Antes de qualquer mudanca persistente, executar `route-skills-by-context`.
2. Registrar na sessao ativa:
- skill executora
- skills de apoio
- motivo da escolha
- validacao da escolha
3. Sem esse registro, manter atividade como `bloqueado`.
