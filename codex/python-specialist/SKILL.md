---
name: python-specialist
description: Especialista em Python para criar, revisar e manter scripts no workspace C:\codes com foco em qualidade, parametros e reutilizacao.
---

# Especialista Python

## Objetivo

Projetar e manter scripts Python confiaveis e reaproveitaveis para automacoes do workspace.

## Uso

1. Usar quando a atividade exigir script Python novo ou manutencao de script existente.
2. Usar para revisar argumentos CLI, validacao de entrada, logs e tratamento de excecoes.
3. Usar como apoio tecnico de linguagem para skills donas de dominio.

## Limites

1. Nao substitui a skill dona do dominio da atividade.
2. Nao altera contexto externo sem plano/atividade correspondente.
3. Nao publica mudancas em Git sem solicitacao explicita.

## Dependencias operacionais

1. `maintain-skills` para revisao da skill.
2. `maintain-automations` para padronizacao de scripts parametrizados.
3. `maintain-activities` para status e evidencia.

## Scripts

1. `scripts/testar-script.ps1`: executa um script Python alvo com argumentos.


## Correlacao Obrigatoria de Skills

1. Antes de qualquer mudanca persistente, executar `route-skills-by-context`.
2. Registrar na sessao ativa:
- skill executora
- skills de apoio
- motivo da escolha
- validacao da escolha
3. Sem esse registro, manter atividade como `bloqueado`.
