---
name: maintain-git
description: Preparar ou executar operacoes Git seguras no workspace C:\codes. Use para criar repositorio local e no GitHub quando solicitado, sugerir ou criar branch, preparar mensagem de commit, executar commit ou sincronizar repositorio, seguindo C:\codes\tools\git e exigindo plano/atividade para operacoes persistentes.
metadata:
  camada: atividade
  escopo_negativo:
    - nao commita em branch protegida sem branch de trabalho
    - nao gerencia chamados (maintain-tickets)
    - nao decide conteudo funcional das mudancas
  dependencias:
    - powershell-specialist
    - connect-github-gitlab
  saidas:
    - commit-push.ps1
    - commitar-todos-repos.ps1
    - indice de repositorios
  triggers:
    - commit
    - push
    - sincronizar repositorios
    - commitar todos os repos
    - nova branch
---

# Manter Git

## Objetivo

Padronizar e automatizar operacoes Git recorrentes com limites seguros.

## Uso

1. Usar para criar repositorio quando solicitado.
2. Usar para clonar repositorio quando solicitado, sempre com branch de trabalho explicita.
3. Usar para sugerir ou criar branch.
4. Usar para preparar mensagem de commit.
5. Quando houver pedido de commit, executar por padrao o fluxo completo `sync + commit + push`, exceto se o usuario pedir explicitamente para nao fazer uma dessas etapas.
5.1. Todo pedido de commit deve passar por esta skill (`maintain-git`); nao usar comandos `git` soltos como caminho principal, apenas como detalhe de execucao dos scripts da skill.
5.2. Quando o pedido envolver "todos os repositorios", "todos os repos", "repos do indice" ou equivalente, SEMPRE usar `scripts/commitar-todos-repos.ps1` lendo `indice-repositorios-root-<usuario>.json`, com `-Sync -Push` por padrao (nunca commitar repo a repo manualmente nesse caso).
5.3. Reportar o resultado por repo (`sync_commit_push_completo`, `sincronizado_sem_alteracoes_novas`, `ignorado_branch_protegida`, `commitado_local`) e sinalizar repos sem `origin` e branches protegidas puladas.
6. Consultar `C:\codes\tools\git` somente quando a operacao exigir artefato compartilhado, inventario ou referencia da tool.
7. Usar para bootstrap de repositorio novo, reorganizado ou ja existente com `git-convencoes.md` na raiz.
8. Quando o fluxo exigir publicacao, criar ou vincular o repositorio no GitHub com `gh` a partir do bootstrap.
9. Priorizar comandos e scripts PowerShell para reduzir repeticao, manter os fluxos parametrizados e evitar reescrever sequencias soltas.
10. Usar `C:\codes\skills\plan\gitrepositorio.md` como referencia pratica de bootstrap, publicacao e validacao de repositorio.
11. Quando `gh` nao estiver disponivel, permitir bootstrap local e registrar a publicacao no GitHub como pendente de execucao posterior.
12. Para qualquer operacao remota com GitHub/GitLab (`push`, `pull`, `fetch`, `clone`, `gh repo create`, publicacao), validar autenticacao/conectividade com `connect-github-gitlab` antes da execucao.
13. Quando a demanda envolver configurar ou recuperar Git/SSH em segunda maquina, encaminhar para `connect-secondary-machine-git`.

## Limites

1. Nao executar operacao Git persistente sem pedido explicito.
2. Nao executar commit ou push na branch `main`/`master`; criar branch de trabalho antes.
3. Nao executar reset, rebase, merge ou force push sem pedido explicito.
4. Nao sobrescrever repositorio existente sem confirmacao.
5. Nao executar operacao Git persistente sem plano e atividade.
6. Nao tratar `C:\codes\tools\git` como substituta desta skill nem dos scripts internos desta skill.
7. Nao omitir `git-convencoes.md` quando o repositorio estiver sendo criado ou reorganizado por esta skill.
8. Nao converter o fluxo padrao para outro shell quando PowerShell atender ao caso.
9. Nao assumir publicacao no GitHub se o usuario pediu somente repositorio local.
10. Nao criar repositorio GitHub sem checar autenticacao, disponibilidade de `gh` e intencao de publicacao.
11. Nao declarar publicacao no GitHub quando o ambiente nao tiver `gh` ou credenciais disponiveis.
12. Nao executar clone em pasta ja existente e nao vazia sem confirmacao explicita.
13. Nao executar mudanca persistente sem roteamento previo com `route-skills-by-context` registrado na sessao ativa.
14. Nao alterar regras ou scripts de skills sem acionar `maintain-skills` quando a solicitacao for manutencao de skill.
15. Nao executar comandos Git em repositorio local sem `safe.directory`; sempre aplicar `git -c safe.directory=<repo>` por comando.
16. Em pastas-raiz de empresa (`C:\codes\pv`, `C:\codes\syg`, `C:\codes\cnu`, `C:\codes\theo`, `C:\codes\elohim`, `C:\codes\skills`, `C:\codes\tools`), tratar cada subpasta direta como projeto com repositorio Git proprio, salvo excecao registrada no indice root.
17. So usar submodule quando houver pedido explicito do usuario e registro no plano/atividade.
18. Nao tentar corrigir manualmente cadeia de autenticacao remota quando houver skill especializada de conexao disponivel.
19. Nao encerrar sync quando houver submodulo pendente no pai (`M <submodulo>`); isso exige commit do ponteiro no repositorio pai.
20. Nao executar clone sem branch explicita; se a branch de trabalho nao estiver informada, bloquear e solicitar a branch antes de clonar.
21. Fora do proposito desta skill, devolver ao `route-skills-by-context` (nao improvisar).

