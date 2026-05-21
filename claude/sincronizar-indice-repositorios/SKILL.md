---
name: sincronizar-indice-repositorios
description: Atualizar e validar indices de repositorios do root em C:\codes por maquina/usuario. Use quando houver novo projeto/empresa, divergencia entre estado local e indice, ou necessidade de regenerar C:\codes\indice-repositorios-root-jf.* ou C:\codes\indice-repositorios-root-jz.*.
---

# Sincronizar Indice de Repositorios

## Objetivo

Manter o indice de repositorios do root consistente com o estado local da maquina atual, separado por usuario/maquina (`jf` ou `jz`).

## Uso

1. Usar quando houver nova empresa, novo projeto ou mudanca de repositorio.
2. Usar para regenerar os arquivos `C:\codes\indice-repositorios-root-{usuario}.json` e `C:\codes\indice-repositorios-root-{usuario}.md`, onde `{usuario}` vem de `C:\codes\personalizado.md`.
3. Usar para validar se o indice local esta atualizado.
4. Usar para manter todos os projetos visiveis no indice, inclusive repositorios Git, diretorios de suporte e itens `sem-git` com justificativa.
5. Usar para observar o indice da outra maquina quando o arquivo estiver disponivel localmente por sincronizacao.

## Limites

1. Nao executa clone/push por conta propria.
2. Nao substitui `manter-git` para operacoes Git executivas.
3. Nao altera arquivos fora do escopo do indice root.
4. Nao escreve o indice de outro usuario: a maquina `jf` escreve apenas `indice-repositorios-root-jf.*`; a maquina `jz` escreve apenas `indice-repositorios-root-jz.*`.
5. Nao exige que o indice da outra maquina exista antes da primeira sincronizacao.

## Fluxo

1. Ler `C:\codes\AGENTS.md`.
2. Ler `C:\codes\personalizado.md` para identificar o usuario atual (`jf` ou `jz`).
3. Executar `scripts\gerar-indice-local.ps1` para reconstruir o indice local com nome por usuario.
4. Executar `scripts\validar-indice-local.ps1` para validar consistencia do indice do usuario atual.
4. Executar `scripts\resumo-sincronizacao.ps1` para resumo final da sessao.
5. Registrar no chamado os resultados: usuario do indice, arquivo gerado, `indice_atualizado`, pendencias e itens nao sincronizaveis.
6. Quando o indice do outro usuario existir, comparar por observacao para identificar projetos ou repositorios que existem na outra maquina e ainda nao existem localmente.

## Scripts

1. `scripts/gerar-indice-local.ps1`: gera JSON e Markdown do indice root.
2. `scripts/validar-indice-local.ps1`: valida aderencia do indice ao estado local.
3. `scripts/resumo-sincronizacao.ps1`: consolida resumo objetivo da sincronizacao.
