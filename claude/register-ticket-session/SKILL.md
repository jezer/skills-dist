---
name: register-ticket-session
description: Criar referencia inicial de sessao pendente no workspace C:\codes. Use somente no inicio de um trabalho com chamado ativo para criar chamados/{empresa}/{usuario}/{ano}/{sequencial}/sessoes/pendentes/NNN.md; ao concluir, a skill solicitada para a atividade deve mover a sessao para sessoes/feitas/NNN.md.
metadata:
  camada: atividade
  escopo_negativo:
    - nao cria chamados (maintain-tickets)
    - nao decide o roteamento (registra o que route-skills-by-context decidiu)
  dependencias:
    - maintain-tickets
    - route-skills-by-context
  saidas:
    - sessoes registradas em sessoes/feitas e pendentes
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

Plano 000134 do all_IA (caso 3-A): sessoes vivem no BANCO (tabela
`chamado_sessao`, estado `pendente`/`feita`) - sem arquivos fisicos novos;
a arvore `sessoes/pendentes|feitas/` e LEGADO somente leitura.

1. Ler `C:\codes\AGENTS.md`.
2. Ler `C:\codes\tools\chamados\AGENTS.md`.
3. Confirmar o chamado ativo (`GET /chamados/{codigo}` na API do all_IA).
4. Criar a sessao pendente no banco via `POST /chamados/{codigo}/sessoes` com resumo inicial e campos de roteamento.
5. Para abertura mecanica, usar `scripts/registrar-sessao.ps1` (offline = fila local, caso 6-A).

## Fluxo — Conclusao de sessao (gate obrigatorio antes de fechar chamado)

1. Verificar se existe sessao `pendente` no banco (`GET /chamados/{codigo}`).
2. Se existir: marcar como `feita` via `PATCH /chamados/{codigo}/sessoes/{numero}` com resumo completo do trabalho realizado.
3. Se nao existir: criar a sessao direto como `feita` com resumo retroativo.
4. Somente apos sessao `feita` confirmada: liberar fechamento do chamado (`status=fechado`).
5. Para conclusao mecanica, usar `scripts/concluir-sessao.ps1`.

## Regras

1. Criar referencia pendente no inicio do trabalho.
2. Concluir sessao (feita) obrigatoriamente antes de fechar o chamado.
3. A numeracao `NNN` e do banco (sequencial por chamado); preservar sessoes existentes, nao renumerar.
4. Resumo da sessao feita deve cobrir o trabalho efetivamente realizado, nao apenas a intencao inicial.
5. Backend fora do ar: a escrita vai para a fila local `C:\codes\plan\.fila-pendente` (JSONL), aplicada na drenagem (caso 6-A); NAO criar arquivos na arvore legada.

## Limites

1. Nao criar chamado novo.
2. Nao escrever historico completo no registro pendente.
3. Nao fechar chamado sem sessao `feita` no banco.
4. Fora do proposito desta skill, devolver ao `route-skills-by-context` (nao improvisar).

## Scripts

1. `scripts/registrar-sessao.ps1`: cria a sessao pendente NO BANCO via API (offline = fila).
2. `scripts/concluir-sessao.ps1`: marca a ultima pendente como `feita` no banco (ou cria feita diretamente se nao houver pendente) com resumo e hash; use antes de fechar o chamado.



## Correlacao Obrigatoria de Skills

1. Antes de qualquer mudanca persistente, executar `route-skills-by-context`.
2. Registrar na sessao ativa:
- skill executora
- skills de apoio
- motivo da escolha
- validacao da escolha
3. Sem esse registro, manter atividade como `bloqueado`.