## Fluxo

1. Ler `C:\codes\AGENTS.md`.
2. Ler `C:\codes\tools\git\AGENTS.md`.
3. Ler `C:\codes\skills\plan\gitrepositorio.md` quando o pedido envolver bootstrap, publicacao ou convencoes de criacao.
4. Confirmar chamado, plano e atividade quando a operacao for persistente.
5. Executar `route-skills-by-context` como etapa obrigatoria antes de operacao persistente e registrar roteamento na sessao ativa.
6. Conferir `git status` antes de branch, commit, pull, merge, rebase ou push.
7. Quando o pedido for clone, priorizar `scripts/clonar-repositorio.ps1` com URL, destino e branch explicitos.
8. Antes de commit ou push, validar que a branch atual nao e `main` nem `master`; se for, criar branch de trabalho.
9. Se o pedido incluir commit e nao houver restricao explicita, executar `sync + commit + push` no mesmo fluxo.
10. Consultar `C:\codes\tools\git` apenas se houver necessidade de artefato compartilhado.
11. Informar status verificavel ao concluir.
12. Quando o repositorio tiver `git-convencoes.md` na raiz, respeitar o arquivo como referencia local do repositorio.
13. Ler `ModeloRepositorio` em `git-convencoes.md` (`multi-repositorio` ou `mono-repositorio`) para ajustar operacao.
14. Permitir entrada interativa nos scripts da skill quando parametros basicos nao forem informados.
15. Preferir scripts PowerShell reutilizaveis para bootstrap, clone, branch, commit, publicacao no GitHub e sincronizacao em vez de comandos soltos.
16. Para operacoes principais, priorizar os scripts da skill (`clonar-repositorio.ps1`, `novo-repositorio.ps1`, `nova-branch.ps1`, `preparar-commit.ps1`, `commit-push.ps1`, `publicar-github.ps1`, `sync-repositorio.ps1`) e evoluir esses scripts quando houver necessidade recorrente.
17. No fluxo de commit, priorizar `preparar-commit.ps1` para mensagem e `commit-push.ps1` para execucao parametrizada (`-AddAll`, `-Push`, `-Sync`, `-NoVerify`, `-AllowMainMaster`, `-DryRun`) antes de usar comandos Git soltos.
18. O padrao operacional de commit desta skill e `-Sync:$true -Push:$true`; qualquer excecao deve ficar explicita na resposta e no registro da sessao.
19. Para operacoes em lote, priorizar `commitar-todos-repos.ps1` lendo o indice root e aplicar por padrao `sync + commit + push` juntos.
20. No bootstrap com `novo-repositorio.ps1`, tratar `init` de forma idempotente: se `.git` ja existir, nao falhar e seguir o fluxo sem reinicializar.
21. Quando houver warnings de `LF -> CRLF`, aplicar `padronizar-eol.ps1` para gravar `.gitattributes` e, quando necessario, renormalizar o repositorio.
22. Em scripts ou comandos soltos desta skill, aplicar `-c safe.directory=<repo>` em toda chamada Git que opere dentro de repositorio local.
23. Quando detectar repositorio embutido nao planejado, orientar normalizacao para pasta comum (remover gitlink no pai, remover `.git` interno e adicionar arquivos no pai).
24. Antes de concluir manutencao de estrutura de projetos por empresa, atualizar e validar o indice por maquina em `C:\codes\indice-repositorios-root-<usuario>.json` e `C:\codes\indice-repositorios-root-<usuario>.md` (usuario lido de `C:\codes\personalizado.md`).
25. Quando diagnostico indicar erro de conexao, acionar scripts parametrizaveis dos skills `connect-github-gitlab` ou `connect-secondary-machine-git` antes de retentar push/pull.
26. Sem validacao positiva de `connect-github-gitlab`, bloquear operacao remota e registrar pendencia de autenticacao na sessao/chamado.
27. Em fluxo com submodulo, executar obrigatoriamente nesta ordem: `repositorio filho -> repositorio pai`.
28. Em fluxo com submodulo, confirmar no fechamento o status sincronizado de ambos (`filho` e `pai`).
29. Em fluxo de clone, validar apos a execucao que o repositorio ficou exatamente na branch solicitada; se nao ficar, tratar como falha do clone.

