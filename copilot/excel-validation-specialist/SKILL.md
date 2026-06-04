---
name: excel-validation-specialist
description: Apoiar leitura tecnica de planilhas Excel para reconciliacao com SQL, mapeando colunas/linhas, divergencias de valor e criterios de validacao para investigacao e correcao de queries analiticas.
metadata:
  camada: ferramenta
  escopo_negativo:
    - nao define a regra de negocio das planilhas (skill de atividade)
  dependencias:
    - python-specialist
  saidas:
    - validadores de planilha parametrizados
---

# Especialista Leitura Excel Validacao

## Objetivo

Transformar evidencias de Excel em insumos tecnicos objetivos para investigacao e correcao de SQL.

## Uso

1. Usar quando houver comparacao entre resultado de query e planilha de validacao.
2. Usar para mapear casos divergentes por coluna, linha e regra de negocio.
3. Usar para produzir matriz de reconciliacao `campo -> atual -> esperado -> status`.

## Limites

1. Nao alterar SQL diretamente sem plano e atividade.
2. Nao assumir significado de coluna sem evidencia no arquivo de referencia.
3. Nao encerrar validacao sem registrar casos divergentes e criterio de aceite.
4. Fora do proposito desta skill, devolver ao `route-skills-by-context` (nao improvisar).

## Checklist tecnico

1. Identificar aba e intervalo usados na validacao.
2. Catalogar colunas de comparacao (resultado atual, esperado e status).
3. Normalizar formato numerico (percentual, decimal, separador de milhar e decimal).
4. Gerar lista de casos `falso` com referencia de linha e coluna.
5. Entregar matriz objetiva para investigacao SQL.


## Correlacao Obrigatoria de Skills

1. Antes de qualquer mudanca persistente, executar `route-skills-by-context`.
2. Registrar na sessao ativa:
- skill executora
- skills de apoio
- motivo da escolha
- validacao da escolha
3. Sem esse registro, manter atividade como `bloqueado`.
