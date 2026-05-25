---
name: ui-infographic-generator
description: Criar infograficos tecnicos e executivos para resumo de processos, KPIs, comparativos e timelines. Use para visualizacao unica condensada (1 imagem). Distingue-se de `presentation-designer` (deck multi-slide) e `visual-storytelling` (narrativa sequencial).
---

# UI Infographic Generator

## Objetivo

Gerar visuais sinteticos para comunicar dados e processos com clareza.

## Uso

1. Cards comparativos, timelines e resumo de indicadores.
2. Apoiar apresentacoes e documentacao executiva.

## Limites

1. Nao substituir diagramas de arquitetura.
2. Nao substituir documentacao tecnica detalhada.

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
