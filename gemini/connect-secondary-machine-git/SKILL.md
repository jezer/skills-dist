---
name: connect-secondary-machine-git
description: Configurar conectividade Git em segunda maquina Windows reaproveitando chave SSH padrao de forma segura e parametrizavel. Use quando a segunda maquina nao consegue autenticar no GitHub/GitLab.
---

# Conectar Segunda Maquina Git

## Objetivo

Padronizar a configuracao de Git/SSH em segunda maquina para restaurar conectividade com GitHub/GitLab.

## Uso

1. Usar quando a segunda maquina falhar em `pull/push` por autenticacao.
2. Usar para copiar chave SSH de origem confiavel para perfil local.
3. Usar para validar fingerprint e conectividade remota apos configuracao.

## Limites

1. Nao versionar chave privada em repositÃ³rio.
2. Nao enviar chave para ambiente nao confiavel.
3. Nao executar push automaticamente.

## Fluxo

1. Executar `scripts/copiar-chave-segundamaquina.ps1`.
2. Executar `scripts/configurar-ssh-segundamaquina.ps1`.
3. Executar `scripts/validar-segundamaquina.ps1`.
4. Registrar no chamado evidencias de conectividade por host.

## Scripts

1. `scripts/copiar-chave-segundamaquina.ps1`: copia chave privada/publica para `~/.ssh`.
2. `scripts/configurar-ssh-segundamaquina.ps1`: configura ssh-agent + Git OpenSSH + `ssh-add`.
3. `scripts/validar-segundamaquina.ps1`: valida fingerprint e testa conexao com GitHub/GitLab.
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
