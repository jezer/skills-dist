---
name: maintain-tickets
description: Manutencao minima de chamado no workspace C:\codes. Use somente quando o chamado atual nao estiver objetivo e claro, ou quando Codex precisar criar, localizar, validar ou corrigir o chamado ativo no formato EMPRESA-USUARIO-CH-ANO-NNNNN.
metadata:
  camada: atividade
  escopo_negativo:
    - nao cria planos (maintain-planner)
    - nao implementa a solucao do chamado
  dependencias:
    - maintain-filesystem
  saidas:
    - estrutura de chamado com sessoes
    - indices de chamados
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
8. Fora do proposito desta skill, devolver ao `route-skills-by-context` (nao improvisar).

## Fluxo

Plano 000134 do all_IA (caso 3-A): o BANCO e a fonte dos chamados - esta
skill e CLIENTE da API do all_IA e NAO cria arquivos fisicos; a arvore
`chamados/{empresa}/{usuario}/{ano}/{sequencial}/` e LEGADO somente leitura.

1. Ler `C:\codes\AGENTS.md`.
2. Ler `C:\codes\tools\chamados\AGENTS.md`.
3. Se houver numero de chamado, consultar `GET /chamados/{codigo}` na API do all_IA; chamado antigo sem registro no banco pode ser lido na arvore legada (somente leitura).
4. Se nao houver chamado claro, usar por padrao o ultimo chamado ABERTO no banco (`GET /chamados?empresa=...&usuario=...&status=aberto`) para o usuario e empresa ativos, salvo se o usuario solicitar a criacao de um novo ou informar outro numero.
5. Se nao for possivel localizar o ultimo chamado, perguntar se deve informar um chamado existente ou criar novo chamado.
6. Se criar novo chamado, exigir empresa permitida, usuario permitido e titulo.
7. Para criar chamado novo de forma mecanica, usar `scripts/novo-chamado.ps1` (POST /chamados; offline = fila local drenada pelo backend, caso 6-A).
8. Imediatamente apos criar novo chamado, executar `route-skills-by-context` como primeiro passo obrigatorio antes de qualquer outra mudanca persistente.
9. Registrar a sessao inicial do chamado com `register-ticket-session`, preenchendo `route-skills-by-context` como skill executora inicial.
10. Ao concluir chamado (`PATCH /chamados/{codigo}` com `status=fechado`): verificar se existe sessao `feita` no banco; se nao existir, acionar `register-ticket-session` (`scripts/concluir-sessao.ps1`) antes de fechar.

## Regras

1. Empresas permitidas: `pv`, `syg`, `cnu`, `theo`, `elohim`, `skills`, `tools`.
2. Usuarios permitidos: `jz`, `jf`.
3. Formato do chamado: `EMPRESA-USUARIO-CH-ANO-NNNNN`.
4. O ano reinicia a sequencia; o sequencial vem do banco e nunca colide com a arvore legada (a API confere as duas fontes).
5. O chamado vive nas tabelas `chamado`/`chamado_sessao` do all_IA; NAO criar `chamado.md` novo (000134 caso 3-A).
6. Backend fora do ar: a escrita vai para a fila local `C:\codes\plan\.fila-pendente` (JSONL) e e aplicada na drenagem (caso 6-A); leitura usa o banco indisponivel = consultar legado/espelhos.

## Scripts

1. `scripts/novo-chamado.ps1`: cria o proximo chamado anual NO BANCO via `POST /chamados` (offline = fila) e retorna `ProximaSkillObrigatoria=route-skills-by-context`; usar `-Json` quando a chamada vier de CLI que precise parsear a saida.



## Correlacao Obrigatoria de Skills

1. Antes de qualquer mudanca persistente, executar `route-skills-by-context`.
2. Registrar na sessao ativa:
- skill executora
- skills de apoio
- motivo da escolha
- validacao da escolha
3. Sem esse registro, manter atividade como `bloqueado`.
