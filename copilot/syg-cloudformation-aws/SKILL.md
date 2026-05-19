---
name: syg-cloudformation-aws
description: Padrao SYG para parametrizacao e validacao de CloudFormation em projetos de dados. Usar quando criar, revisar ou comparar templates `cloudformation.yml` e arquivos `parameters/*.json`, quando houver mudancas de ambiente (DEV/TEST/PROD), ou quando for necessario validar nao regressao de parametros de jobs/triggers/conexoes antes de deploy.
---

# Syg Cloudformation Aws

## Objetivo

Padronizar a evolucao de artefatos CloudFormation na SYG com foco em compatibilidade entre ambientes e preservacao de contratos existentes.

## Uso

1. Usar para revisar `ci_cd/deploy/*/cloud_formation/templates/cloudformation.yml`.
2. Usar para revisar `ci_cd/deploy/*/cloud_formation/parameters/DEV.json`, `TEST.json` e `PROD.json`.
3. Usar para validar adicao/alteracao de parametros sem quebrar stacks atuais.
4. Carregar `references/checklist-cloudformation-syg.md` antes de propor mudancas estruturais.

## Limites

1. Nao executar deploy diretamente em ambiente.
2. Nao alterar naming/fluxo de workflows; nesse caso acionar skill de workflow SYG.
3. Nao alterar parametros produtivos sem plano e atividade aprovados.
4. Nao substituir `maintain-git`, `maintain-planner` ou `maintain-activities`.

## Fluxo recomendado

1. Mapear template e parametros por ambiente.
2. Verificar contrato de parametros obrigatorios e defaults.
3. Identificar mudancas de risco (remocao/renomeio/tipo).
4. Propor mudanca incremental com plano de transicao.
5. Validar com checklist de nao regressao.

## Dependencias operacionais

1. `route-skills-by-context` para eleicao de skill executora por bloco persistente.
2. `maintain-planner` para alteracoes orientadas a plano.
3. `maintain-activities` para rastreio de status e evidencias.
4. `maintain-git` para commit/push/sync.

## Referencias

1. `references/checklist-cloudformation-syg.md`: checklist de validacao antes de alterar template/parametros.



## Correlacao Obrigatoria de Skills

1. Antes de qualquer mudanca persistente, executar `route-skills-by-context`.
2. Registrar na sessao ativa:
- skill executora
- skills de apoio
- motivo da escolha
- validacao da escolha
3. Sem esse registro, manter atividade como `bloqueado`.
