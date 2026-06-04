---
name: register-ticket-session
description: Criar referencia inicial de sessao pendente no workspace C:\codes. Use somente no inicio de um trabalho com chamado ativo para criar chamados/{empresa}/{usuario}/{ano}/{sequencial}/sessoes/pendentes/NNN.md; ao concluir, a skill solicitada para a atividade deve mover a sessao para sessoes/feitas/NNN.md.
metadata:
  triggers:
    - registrar sessao
    - sessao do chamado
---

# Registrar Sessao Chamado

## Objetivo

Criar a referencia inicial de uma sessao pendente para um chamado ativo.

## Apelido

1. Esta skill faz parte de `ctrl_chamados`.
2. Quando o usuario chamar `ctrl_chamados`, considerar esta skill junto com `C:\codes\tools\chamados` e `maintain-tickets`.
3. Quando o usuario chamar `root`, consultar `C:\codes\AGENTS.md`.

## Fluxo — Abertura de sessao

1. Ler `C:\codes\AGENTS.md`.
2. Ler `C:\codes\tools\chamados\AGENTS.md`.
3. Confirmar o chamado ativo.
4. Converter o chamado para `tools/chamados/chamados/{empresa}/{usuario}/{ano}/{sequencial}/`.
5. Ler `chamado.md`.
6. Definir o proximo `NNN` listando `sessoes/pendentes/*.md` e `sessoes/feitas/*.md`.
7. Criar `sessoes/pendentes/NNN.md` com resumo inicial e campos de roteamento.
8. Para abertura mecanica, usar `scripts/registrar-sessao.ps1`.

## Fluxo — Conclusao de sessao (gate obrigatorio antes de fechar chamado)

1. Verificar se existe arquivo em `sessoes/pendentes/`.
2. Se existir: mover para `sessoes/feitas/NNN.md` com resumo completo do trabalho realizado.
3. Se nao existir: criar diretamente em `sessoes/feitas/NNN.md` com resumo retroativo.
4. Somente apos sessao em `feitas/` confirmada: liberar conclusao do chamado (Status: concluido).
5. Para conclusao mecanica, usar `scripts/concluir-sessao.ps1`.

## Regras

1. Criar referencia pendente no inicio do trabalho.
2. Concluir sessao (feita) obrigatoriamente antes de fechar o chamado.
3. Nao criar arquivo unico `sessoes.md`.
4. Preservar sessoes existentes; nao renumerar.
5. Resumo da sessao feita deve cobrir o trabalho efetivamente realizado, nao apenas a intencao inicial.

## Limites

1. Nao criar chamado novo.
2. Nao escrever historico completo no registro pendente.
3. Nao fechar chamado sem sessao em `sessoes/feitas/`.

## Scripts

1. `scripts/registrar-sessao.ps1`: cria `sessoes/pendentes/NNN.md` para o chamado informado.
2. `scripts/concluir-sessao.ps1`: move pendente para `sessoes/feitas/NNN.md` (ou cria feita diretamente se nao houver pendente) com resumo e hash; use antes de concluir o chamado.



## Correlacao Obrigatoria de Skills

1. Antes de qualquer mudanca persistente, executar `route-skills-by-context`.
2. Registrar na sessao ativa:
- skill executora
- skills de apoio
- motivo da escolha
- validacao da escolha
3. Sem esse registro, manter atividade como `bloqueado`.
