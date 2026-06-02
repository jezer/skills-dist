---
name: frontend-assets-specialist
description: Manages frontend assets (images, icons, fonts, favicons) with correct optimization, format selection and delivery strategy. Use when adding, optimizing or organizing static assets for any web project in the workspace.
---

# Frontend Assets Specialist

## Objetivo

Garantir que todos os assets visuais (imagens, icones, fontes, favicons) sejam entregues
com o formato correto, tamanho minimo e a estrategia de carregamento adequada.

## Quando usar

- Ao adicionar logos, icones, imagens de fundo ou fotografias a um projeto web.
- Ao receber imagens geradas por IA (ChatGPT, Midjourney) para uso em UI.
- Ao revisar performance de assets estaticos no projeto.
- Ao configurar favicon, PWA manifest ou apple-touch-icon.

## Decisao de formato

| Caso de uso | Formato preferido | Alternativa |
|---|---|---|
| Logo vetorial / icone | SVG inline ou SVG externo | WebP |
| Logo raster (PNG gerado por IA) | WebP otimizado | PNG comprimido |
| Fotografia, hero, background complexo | WebP | JPEG progressive |
| Pattern decorativo, textura | WebP | PNG |
| Favicon | ICO (16+32px embutido) | PNG 32x32 |
| PWA app icon | PNG 192px + 512px | WebP |
| Icones de interface (botoes, nav) | SVG inline no HTML | CSS mask-image |

## Regra de tamanho vs estrategia de entrega

| Tamanho do asset | Estrategia |
|---|---|
| < 2KB (icone simples) | Inline SVG no HTML ou base64 no CSS |
| 2KB – 10KB | Arquivo separado; pode usar base64 em CSS se for unico |
| > 10KB | SEMPRE arquivo separado; NUNCA base64 no CSS |
| > 100KB | Comprimir ate < 50KB antes de usar; revisar necessidade |

**Regra de ouro:** base64 no CSS so para assets < ~5KB que nao mudam e precisam
evitar uma requisicao HTTP extra (ex: icone SVG usado como `background-image`).
Para logos e backgrounds, sempre arquivo separado.

## Otimizacao com Python Pillow

```python
from PIL import Image

img = Image.open('logo.png')          # Abre o PNG original (pode ser 800KB+)
img.thumbnail((256, 256), Image.LANCZOS)  # Redimensiona mantendo aspect ratio
img.save('logo.webp', 'WEBP', quality=90, method=6)  # Salva WebP otimizado
# Resultado esperado: reducao de 95-99% no tamanho
```

Instalar: `pip install pillow`

## Pipeline obrigatorio para imagens novas

1. Receber o arquivo original (PNG, JPG etc.)
2. Identificar o uso: logo / background / icone / fotografia
3. Definir dimensao maxima necessaria (logo sidebar: 256px; logo retina: 512px)
4. Converter para WebP com Pillow (quality 75-90 conforme complexidade)
5. Salvar versao original na pasta `plan/assets/` ou `docs/assets/` (referencia)
6. Salvar versao otimizada em `frontend/static/assets/`
7. Usar `<picture>` com `<source type="image/webp">` + `<img>` fallback PNG

## Markup correto para logo (evita CLS)

```html
<!-- CORRETO: dimensoes explicitas previnem layout shift (CLS) -->
<picture>
  <source srcset="/static/assets/logo.webp" type="image/webp"/>
  <img src="/static/assets/logo.png"
       alt="Nome do produto"
       width="36" height="36"
       loading="eager"
       decoding="async"/>
</picture>

<!-- Imagem abaixo do fold: usar loading="lazy" -->
<picture>
  <source srcset="/static/assets/bg.webp" type="image/webp"/>
  <img src="/static/assets/bg.png" alt="" loading="lazy" decoding="async"
       width="800" height="600"/>
</picture>
```

## CSS background-image

```css
/* CORRETO: WebP como arquivo separado */
.empty-pattern {
  background: url('/static/assets/bg-pattern.webp') center/cover;
  opacity: .06;
}

/* ERRADO para imagens > 10KB: base64 no CSS incha o arquivo */
/* .empty-pattern { background: url("data:image/png;base64,iVBORw0K..."); } */

/* OK para icone < 2KB */
.icon-check {
  background: url("data:image/svg+xml,%3Csvg...%3E") center/contain no-repeat;
}
```

## Favicon

```html
<!-- No <head> de todos os templates -->
<link rel="icon" type="image/x-icon" href="/static/favicon.ico"/>
<!-- Opcional: Apple touch icon para iOS -->
<link rel="apple-touch-icon" href="/static/assets/logo-192.png"/>
```

Gerar favicon.ico com Pillow:
```python
img = Image.open('logo.png')
img.save('favicon.ico', format='ICO', sizes=[(16,16),(32,32)])
```

## Estrutura de pastas

```
frontend/static/
  favicon.ico              # Favicon (< 10KB, ICO com 16+32px)
  assets/
    logo.png               # Original de referencia (nao servido diretamente)
    logo.webp              # Versao otimizada 256px (< 10KB)
    logo-2x.webp           # Versao retina 512px (< 15KB)
    logo-192.png           # PWA icon (para manifest)
    bg-pattern.webp        # Background decorativo (< 15KB)
```

## Limites

- Nao substitui `fastapi-specialist` para configuracao de rotas de static files.
- Nao define paleta de cores ou UI — responsabilidade do designer / style.css.
- Nao gerencia CDN ou cache headers em producao — registrar pedido no plano se necessario.
- Nao inclui otimizacao de video ou audio.

## Dependencias operacionais

- `python-specialist` para scripts de conversao com Pillow.
- `fastapi-specialist` para montar StaticFiles e configurar rotas de favicon.
- `technical-writer` para documentar decisoes de assets no plano.
