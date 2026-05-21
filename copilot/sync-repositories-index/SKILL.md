---
name: sync-repositories-index
description: "Atualizar e validar o indice de repositorios do root em C:\\codes. Use quando houver novo projeto/empresa, divergencia entre estado local e indice, ou necessidade de regenerar os arquivos por maquina (ex.: C:\\codes\\indice-repositorios-root-jz.json e .md)."
---

# Sincronizar Indice de Repositorios

## Objetivo

Manter o indice de repositorios do root consistente com o estado local da maquina atual.

## Uso

1. Usar quando houver nova empresa, novo projeto ou mudanca de repositorio.
2. Usar para regenerar os arquivos por maquina `C:\codes\indice-repositorios-root-<usuario>.json` e `C:\codes\indice-repositorios-root-<usuario>.md`, com `<usuario>` lido de `C:\codes\personalizado.md` (ex.: `jz`, `jf`).
3. Usar para validar se o indice local esta atualizado.
4. Sempre incluir o repositorio raiz `C:\codes` no indice como entrada do contexto `root`.

## Limites

1. Nao executa clone/push por conta propria.
2. Nao substitui `maintain-git` para operacoes Git executivas.
3. Nao altera arquivos fora do escopo do indice root.

## Fluxo

1. Ler `C:\codes\AGENTS.md`.
2. Executar `scripts\gerar-indice-local.ps1` para reconstruir o indice local.
3. Executar `scripts\validar-indice-local.ps1` para validar consistencia.
4. Executar `scripts\resumo-sincronizacao.ps1` para resumo final da sessao.
5. Registrar no chamado os resultados: `indice_atualizado`, pendencias e itens nao sincronizaveis.

## Scripts

1. `scripts/gerar-indice-local.ps1`: gera JSON e Markdown do indice root.
2. `scripts/validar-indice-local.ps1`: valida aderencia do indice ao estado local.
3. `scripts/resumo-sincronizacao.ps1`: consolida resumo objetivo da sincronizacao.


## Correlacao Obrigatoria de Skills

1. Antes de qualquer mudanca persistente, executar `route-skills-by-context`.
2. Registrar na sessao ativa:
- skill executora
- skills de apoio
- motivo da escolha
- validacao da escolha
3. Sem esse registro, manter atividade como `bloqueado`.
