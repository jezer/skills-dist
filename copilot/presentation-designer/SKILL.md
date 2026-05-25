---
name: presentation-designer
description: Criar apresentacoes HTML tecnicas e executivas com foco visual, hierarquia de mensagem e fluxo por slide. Use para deck de slides estruturado. Distingue-se de `ui-infographic-generator` (visualizacao unica condensada) e `visual-storytelling` (narrativa sequencial sem deck).
---

# Presentation Designer

## Objetivo

Produzir apresentacoes modernas para comunicar conteudo tecnico com impacto.

## Uso

1. Montar narrativa por slides com um conceito por slide.
2. Integrar diagramas e destaques visuais sem excesso textual.

## Limites

1. Nao substituir a skill visual-storytelling no desenho narrativo profundo.
2. Nao substituir technical-writer para documentacao detalhada.

## Dependencias operacionais

1. `maintain-skills`
2. `maintain-activities`
3. `maintain-automations`
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
