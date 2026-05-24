---
name: semaforo-container-partner-pattern
description: Define o padrao de estrutura para implantar o cabecalho Semaforo em containers de projeto (especialmente CNU), com pastas x.semaforo_cabecalho, x.scripts e x.parameters e uso de %run relativo.
---

# Semaforo Container Partner Pattern

## Objetivo

Padronizar a estrutura de containers que recebem o cabecalho Semaforo para evitar divergencia de pastas, notebooks e instrucoes de uso.

## Uso

1. Usar antes de criar ou atualizar pacote de cabecalho em qualquer container.
2. Criar a raiz do pacote como `x.semaforo_cabecalho`.
3. Colocar scripts e artefatos em `x.semaforo_cabecalho/x.scripts`.
4. Colocar notebooks de loader/admin no mesmo diretorio `x.semaforo_cabecalho/x.parameters`.
5. Garantir referencia relativa de uso no notebook consumidor:
- `MAGIC %run "../x.Parameters/x.cabecalho.v3.delta"`
6. Incluir guia de implantacao manual no pacote com passos de upload de parquet e execucao do admin.

## Limites

1. Nao usar `x.tools/semaforo_cabecalho` para pacote novo.
2. Nao separar notebooks entre `x.admin` e `x.Parameters` quando este padrao estiver ativo; consolidar em `x.parameters`.
3. Nao publicar pacote sem parquet pronto para upload manual.
4. Nao entregar sem instrucoes de `%run` relativo no guia.

## Checklist minimo

1. Estrutura presente:
- `x.semaforo_cabecalho/x.scripts`
- `x.semaforo_cabecalho/x.scripts/output/*.parquet`
- `x.semaforo_cabecalho/x.parameters/x.cabecalho.v3.delta.py`
- `x.semaforo_cabecalho/x.parameters/x.admin.popular-tabela-cabecalho.py`
2. Guia de implantacao atualizado.
3. Commit realizado no repositorio do container.
