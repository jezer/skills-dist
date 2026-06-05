# Reuniao de Argumentos - Skill de Teste Unitario SYG

- Data: 2026-05-17
- Objetivo: consolidar argumentos tecnicos para uma skill especializada em testes unitarios na SYG.
- Fontes avaliadas:
  - `C:\codes\syg\rebates\tests`
  - `C:\codes\syg\latam_liberty_mkt_coe\test`

## Pontos convergentes

1. Ambos os projetos usam Python e mocks intensivos para isolamento de dependencias externas.
2. Ambos dependem de contexto AWS/Glue (`awsglue`, `boto3`, `lib.*`) e precisam de bootstrap de import para testes rodarem fora da infraestrutura AWS.
3. O foco dos testes e comportamento:
   - caminho feliz,
   - falha controlada,
   - manutencao de contrato de entrada/saida.

## Diferencas relevantes

1. Estrutura de pasta:
   - `rebates`: `tests/`
   - `latam_liberty_mkt_coe`: `test/`
2. `latam_liberty_mkt_coe` possui casos mais extensos com `unittest.TestCase` e cenarios de execucao completa.
3. `rebates` esta mais orientado a `pytest` com foco incremental em modulos especificos.

## Argumentos para a nova skill

1. Padrao unico reduz retrabalho ao criar fixtures/stubs para Glue e AWS.
2. Guia de regressao padroniza cobertura minima em jobs e validadores.
3. Padrao de execucao por `python -m pytest` reduz dependencia de instalacoes parciais.
4. Orientacao unica para `tests/` e `test/` evita friccao entre projetos SYG.

## Escopo da skill

1. Definir checklist minimo para testes unitarios em SYG.
2. Definir estrategia de mock/stub para dependencias externas.
3. Definir padrao de nomenclatura, organizacao e asserts.
4. Oferecer script simples para execucao de pytest com caminho opcional.

## Limites da skill

1. Nao substituir skill de negocio.
2. Nao impor mudancas estruturais massivas em suites legadas.
3. Nao executar fluxo de CI/CD; apenas orientar e apoiar implementacao local.
