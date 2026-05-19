---
name: syg-workflows-user-zone
description: Padrao SYG para naming, cascata e transicao de workflows/jobs na camada user_zone. Usar quando criar, revisar ou migrar nome de jobs e encadeamentos (A0/A1/B1...), quando for necessario mapear estado atual para estado alvo sem quebra, ou quando houver ajuste de orquestracao entre ingestao e carga.
---

# Syg Workflows User Zone

## Objetivo

Padronizar evolucao de workflows SYG na user_zone com mudancas incrementais, rastreaveis e retrocompativeis.

## Uso

1. Usar para revisar arquivos de jobs em `workflows/user_zone/glue_jobs`.
2. Usar para definir/migrar naming de etapas A0/A1/B1 e cascatas relacionadas.
3. Usar para montar estrategia de transicao sem quebrar dependencias existentes.
4. Ler `references/checklist-workflows-user-zone.md` antes de qualquer proposta de renome ou reencadeamento.

## Limites

1. Nao alterar CloudFormation; acionar `syg-cloudformation-aws` quando necessario.
2. Nao alterar regras de contrato CSV; acionar `syg-rebates-parameterization`.
3. Nao executar deploy em ambiente.
4. Nao substituir skills de governanca (`maintain-planner`, `maintain-activities`, `maintain-git`).

## Fluxo recomendado

1. Levantar estado atual de naming/encadeamento.
2. Definir alvo com tabela `atual -> alvo`.
3. Projetar fase de coexistencia e rollback.
4. Validar impacto em testes e automacoes antes de consolidar.

## Dependencias operacionais

1. `route-skills-by-context` para roteamento obrigatorio antes de mudanca persistente.
2. `syg-unit-test-specialist` para cobertura de regressao em jobs.
3. `maintain-activities` para trilha de execucao.
4. `maintain-git` para sync+commit+push.

## Referencias

1. `references/checklist-workflows-user-zone.md`.



## Correlacao Obrigatoria de Skills

1. Antes de qualquer mudanca persistente, executar `route-skills-by-context`.
2. Registrar na sessao ativa:
- skill executora
- skills de apoio
- motivo da escolha
- validacao da escolha
3. Sem esse registro, manter atividade como `bloqueado`.
