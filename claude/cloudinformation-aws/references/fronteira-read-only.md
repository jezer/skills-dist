# Fronteira Read-Only - cloudinformation-aws

## Permitido

1. Consultar metadados de recursos.
2. Consultar configuracoes e estados.
3. Coletar evidencias para plano/atividade.
4. Descrever impactos potenciais sem executar mudancas.

## Proibido

1. Criar, alterar ou remover recurso.
2. Aplicar stack/update de CloudFormation.
3. Alterar permissoes, segredos ou dados.
4. Executar carga, backfill ou deploy.

## Escalonamento

1. Mudanca em CloudFormation: `syg-cloudformation-aws`.
2. Mudanca em workflows: `syg-workflows-user-zone`.
3. Mudanca em contrato CSV rebates: `syg-rebates-parameterization`.
4. Publicacao Git: `maintain-git`.

