---
name: ia-gateway-specialist
description: Operate and maintain the ia-gateway module in C:\codes\tools\ia-gateway. Use when the activity requires configuring IA providers, defining routing rules by subject/skill/complexity, managing usage limits, tracking costs, implementing fallback logic, or analyzing the IA routing index for workspace modules.
---

# IA Gateway Specialist

## Objetivo

Operar e manter o modulo `ia-gateway` (`C:\codes\tools\ia-gateway`): configurar provedores de IA, definir regras de roteamento por assunto/skill/complexidade, gerenciar limites, rastrear custos e implementar fallback automatico.

## Uso

1. Usar para configurar provedores (`ia_provider`): chave de API, limite total, custo por 1k tokens, status ativo.
2. Usar para definir prioridade de IA por assunto (`ia_priority_by_subject`) e por skill/complexidade (`ia_priority_by_skill`).
3. Usar para implementar ou ajustar a logica de roteamento: selecao por menor custo (tarefas simples) vs. prioridade configurada (tarefas complexas).
4. Usar para implementar fallback: quando IA prioritaria esta indisponivel ou sem limite, tenta a proxima elegivel na ordem.
5. Usar para gerenciar limites: verificar `limite_atual < limite_total`, resetar via endpoint admin.
6. Usar para analisar `ia_skill_usage_stats` e ajustar prioridades com base em historico real de custo/beneficio.
7. Usar para adicionar novo provedor de IA: adapter, seed, registro no indice.
8. Usar para implementar `scripts/verify_ia_connections.py`: script que envia "ping" para cada provedor configurado no `.env` e retorna status/latencia/custo; usado como gate obrigatorio da Fase 0 antes de qualquer desenvolvimento de UI.
9. Usar para implementar e manter a suite `ia_install` em `test_aut/suites/ia-gateway/`: cenarios parametrizados por provedor, cenarios de fallback, cenarios de prioridade adaptativa (C6).
10. Usar como skill de apoio para `sci-content-flow` quando a classificacao de topico ou emocao precisar rotear para a IA mais adequada.

## Limites

1. Nao armazena conteudo dos prompts alem do log tecnico (`request_log`).
2. Nao gerencia usuarios, sessoes nem permissoes; limita-se ao roteamento de IAs.
3. Nao decide em qual topico um artefato pertence; isso e de `sci-content-flow`.
4. Nao executa mudanca persistente em `ia_provider` sem plano e atividade correspondente.
5. Nao altera chaves de API diretamente no banco; chaves ficam apenas no `.env`.

## Regras de elegibilidade de IA

1. IA elegivel: `ativo == True` E `limite_atual < limite_total`.
2. Tarefas com complexidade `baixa` sem skill especifica: prefere IA de menor `custo_por_1k_tokens_usd` elegivel.
3. Tarefas com complexidade `media` ou `alta`: usa ordem configurada em `ia_priority_by_skill` para a skill/faixa.
4. Quando nenhuma IA esta elegivel: retorna erro controlado `{"error": "nenhuma_ia_disponivel"}`.
5. Motivo de fallback deve sempre ser registrado em `request_log.motivo_fallback`.

## Provedor padrao por assunto (seed inicial)

| Assunto | Ordem |
|---|---|
| plano | Gemini, Codex, Claude, DeepSeek |
| atividades | DeepSeek, Codex, Gemini, Claude |
| desenvolvimento | Claude, Codex, DeepSeek, Gemini |
| revisao | Codex, Claude, Gemini, DeepSeek |

## Dependencias operacionais

1. `fastapi-specialist` para estrutura da API do modulo.
2. `alembic-db-specialist` para modelos e migrations.
3. `python-specialist` para adapters e logica de roteamento.
4. `maintain-activities` para status e evidencia.

## Correlacao Obrigatoria de Skills

1. Antes de qualquer mudanca persistente, executar `route-skills-by-context`.
2. Registrar na sessao ativa: skill executora, skills de apoio, motivo da escolha.
3. Sem esse registro, manter atividade como `bloqueado`.
