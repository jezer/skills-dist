---
name: architecture-diagrammer
description: Modelar e revisar diagramas de arquitetura tecnica com consistencia entre componentes, fluxos e fronteiras de sistema.
---

# Architecture Diagrammer

## Objetivo

Modelar diagramas de arquitetura tecnicamente corretos e coerentes com o sistema.

## Uso

1. Diagramas C4, fluxos de integracao e topologias de sistema.
2. Revisao de coerencia entre texto tecnico e diagrama.

## Limites

1. Nao assumir escrita documental completa.
2. Nao assumir narrativa executiva completa.

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
