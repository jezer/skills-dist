---
name: maintain-tickets
description: Manutencao minima de chamado no workspace C:\codes. Use somente quando o chamado atual nao estiver objetivo e claro, ou quando Codex precisar criar, localizar, validar ou corrigir o chamado ativo no formato EMPRESA-USUARIO-CH-ANO-NNNNN.
metadata:
  triggers:
    - criar chamado
    - abrir chamado
    - revisar chamado
---

# Manter Chamados

## Objetivo

Criar, localizar, validar ou corrigir o chamado ativo quando ele nao estiver objetivo e claro.

## Apelido

1. Esta skill faz parte de `ctrl_chamados`.
2. Quando o usuario chamar `ctrl_chamados`, considerar esta skill junto com `C:\codes\tools\chamados` e `register-ticket-session`.
3. Quando o usuario chamar `root`, consultar `C:\codes\AGENTS.md`.

## Uso

1. Usar somente quando o chamado atual nao estiver claro.
2. Nao usar quando o chamado ativo ja estiver definido.
3. Nao registrar sessoes; isso pertence a `register-ticket-session`.

## Limites

1. Nao inventar chamado, empresa, usuario ou titulo.
2. Nao criar regras novas de chamados; alterar regras somente quando o usuario pedir manutencao do `ctrl_chamados`.
3. Nao substituir regras especificas de projeto.
4. Se a manutencao ficar repetitiva ou extensa, criar script auxiliar em `scripts/`.
5. Nao registrar sessao pendente; isso pertence a `register-ticket-session`.
6. Nao criar, editar ou validar arquivo de plano diretamente; qualquer plano deve ser criado e mantido por `maintain-planner`.
7. Nao alterar Status do chamado para `concluido` sem verificar que existe ao menos um arquivo em `sessoes/feitas/`.

## Fluxo

1. Ler `C:\codes\AGENTS.md`.
2. Ler `C:\codes\tools\chamados\AGENTS.md`.
3. Se houver numero de chamado, converter para `chamados/{empresa}/{usuario}/{ano}/{sequencial}/`.
4. Verificar se existe `chamado.md`.
5. Se nao houver chamado claro, usar por padrao o ultimo chamado existente para o usuario e empresa ativos, salvo se o usuario solicitar explicitamente a criacao de um novo chamado ou informar outro numero.
6. Se nao for possivel localizar o ultimo chamado, perguntar se deve informar um chamado existente ou criar novo chamado.
7. Se criar novo chamado, exigir empresa permitida, usuario permitido e titulo.
8. Para criar chamado novo de forma mecanica, usar `scripts/novo-chamado.ps1`.
9. Imediatamente apos criar novo chamado, executar `route-skills-by-context` como primeiro passo obrigatorio antes de qualquer outra mudanca persistente.
10. Registrar a sessao inicial do chamado com `register-ticket-session`, preenchendo `route-skills-by-context` como skill executora inicial.
11. Ao concluir chamado (Status: concluido): verificar se existe arquivo em `sessoes/feitas/`; se nao existir, acionar `register-ticket-session` (`scripts/concluir-sessao.ps1`) antes de alterar o status.

## Regras

1. Empresas permitidas: `pv`, `syg`, `cnu`, `theo`, `elohim`, `skills`, `tools`.
2. Usuarios permitidos: `jz`, `jf`.
3. Formato do chamado: `EMPRESA-USUARIO-CH-ANO-NNNNN`.
4. O ano reinicia a sequencia.
5. O cabecalho do chamado fica em `chamado.md`.

## Scripts

1. `scripts/novo-chamado.ps1`: cria a estrutura do proximo chamado anual para empresa, usuario e titulo informados e retorna `ProximaSkillObrigatoria=route-skills-by-context`; usar `-Json` quando a chamada vier de CLI que precise parsear a saida.



## Correlacao Obrigatoria de Skills

1. Antes de qualquer mudanca persistente, executar `route-skills-by-context`.
2. Registrar na sessao ativa:
- skill executora
- skills de apoio
- motivo da escolha
- validacao da escolha
3. Sem esse registro, manter atividade como `bloqueado`.
