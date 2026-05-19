---
name: connect-github-gitlab
description: Recuperar conectividade Git com GitHub/GitLab no Windows usando scripts parametrizaveis. Use quando houver erro de autenticacao SSH/HTTPS, falha de ssh-agent, chave ausente, ou bloqueio de push/pull por conexao.
---

# Conectar GitHub GitLab

## Objetivo

Diagnosticar e corrigir falhas de conexao Git com GitHub/GitLab por meio de scripts reutilizaveis e parametrizaveis.

## Uso

1. Usar quando `git fetch/pull/push` falhar por autenticacao ou SSH.
2. Usar quando `ssh -T git@github.com` ou `ssh -T git@gitlab.com` falhar.
3. Usar para padronizar o OpenSSH do Windows no Git.

## Limites

1. Nao executa push automaticamente.
2. Nao publica chave em contas remotas sem pedido explicito.
3. Nao manipula segredos fora do perfil do usuario sem autorizacao.

## Fluxo

1. Executar `scripts/diagnosticar-conexao-git.ps1`.
2. Corrigir ambiente local com `scripts/configurar-ssh-windows.ps1`.
3. Se necessario, gerar chave com `scripts/gerar-chave-ssh.ps1`.
4. Validar conexao com `scripts/testar-conexao-remota.ps1`.
5. Registrar no chamado resultado e pendencias remotas (ex.: chave nao cadastrada no provedor).

## Scripts

1. `scripts/diagnosticar-conexao-git.ps1`: verifica Git, OpenSSH, ssh-agent e teste de conexao.
2. `scripts/configurar-ssh-windows.ps1`: liga ssh-agent, adiciona chave e define `core.sshCommand`.
3. `scripts/gerar-chave-ssh.ps1`: gera chave ED25519 parametrizada.
4. `scripts/testar-conexao-remota.ps1`: testa conectividade com `github`, `gitlab` ou ambos.
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
