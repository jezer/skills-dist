# Contrato Operacional - Parametrizacao Rebates

## Dominios

1. `meta_safra_2025.csv`
2. `meta_safra_2026.csv`
3. `super_safra.csv`
4. `parametrizacao_meta_safra.csv`
5. `parametrizacao_pfp.csv`

## Regras

1. Colunas novas entram como opcionais na fase inicial.
2. Mudanca de tipo deve usar estrategia de coexistencia.
3. Chaves de negocio devem permanecer estaveis por lote.
4. Validacao tecnica deve passar pelo script:
   - `C:\codes\syg\rebates\workflows\user_zone\validators\validate_parametrizacao_csv.py`

## Gate de evolucao

1. Plano e atividade atualizados antes da mudanca.
2. Teste unitario atualizado quando houver nova regra.
3. Commit e push obrigatorios apos bloco fechado.
