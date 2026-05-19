---
name: syg-unit-test-specialist
description: Especialista em testes unitarios Python para projetos da empresa SYG (especialmente Glue jobs, validadores e modulos de workflow). Usar quando criar, revisar, ampliar ou padronizar testes em pastas `tests/` ou `test/`, quando houver necessidade de mock de dependencias AWS/awsglue/lib, quando for preciso reduzir regressao com cobertura de cenarios de erro e sucesso, ou quando for integrar execucao de pytest ao fluxo do repositorio.
---

# Especialista Teste Unitario Syg

## Objetivo

Padronizar a criacao e manutencao de testes unitarios nos repositorios SYG com foco em nao regressao, isolamento de dependencias externas e clareza de cenarios.

## Uso

1. Usar quando o pedido envolver criar ou revisar testes unitarios em Python nos projetos SYG.
2. Usar quando houver Glue jobs com import de `awsglue`, `boto3` ou `lib.*` e o teste precisar de stubs/mocks para import seguro.
3. Usar quando houver validadores/transformacoes de dados e for necessario cobrir regras de contrato, erros e retrocompatibilidade.
4. Ler `references/reuniao-argumentos-testes-syg.md` antes de propor padrao de testes para um projeto SYG novo.

## Limites

1. Nao substitui skill dona de negocio (ex.: planejamento, atividades, git, workflows).
2. Nao executa alteracoes produtivas em Glue/Redshift sem plano e atividade aprovados.
3. Nao exige bloqueio imediato de legado; prioriza transicao incremental com coexistencia.
4. Nao publica commit/push sem solicitacao explicita.

## Fluxo recomendado

1. Identificar modulo alvo e contrato esperado (entrada, saida, efeitos colaterais).
2. Definir cenarios minimos:
   - caminho feliz,
   - validacao de erro esperado,
   - regressao critica do dominio.
3. Isolar dependencias externas com `patch`, `MagicMock` ou stubs de modulo.
4. Evitar acesso real a AWS/rede em testes unitarios.
5. Manter testes curtos, deterministas e com asserts explicitos.
6. Executar pytest localmente com `scripts/executar-pytest-syg.ps1` quando disponivel.

## Padroes SYG

1. Aceitar estrutura `tests/` (rebates) e `test/` (latam_liberty_mkt_coe) sem forcar migracao imediata.
2. Preservar fixtures de bootstrap de import para `awsglue`/`lib.*` quando o job depende desses pacotes.
3. Em Glue jobs, testar:
   - inicializacao com argumentos,
   - tratamento de retorno vazio,
   - tratamento de excecoes por fonte/tabela,
   - comportamento de escrita/nao escrita conforme volume.

## Dependencias operacionais

1. `python-specialist` para apoio tecnico de linguagem.
2. `maintain-activities` para refletir criacao/revisao de testes no plano ativo.
3. `maintain-git` para commit/push/sync do repositorio dono.

## Scripts

1. `scripts/executar-pytest-syg.ps1`: executa pytest via `python -m pytest`, com caminho de teste opcional.

## Referencias

1. `references/reuniao-argumentos-testes-syg.md`: comparativo dos padroes observados em `rebates` e `latam_liberty_mkt_coe`.
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
