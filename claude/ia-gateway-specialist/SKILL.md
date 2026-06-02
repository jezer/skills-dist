---
name: ia-gateway-specialist
description: Operate and maintain the ia-gateway module. Use when configuring IA providers, defining routing rules by subject/skill/complexity, managing usage limits, implementing subprocess CLI callers, tracking costs or analysing the IA routing index.
---

# IA Gateway Specialist

## Objetivo

Operar e manter o modulo de roteamento de IAs: configurar provedores, definir regras
de selecao por assunto/skill/complexidade, gerenciar limites, rastrear custos e
implementar chamadas a CLIs de IA via subprocess.

## Quando usar

1. Configurar provedores (`ia_provider`): limite, custo, status ativo.
2. Definir prioridade de IA por assunto (`ia_priority_by_subject`) e por skill/complexidade.
3. Implementar ou ajustar logica de roteamento com fallback automatico.
4. Adicionar novo provedor: adapter subprocess, seed, registro no indice.
5. Implementar `scripts/verify_ia_connections.py` (gate de Fase 0).
6. Implementar suite `ia_install` em `test_aut/suites/ia-gateway/`.
7. Apoiar `sci-content-flow` quando classificacao de topico precisar rotear para IA.

## Limites

1. Nao armazena conteudo dos prompts alem do log tecnico (`request_log`).
2. Nao gerencia usuarios, sessoes nem permissoes.
3. Nao decide em qual topico um artefato pertence — isso e `sci-content-flow`.
4. Nao altera chaves de API no banco; chaves ficam no `.env`.

## Decisao de projeto: CLI via subprocess (sem API key)

Este workspace usa CLIs de IA OAuth instaladas localmente, nao API keys pagas.
A chamada e feita via `subprocess.run` e o resultado capturado como texto.

**Vantagem:** sem custo, sem chave, sem limite de tokens.  
**Limitacao:** depende de CLI instalada e autenticada no sistema.

### Implementacao padrao — ia_caller.py

```python
import subprocess
import shutil

# Mapa de CLIs suportadas: provider_name -> [binario, ...flags_antes_do_prompt]
PROVIDERS_CLI: dict[str, list[str]] = {
    "Gemini":   ["gemini",   "-p"],
    "Claude":   ["claude",   "-p"],
    "Aider":    ["aider",    "--message", "--no-git", "--yes"],
    "Goose":    ["goose",    "run"],
    "OpenCode": ["opencode"],
    "Amp":      ["amp"],
    "Crush":    ["crush"],
    "Kilo":     ["kilo"],
    "Continue": ["cn", "chat"],
}

def call_ia(texto: str, provider_name: str, timeout: int = 60) -> dict:
    cmd_template = PROVIDERS_CLI.get(provider_name)
    if not cmd_template:
        raise ValueError(f"CLI nao configurada para: {provider_name}")

    binario = cmd_template[0]
    if not shutil.which(binario):
        raise RuntimeError(f"CLI '{binario}' nao encontrada no PATH. Instalar e autenticar.")

    cmd = cmd_template + [texto]
    result = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout)
    if result.returncode != 0:
        raise RuntimeError(result.stderr.strip() or f"{binario} retornou exit {result.returncode}")

    return {
        "resposta": result.stdout.strip(),
        "tokens_estimados": max(1, len(texto) // 4),
    }
```

### Regras de elegibilidade de IA

1. IA elegivel: `ativo == True` E `limite_atual < limite_total`.
2. Complexidade `baixa` sem skill especifica: prefere IA de menor custo elegivel.
3. Complexidade `media` ou `alta`: usa ordem de `ia_priority_by_skill` para a skill/faixa.
4. IA indisponivel ou sem limite: tenta a proxima na ordem configurada.
5. Nenhuma IA elegivel: retorna `{"error": "nenhuma_ia_disponivel"}`.
6. Motivo de fallback registrado sempre em `request_log.motivo_fallback`.

### Seed padrao de provedores

```python
# Gemini CLI: unica ativa por padrao (OAuth Google, 1000 req/dia free)
{"nome": "Gemini", "tipo_limite": "chamadas_dia", "limite_total": 1000, "ativo": True}

# Claude: inativo — exige Claude Pro $20/mes
{"nome": "Claude", "tipo_limite": "chamadas_dia", "limite_total": 100, "ativo": False}

# Codex/DeepSeek: inativos — exigem API key paga
{"nome": "Codex",    "tipo_limite": "tokens", "limite_total": 0, "ativo": False}
{"nome": "DeepSeek", "tipo_limite": "tokens", "limite_total": 0, "ativo": False}
```

### Tabela cli_provider_info

Registra metadados de todas as CLIs conhecidas (instaladas ou nao):
- `cli_binario`: nome do executavel (ex: `gemini`)
- `auth_tipo`: `oauth` | `api_key` | `byok` | `credito`
- `plano_free_limite_diario`: requests/dia no tier gratuito
- `plano_pago_usd_mes`: custo mensal do plano basico pago
- `instalado`: atualizado por `POST /context/verify-clis` via `shutil.which()`

### Prioridade por assunto (seed inicial)

| Assunto | Ordem |
|---|---|
| plano | Gemini, Codex, Claude, DeepSeek |
| atividades | DeepSeek, Codex, Gemini, Claude |
| desenvolvimento | Claude, Codex, DeepSeek, Gemini |
| revisao | Codex, Claude, Gemini, DeepSeek |

### Verificacao de conexoes (gate obrigatorio Fase 0)

```python
# scripts/verify_ia_connections.py
# Envia "ping" para cada provedor ativo no banco
# Retorna: provedor | status | latencia_ms
# Exit 0 se pelo menos 1 provedor respondeu
# Exit 1 se todos falharam
```

Executar antes de qualquer fase que dependa de IA:
```powershell
cd backend && python scripts/verify_ia_connections.py
```

## Dependencias operacionais

1. `fastapi-specialist` para estrutura da API do modulo.
2. `alembic-db-specialist` para modelos e migrations.
3. `python-specialist` para subprocess, encoding e logica geral.
4. `automated-test-builder` para suites `ia_install` e `ia_smart`.
5. `maintain-activities` para status e evidencia.