## Scripts

1. `scripts/novo-repositorio.ps1`: cria pasta, inicializa repositorio Git e pode criar ou vincular o repo no GitHub quando solicitado.
2. `scripts/clonar-repositorio.ps1`: clona repositorio por URL com destino e branch parametrizados, validando conflito de pasta, exigindo branch explicita, conferindo checkout final e oferecendo suporte a `-DryRun`.
3. `scripts/gravar-convencoes.ps1`: grava o arquivo raiz `git-convencoes.md`.
4. `scripts/nova-branch.ps1`: sugere ou cria branch padronizada.
5. `scripts/preparar-commit.ps1`: gera mensagem de commit padronizada.
6. `scripts/commit-push.ps1`: executa commit parametrizado com validacoes de branch, staging opcional (`-AddAll`), simulacao (`-DryRun`), bypass opcional de hooks (`-NoVerify`) e push opcional no `origin`.
7. `scripts/publicar-github.ps1`: cria ou vincula repositorio GitHub com validacao de autenticacao `gh`.
8. `scripts/padronizar-eol.ps1`: grava `.gitattributes` padrao e pode executar `add --renormalize` para evitar warnings de fim de linha.
9. `scripts/sync-repositorio.ps1`: mostra status e executa pull/push somente com parametro explicito.
10. `git-convencoes.md`: arquivo raiz padrao gerado para registrar nome do repositorio, `BasePath`, regras de branch, regras de commit e orientacoes minimas de bootstrap.
11. `C:\codes\skills\plan\gitrepositorio.md`: referencia pratica de comandos e exemplos de bootstrap Git e GitHub.
12. `scripts/detectar-modelo-repositorio.ps1`: identifica o modelo de repositorio pelo `git-convencoes.md`.
13. `scripts/commitar-todos-repos.ps1`: usa por padrao o indice por maquina `indice-repositorios-root-<usuario>.json` (com fallback para legado) para executar em lote `sync + commit + push` juntos nos repositorios Git habilitados, incluindo a entrada `root/codes-root` quando presente.

## Convencoes locais

1. Todo repositorio tratado por esta skill deve receber `git-convencoes.md` na raiz.
2. O arquivo deve registrar nome do repositorio, `BasePath`, formato de branch e formato de commit.
3. O arquivo deve registrar `ModeloRepositorio: multi-repositorio|mono-repositorio`.
3. No contexto atual de `C:\codes`, o `git-convencoes.md` deve registrar `Provedor remoto padrao: github`.
4. Quando houver contexto com outro provedor (como Azure ou GitLab), a convencao deve ser ajustada no contexto dono, sem quebrar o padrao local atual.
5. O arquivo deve ser curto e legivel rapidamente antes de branch, commit ou push.
6. As regras de branch devem seguir o formato `tipo/escopo-descricao-curta`.
7. As regras de commit devem seguir o formato `tipo(escopo): resumo curto`.
8. Quando necessario, os scripts da skill podem perguntar empresa, nome do repositorio, tipo de branch, escopo e resumo do commit.
9. Quando o bootstrap for executado, o arquivo de convencoes deve ser gravado ou regravado pela skill, inclusive em pasta ja existente.
10. Quando o fluxo for repetitivo, manter a logica em script PowerShell na skill para reutilizacao.
11. Quando houver publicacao no GitHub, o bootstrap deve preferir `gh repo create` ou vinculacao equivalente com `origin`.

## GitHub

1. Usar `gh auth status` ou equivalente para confirmar autenticacao valida quando a publicacao for solicitada; sem token valido, interromper com orientacao para novo login.
2. Usar `gh repo create <nome> --private|--public --source <pasta> --remote origin` para publicar o repositorio no GitHub quando o bootstrap exigir repositorio remoto novo.
3. Se o repositorio GitHub ja existir, vincular o `origin` em vez de tentar recriar.
4. Se o usuario pediu apenas repositorio local, nao forcar publicacao.
5. Se `gh` nao estiver disponivel, tratar como limitacao do ambiente e informar claramente.
6. Quando a publicacao ficar pendente, manter a convencao local e o bootstrap prontos para vincular `origin` depois.

## Tools

1. `C:\codes\tools\git`: regras Git operacionais e apoio sob demanda para inventarios, referencias e artefatos Git compartilhados.
2. Scripts exclusivos desta skill permanecem em `scripts\` ate haver plano aprovado de migracao.


## Correlacao Obrigatoria de Skills

1. Antes de qualquer mudanca persistente, executar `route-skills-by-context`.
2. Registrar na sessao ativa:
- skill executora
- skills de apoio
- motivo da escolha
- validacao da escolha
3. Sem esse registro, manter atividade como `bloqueado`.
