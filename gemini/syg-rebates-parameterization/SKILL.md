---
name: syg-rebates-parameterization
description: Governanca SYG para parametrizacao do projeto rebates com foco em contrato CSV, versao de parametros e transicao retrocompativel. Usar quando criar, revisar ou evoluir regras de `meta_safra`, `super_safra` e `pfp`, quando houver mudanca de layout de arquivo, ou quando for necessario acionar validacao tecnica antes da carga.
---

# Syg Parametrizacao Rebates

## Objetivo

Garantir evolucao segura do contrato de parametrizacao do `rebates` sem quebra do legado.

## Uso

1. Usar quando mudar colunas, tipos, chaves ou vigencia de arquivos CSV de parametrizacao.
2. Usar quando revisar documentos do plano em `C:\codes\syg\rebates\plan`.
3. Usar quando validar transicao de contrato com coexistencia de layout.
4. Ler `references/contrato-operacional-parametrizacao.md` antes de propor mudanca.

## Limites

1. Nao substituir skill de workflow, cloudformation ou git.
2. Nao alterar job produtivo sem plano e atividade aprovados.
3. Nao bloquear contrato legado por padrao sem janela de transicao.

## Fluxo recomendado

1. Identificar dominio afetado: meta_safra, super_safra ou pfp.
2. Conferir impacto no contrato CSV por coluna/chave/regra.
3. Definir transicao retrocompativel e evidencias.
4. Acionar validador tecnico em `workflows/user_zone/validators/validate_parametrizacao_csv.py`.
5. Registrar resultado no plano/atividade.

## Dependencias operacionais

1. `python-specialist` para evolucao de validadores.
2. `syg-unit-test-specialist` para testes de regressao.
3. `maintain-activities` para rastreabilidade.
4. `maintain-git` para sync+commit+push.

## Referencias

1. `references/contrato-operacional-parametrizacao.md`.
## Dependencia obrigatoria de roteamento

1. Antes de qualquer mudanca persistente no contexto desta skill, associar o bloco ao `route-skills-by-context`.
2. Quando houver necessidade fora do objetivo desta skill, encaminhar para a skill dona da responsabilidade em vez de duplicar comportamento.



## Correlacao Obrigatoria de Skills

1. Antes de qualquer mudanca persistente, executar `route-skills-by-context`.
2. Registrar na sessao ativa:
- skill executora
- skills de apoio
- motivo da escolha
- validacao da escolha
3. Sem esse registro, manter atividade como `bloqueado`.
