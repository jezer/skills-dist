---
name: maintain-filesystem
description: Manter regras de pastas, arquivos e repositorios do workspace C:\codes. Use quando Codex precisar revisar root, file_system, regras_file_system, estrutura de empresas, .gitignore da raiz, personalizado.md, template.personalizado.md, ou organizacao de repositorios em C:\codes.
---

# Manter File System

## Objetivo

Manter a organizacao de pastas, arquivos e repositorios do workspace `C:\codes`.

## Alias

1. Esta skill tambem atende pelo texto `manter_file_system`.
2. `root` significa `C:\codes\AGENTS.md`.
3. `file_system` e `regras_file_system` significam `C:\codes\pv\regras_file_system`.

## Fluxo

1. Ler `C:\codes\AGENTS.md`.
2. Ler `C:\codes\pv\regras_file_system\AGENTS.md`.
3. Conferir `.gitignore` da raiz quando a tarefa envolver Git da raiz.
4. Conferir `template.personalizado.md` e `personalizado.md` quando a tarefa envolver configuracao local.
5. Nao alterar repositorios de empresas sem pedido explicito.
6. Quando a mudanca afetar outro contexto, registrar pedido no `plan` do contexto dono antes de implementar.

## Limites

1. Nao mover projetos entre empresas sem pedido explicito.
2. Nao criar `AGENTS.md` em empresa ou projeto sem regra especifica.
3. Nao duplicar regras que ja estejam em `C:\codes\AGENTS.md`, `skills/AGENTS.md` ou `pv/regras_file_system/AGENTS.md`.
4. Nao criar tool especifica em `C:\codes\tools` sem plano aprovado no contexto tools.

## Regras

1. A raiz `C:\codes` e repositorio Git guarda-chuva.
2. O Git da raiz ignora todas as subpastas diretas.
3. `personalizado.md` e local e ignorado pelo Git.
4. `template.personalizado.md` e modelo versionado.
5. `pv`, `syg`, `cnu`, `theo` e `elohim` sao pastas de empresas.
6. Projetos dentro das empresas devem ser repositorios proprios quando aplicavel.
7. `C:\codes\skills` e repositorio proprio das skills reais.
8. `C:\codes\tools` e o contexto existente para tools globais aprovadas.
9. Tools guardam artefatos de apoio; skills continuam em `C:\codes\skills`.

## Saida esperada

1. Estrutura de pastas coerente com `pv/regras_file_system`.
2. Mudancas limitadas ao escopo solicitado.
3. Nenhum arquivo global acumulativo criado sem regra explicita.


## Correlacao Obrigatoria de Skills

1. Antes de qualquer mudanca persistente, executar `route-skills-by-context`.
2. Registrar na sessao ativa:
- skill executora
- skills de apoio
- motivo da escolha
- validacao da escolha
3. Sem esse registro, manter atividade como `bloqueado`.
