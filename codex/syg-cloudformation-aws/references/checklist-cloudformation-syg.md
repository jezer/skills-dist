# Checklist CloudFormation SYG

## Objetivo

Validar mudancas em template/parametros com foco em nao regressao e compatibilidade entre ambientes.

## Checklist minimo

1. Confirmar que template principal existe e permanece carregavel.
2. Verificar que parametros `DEV/TEST/PROD` continuam com mesma chave quando nao ha migracao planejada.
3. Evitar renomear/remover parametro usado por stack ativa sem estrategia de transicao.
4. Validar parametros de jobs, cron trigger e conexao antes de publicar mudanca.
5. Conferir se novo parametro tem valor consistente por ambiente ou default explicito.
6. Registrar evidencia no plano/atividade do projeto dono antes de commit.
7. Executar commit/push/sync com `maintain-git`.

## Riscos comuns

1. Divergencia de chave entre ambientes.
2. Mudanca de tipo que quebra stack update.
3. Alteracao de nome de recurso sem plano de impacto.

