---
name: visual-storytelling
description: Transformar conteudo tecnico em narrativa visual com fluxo cognitivo claro para publico tecnico e executivo. Use para narrativa sequencial (sequencia de cenas). Distingue-se de `presentation-designer` (deck de slides) e `ui-infographic-generator` (visualizacao unica).
---

# Visual Storytelling

## Objetivo

Melhorar compreensao e retencao de conteudo tecnico por narrativa visual.

## Uso

1. Estruturar historia tecnica: contexto, problema, decisao e resultado.
2. Apoiar technical-writer e presentation-designer.

## Limites

1. Nao substituir documentacao tecnica detalhada.
2. Nao executar implementacoes de codigo.

## Dependencias operacionais

1. `maintain-skills`
2. `maintain-activities`
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
