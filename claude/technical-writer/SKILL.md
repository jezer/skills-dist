---
name: technical-writer
description: Criar e revisar documentacao tecnica em Markdown com estrutura profissional, diagramas Mermaid validos e linguagem objetiva.
---

# Technical Writer

## Objetivo

Produzir documentacao tecnica clara, rastreavel e visualmente organizada.

## Uso

1. Documentacao de arquitetura, fluxos e operacao.
2. Padronizacao de secoes tecnicas com tabelas e Mermaid.

## Limites

1. Nao implementa codigo de negocio.
2. Nao substitui skill de apresentacao visual executiva.

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
