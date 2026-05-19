---
name: register-ticket-session
description: Criar referencia inicial de sessao pendente no workspace C:\codes. Use somente no inicio de um trabalho com chamado ativo para criar chamados/{empresa}/{usuario}/{ano}/{sequencial}/sessoes/pendentes/NNN.md; ao concluir, a skill solicitada para a atividade deve mover a sessao para sessoes/feitas/NNN.md.
---

# Registrar Sessao Chamado

## Objetivo

Criar a referencia inicial de uma sessao pendente para um chamado ativo.

## Apelido

1. Esta skill faz parte de `ctrl_chamados`.
2. Quando o usuario chamar `ctrl_chamados`, considerar esta skill junto com `C:\codes\tools\chamados` e `maintain-tickets`.
3. Quando o usuario chamar `root`, consultar `C:\codes\AGENTS.md`.

## Fluxo

1. Ler `C:\codes\AGENTS.md`.
2. Ler `C:\codes\tools\chamados\AGENTS.md`.
3. Confirmar o chamado ativo.
4. Converter o chamado para `tools/chamados/chamados/{empresa}/{usuario}/{ano}/{sequencial}/`.
5. Ler `chamado.md`.
6. Definir o proximo `NNN` listando `sessoes/pendentes/*.md` e `sessoes/feitas/*.md`.
7. Criar apenas `sessoes/pendentes/NNN.md`.
8. Nao registrar resultado final nesta skill.
9. Para registro mecanico, usar `scripts/registrar-sessao.ps1`.

## Regras

1. Criar a referencia pendente no inicio do trabalho.
2. Nao criar arquivo unico `sessoes.md`.
3. Nao registrar em `C:\codes\pv\sessoes.md` nem em arquivo unico `sessoes.md`.
4. Preservar sessoes existentes.
5. Nao renumerar sessoes antigas.
6. Ao concluir a atividade, a skill executora deve completar e mover o arquivo para `sessoes/feitas/NNN.md`.

## Limites

1. Nao criar chamado novo.
2. Nao mover sessao para `feitas`.
3. Nao escrever historico completo no registro pendente.

## Scripts

1. `scripts/registrar-sessao.ps1`: cria o proximo arquivo em `sessoes/pendentes/NNN.md` para o chamado informado; usar `-Json` quando a chamada vier de CLI que precise parsear a saida.



## Correlacao Obrigatoria de Skills

1. Antes de qualquer mudanca persistente, executar `route-skills-by-context`.
2. Registrar na sessao ativa:
- skill executora
- skills de apoio
- motivo da escolha
- validacao da escolha
3. Sem esse registro, manter atividade como `bloqueado`.
