---
name: sci-content-flow
description: "Manage the SCI artifact lifecycle in the workspace: draft creation, IA-based topic classification with confidence percentage, plan-before-execute confirmation panel, contextual publishing, 12h auto-publish job, context correction alert, comment emotion classification, and quality score calculation. Use when implementing or operating any artifact flow in C:\\codes\\tools\\artifact-engine or C:\\codes\\tools\\all_IA."
---

# SCI Content Flow

## Objetivo

Implementar e operar o ciclo de vida de artefatos do Sistema de Comunicacao Contextual Inteligente (SCI): desde a criacao em rascunho no roteador principal ate a publicacao confirmada no topico correto, passando pela classificacao por IA, correcao de contexto e calculo de quality score.

## Uso

1. Usar para implementar `POST /artifacts/draft`: recebe texto/arquivo, chama `ia-gateway-specialist` para classificar topicos candidatos com `confianca_pct`, grava `artifact_classification` com status `pendente` e `auto_publicar_em = now + 12h`.
2. Usar para implementar `POST /artifacts/suggest`: classificacao leve e rapida (< 1s) para sugestao em tempo real enquanto o usuario digita (debounce 500ms, texto >= 10 chars).
3. Usar para implementar `POST /artifacts/publish` (Fluxo 1): usuario confirma topico; `artifact_classification.status = confirmado`.
4. Usar para implementar `POST /artifacts/auto-publish-pending` (Fluxo 2): job que publica artefatos com `auto_publicar_em <= now`; status = `auto_publicado`.
5. Usar para implementar alerta de correcao de contexto (Fluxo 3): quando `confianca_pct >= 85%` para topico diferente do atual, retornar `{"alerta": true}` sem publicar.
6. Usar para implementar classificacao de emocao em comentarios: prompt curto para `ia-gateway-specialist`; mapear para `elogio|sugestao|critica|duvida|ataque`.
7. Usar para implementar calculo de `quality_score`: registrar eventos em `artifact_quality_log`, recalcular com pesos de `docs/quality_weights.yml`.
8. Usar para implementar o componente `plan_panel.html` (plan-before-execute): painel que exibe acoes planejadas, perguntas pendentes e consequencias antes de habilitar execucao.

## Limites

1. Nao substitui `ia-gateway-specialist` para logica de roteamento de provedores de IA.
2. Nao substitui `fastapi-specialist` para estrutura da API FastAPI.
3. Nao gerencia autenticacao nem permissoes; delega para `auth` e `permissions`.
4. Nao renderiza layouts; limita-se ao ciclo de vida do artefato (dados e logica).
5. Nao executa auto-publicacao sem job ou endpoint acionado; nao roda em background sem configuracao explicita.
6. Nao publica artefato sem validar permissao do usuario no topico.

## Fluxos do SCI

| Fluxo | Gatilho | Resultado |
|---|---|---|
| 1 - Publicacao com confirmacao | Usuario confirma topico | `artifact_classification.status = confirmado` |
| 2 - Auto-publicacao 12h | Job: `auto_publicar_em <= now` | `status = auto_publicado`; notificacao enviada |
| 3 - Correcao de contexto | `confianca_pct >= 85%` para outro topico | `{"alerta": true}`; nao publica ate usuario decidir |

## Plan-before-execute obrigatorio

As seguintes acoes exigem painel de plano antes de executar:

- Publicar artefato (topico, canal, visibilidade)
- Resetar limite de IA
- Alterar permissao de topico
- Alterar labels de hierarquia
- Sincronizar chamados abertos
- Desativar nivel 3 da hierarquia

O botao de execucao so habilita quando todas as perguntas do painel forem respondidas.

## Dependencias operacionais

1. `ia-gateway-specialist` para classificacao de topico e emocao.
2. `fastapi-specialist` para endpoints da API.
3. `alembic-db-specialist` para modelos e migrations do SCI.
4. `automated-test-builder` para suites de teste dos fluxos SCI.
5. `maintain-activities` para status e evidencia.

## Correlacao Obrigatoria de Skills

1. Antes de qualquer mudanca persistente, executar `route-skills-by-context`.
2. Registrar na sessao ativa: skill executora, skills de apoio, motivo da escolha.
3. Sem esse registro, manter atividade como `bloqueado`.
