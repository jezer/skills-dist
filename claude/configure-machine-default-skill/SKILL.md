---
name: configure-machine-default-skill
description: Criar, corrigir ou validar a skill ponte global usar-codes-agents no diretorio padrao do Codex para apontar somente para C:\codes\AGENTS.md.
---

# Configure Machine Default Skill

## Objetivo

Manter a ponte global minima do Codex para `C:\codes\AGENTS.md`.

## Uso

1. Usar apenas quando o usuario solicitar manutencao da ponte global.
2. Garantir que a skill global `usar-codes-agents` contenha referencia minima ao `C:\codes\AGENTS.md`.
3. Validar consistencia entre `SKILL.md` e `agents/openai.yaml` da ponte global.

## Limites

1. Nao adicionar regras completas fora de `C:\codes`.
2. Nao alterar outras skills operacionais sem pedido explicito.

## Correlacao Obrigatoria de Skills

1. Antes de qualquer mudanca persistente, executar `route-skills-by-context`.
2. Registrar na sessao ativa:
- skill executora
- skills de apoio
- motivo da escolha
- validacao da escolha
3. Sem esse registro, manter atividade como `bloqueado`.
