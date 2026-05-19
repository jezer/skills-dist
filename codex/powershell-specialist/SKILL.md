---
name: powershell-specialist
description: Especialista em PowerShell para criar, revisar e manter scripts no workspace C:\codes com foco em robustez, parametrizacao e reaproveitamento.
---

# Especialista PowerShell

## Objetivo

Projetar e manter scripts PowerShell confiaveis, legiveis e parametrizados para automacoes locais.

## Uso

1. Usar quando a implementacao exigir script PowerShell novo ou manutencao de script existente.
2. Usar para revisar tratamento de erro, parametros obrigatorios e saidas previsiveis.
3. Usar como apoio tecnico para skills donas de dominio que possuam scripts PowerShell.

## Limites

1. Nao assume o proposito da skill dona do dominio da atividade.
2. Nao altera contexto externo sem atividade/plano correspondente.
3. Nao executa publicacao Git sem solicitacao explicita.

## Dependencias operacionais

1. `maintain-skills` para criacao/revisao da skill.
2. `maintain-automations` para padronizacao de scripts parametrizados.
3. `maintain-activities` para rastrear status e evidencia.

## Scripts

1. `scripts/testar-script.ps1`: verificacao rapida de sintaxe e execucao controlada.


## Correlacao Obrigatoria de Skills

1. Antes de qualquer mudanca persistente, executar `route-skills-by-context`.
2. Registrar na sessao ativa:
- skill executora
- skills de apoio
- motivo da escolha
- validacao da escolha
3. Sem esse registro, manter atividade como `bloqueado`.
