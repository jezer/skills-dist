---
name: cloudinformation-aws
description: Skill de apoio para consulta de informacoes AWS em modo somente leitura. Usar quando for necessario inventariar conta, regiao, recursos e configuracoes para diagnostico, planejamento ou validacao previa, sem executar alteracoes em infraestrutura, dados ou deploy.
---

# Cloudinformation Aws

## Objetivo

Oferecer um ponto padrao de consulta read-only de contexto AWS para projetos SYG.

## Uso

1. Usar para levantamento de contexto (recursos, parametros, regioes, contas).
2. Usar para preparar evidencias antes de mudancas em CloudFormation, workflows ou dados.
3. Usar para diagnostico inicial sem impacto operacional.
4. Ler `references/fronteira-read-only.md` antes de qualquer comando.

## Limites

1. Nao criar, atualizar, remover ou publicar recursos AWS.
2. Nao executar deploy, migration, carga ou alteracao de permissao.
3. Nao substituir skills executoras de mudanca.
4. Quando houver pedido de alteracao, rotear para skill executora adequada.

## Roteamento obrigatorio

1. Se o pedido envolver CloudFormation, encaminhar para `syg-cloudformation-aws`.
2. Se envolver workflow/user_zone, encaminhar para `syg-workflows-user-zone`.
3. Se envolver contrato CSV de rebates, encaminhar para `syg-rebates-parameterization`.
4. Se envolver Git, encaminhar para `maintain-git`.

## Dependencias operacionais

1. `route-skills-by-context` para eleicao de skill executora por atividade.
2. `maintain-activities` para registrar evidencias no plano ativo.

## Referencias

1. `references/fronteira-read-only.md`.



## Correlacao Obrigatoria de Skills

1. Antes de qualquer mudanca persistente, executar `route-skills-by-context`.
2. Registrar na sessao ativa:
- skill executora
- skills de apoio
- motivo da escolha
- validacao da escolha
3. Sem esse registro, manter atividade como `bloqueado`.
