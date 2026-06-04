---
name: python-specialist
description: Create, review and maintain Python scripts and modules in the workspace with focus on quality, encoding safety, subprocess patterns and reuse. Use when the activity requires Python scripting beyond what a domain skill covers.
metadata:
  camada: ferramenta
  escopo_negativo:
    - nao resolve atividade especifica de empresa (orientar criacao de skill de atividade)
    - nao decide arquitetura de projeto
    - nao executa operacoes git (maintain-git)
  saidas:
    - codigo python idiomatico
    - scripts argparse parametrizados e idempotentes
---

# Python Specialist

## Objetivo

Projetar e manter scripts e modulos Python confiaveis, seguros e reaproveitaveis
para automacoes e servicos do workspace.

## Quando usar

1. Script Python novo ou manutencao de script existente fora de escopo de skill de dominio.
2. Revisar argumentos CLI, validacao de entrada, tratamento de excecoes, logs.
3. Resolucao de problemas de encoding, subprocess, paths ou IO.
4. Apoio tecnico de linguagem para skills donas de dominio.

## Limites

1. Nao substitui a skill dona do dominio da atividade.
2. Nao altera contexto externo sem plano/atividade correspondente.
3. Nao publica mudancas em Git sem solicitacao explicita.
4. Fora do proposito desta skill, devolver ao `route-skills-by-context` (nao improvisar).

## Padroes obrigatorios

### Encoding de arquivos — UTF-8-sig para JSON do PowerShell

PowerShell gera arquivos com UTF-8 BOM (`\xef\xbb\xbf`). Usar sempre `utf-8-sig`
em leituras de JSON ou texto do workspace:

```python
import json
from pathlib import Path

# CORRETO — funciona com e sem BOM
data = json.loads(Path(r"C:\codes\indice-repositorios-root-jz.json").read_text(encoding="utf-8-sig"))

# ERRADO — falha com BOM (json.JSONDecodeError: Unexpected UTF-8 BOM)
data = json.loads(Path("arquivo.json").read_text(encoding="utf-8"))
```

Regra simples: **sempre `utf-8-sig`** em leituras de JSON no workspace Windows.
O `utf-8-sig` funciona igualmente para arquivos sem BOM.

### Subprocess CLI — padrão de chamada

```python
import subprocess
import shutil

def call_cli(binario: str, args: list[str], timeout: int = 60) -> str:
    if not shutil.which(binario):
        raise RuntimeError(f"CLI '{binario}' nao encontrada no PATH. Verificar instalacao.")
    result = subprocess.run(
        [binario] + args,
        capture_output=True,
        text=True,
        timeout=timeout,
    )
    if result.returncode != 0:
        raise RuntimeError(result.stderr.strip() or f"{binario} retornou exit {result.returncode}")
    return result.stdout.strip()

# Exemplo:
resposta = call_cli("gemini", ["-p", "Explique o que e Python"])
```

**Checklist para subprocess:**
- Verificar com `shutil.which()` antes de chamar — nunca assumir que o binario existe
- Sempre `capture_output=True` para nao poluir stdout/stderr do processo pai
- Sempre `text=True` para string em vez de bytes
- Sempre definir `timeout` — CLIs de IA podem travar
- Tratar `returncode != 0` como erro explicito

### Paths no Windows

```python
from pathlib import Path

# CORRETO — Path trata \ e / uniformemente no Windows
workspace = Path(r"C:\codes")
index_file = workspace / "plan" / "indice-planos-jz.json"

# Verificar existencia antes de abrir
if not index_file.exists():
    return {"upserted": 0, "sem_alteracao": 0}

# EVITAR — hardcode de separador
path = "C:\\codes\\plan\\indice.json"  # evitavel
```

### Otimizacao de imagens com Pillow

```python
from PIL import Image

def otimizar_para_webp(origem: str, destino: str, max_dim: int = 256, quality: int = 90) -> int:
    """Converte PNG/JPG para WebP redimensionado. Retorna tamanho final em bytes."""
    img = Image.open(origem)
    img.thumbnail((max_dim, max_dim), Image.LANCZOS)
    img.save(destino, "WEBP", quality=quality, method=6)
    return Path(destino).stat().st_size

# PNG 851KB -> WebP ~5KB: reducao de 99%
tamanho = otimizar_para_webp("logo.png", "logo.webp", max_dim=256)
```

Instalar: `pip install pillow`

### Upsert idemportente — padrao SQLAlchemy

```python
def upsert(db: Session, model, unique_filters: dict, defaults: dict = None) -> tuple:
    """Retorna (row, created: bool). Nunca duplica."""
    row = db.query(model).filter_by(**unique_filters).one_or_none()
    if row is None:
        row = model(**unique_filters, **(defaults or {}))
        db.add(row)
        return row, True
    return row, False

# Uso:
row, criado = upsert(db, ProjectTree, {"empresa": "pv", "projeto": "semaforo"}, {"ativo": True})
```

### Leitura de frontmatter YAML em Markdown

```python
import re
from pathlib import Path

_FM_RE = re.compile(r'^---\s*\n(.*?)\n---', re.DOTALL)
_FIELD_RE = re.compile(r'^(\w[\w-]*):\s*(.+)$', re.MULTILINE)

def parse_skill_md(path: Path) -> dict[str, str]:
    try:
        text = path.read_text(encoding="utf-8-sig", errors="ignore")
    except OSError:
        return {}
    m = _FM_RE.match(text)
    if not m:
        return {}
    return {k.strip(): v.strip().strip('"').strip("'") for k, v in _FIELD_RE.findall(m.group(1))}

# Uso:
fields = parse_skill_md(Path(r"C:\codes\skills\dist\claude\fastapi-specialist\SKILL.md"))
# {"name": "fastapi-specialist", "description": "..."}
```

## Dependencias operacionais

1. `maintain-skills` para revisao da skill.
2. `maintain-automations` para padronizacao de scripts parametrizados.
3. `maintain-activities` para status e evidencia.
4. `frontend-assets-specialist` para otimizacao de imagens com Pillow.

## Scripts

1. `scripts/testar-script.ps1`: executa um script Python alvo com argumentos.
