---
name: ux-navigation-specialist
description: Design and validate navigability and efficient user experience for workspace apps. Use when the activity requires defining navigation models, information architecture, UX heuristics, flow efficiency (clicks/latency), empty/loading/error states, accessibility and keyboard navigation, or acceptance criteria that an automated test (Playwright/test_aut) can verify.
---

# UX Navigation Specialist

## Objetivo

Definir e validar a **navegabilidade** e a **eficiencia da experiencia do usuario**
de aplicacoes do workspace: arquitetura de informacao, modelos de navegacao, fluxos
de menor atrito, estados obrigatorios e criterios de aceite verificaveis por teste
automatizado.

## Quando usar

1. Desenhar ou revisar a arquitetura de navegacao (sidebar, abas, drawer, breadcrumb, busca).
2. Reduzir atrito de fluxos: minimizar cliques, campos e esperas ate a acao-alvo.
3. Definir estados obrigatorios de UI: vazio, carregando, erro, sem permissao, sucesso.
4. Especificar acessibilidade basica: foco visivel, navegacao por teclado, alvos de toque.
5. Escrever criterios de aceite de UX que um teste (Playwright/`test_aut`) consiga validar.
6. Apoiar planos que exijam estrategia de experiencia eficiente por fases.

## Limites

1. Nao implementa CSS/JS final — isso e de `frontend-assets-specialist` e dos especialistas de frontend do projeto.
2. Nao define regra de negocio — apenas como o usuario navega/experimenta a regra existente.
3. Nao substitui `automated-test-builder`; entrega os criterios que ela transforma em teste.
4. Nao executa mudanca persistente sem plano e atividade.

## Principios de navegabilidade (heuristicas-base)

1. **Uma acao primaria por tela.** Cada tela tem um objetivo claro e um caminho obvio para ele.
2. **Contexto sempre visivel.** O usuario enxerga onde esta (empresa › projeto › chamado) sem rolar.
3. **Captura progressiva.** Pedir o minimo; revelar campos conforme o passo anterior e satisfeito (cascata).
4. **Regra dos 3 cliques / 3 campos.** Acao recorrente deve caber em ate ~3 interacoes a partir do estado limpo.
5. **Estado vazio util.** Tela sem dados orienta o proximo passo, nunca fica em branco.
6. **Feedback imediato.** Toda acao assincrona mostra loading; todo erro e inline e acionavel.
7. **Navegacao reversivel.** Voltar/cancelar sempre disponivel; nada destrutivo sem confirmacao.
8. **Busca antes de arvore.** Em listas grandes, oferecer busca/filtro antes de obrigar navegacao hierarquica.
9. **Persistencia de contexto.** Conversas/telas retornam ao ultimo estado do usuario.
10. **Responsivo por prioridade.** Mobile prioriza a area-alvo (chat/conteudo); navegacao vira drawer/sheet.
11. **Acessibilidade minima nao-negociavel.** Foco visivel, ordem de tab logica, alvo de toque >= 24px (WCAG 2.5.8), contraste AA.
12. **Latencia percebida.** Operacao < 1s sem spinner; 1-4s com spinner; > 4s com progresso/estimativa.

## Metricas de eficiencia (medir, nao adivinhar)

| Metrica | Alvo padrao |
|---|---|
| Cliques ate a acao-alvo (estado limpo) | <= 3 |
| Campos obrigatorios antes de enviar | minimo necessario; opcionais como tags |
| Tempo ate primeira interacao util (TTI percebido) | < 1s para shell; dados sob demanda |
| Sugestao em tempo real (debounce) | 300-500ms; resposta < 1s |
| Estados de UI cobertos | vazio, loading, erro, sem-permissao, sucesso |
| Overflow horizontal em qualquer viewport | zero |

## Modelo de navegacao (padrao do workspace)

- **AppShell**: Sidebar (contexto + navegacao) · Main (conteudo/chat) · RightPanel opcional (status/auditoria).
- **Topbar**: breadcrumb de contexto + acoes compactas.
- **Composer/acao fixa** no rodape da area principal.
- **Mobile**: sidebar e right panel viram drawer/sheet; main ocupa a tela.
- **Busca lateral** estilo mensageria para listas grandes (empresa/projeto/plano/chamado/conversa).

## Criterios de aceite verificaveis (entregar para o teste)

Escrever cada criterio de forma que vire assercao Playwright/`test_aut`:

- "Ao abrir `/`, com nenhum contexto, o estado vazio e visivel e o composer fica desabilitado."
- "Selecionar empresa habilita o select de projeto; selecionar projeto habilita o chamado."
- "Sem chamado selecionado, o botao Enviar permanece desabilitado."
- "Em viewport 320px nao ha overflow horizontal e a sidebar fica em drawer."
- "Acao assincrona mostra spinner; erro aparece inline e nao em alert()."
- "Foco navega por teclado na ordem: empresa -> projeto -> chamado -> texto -> enviar."

## Procedimento

1. Mapear a acao-alvo de cada tela e o caminho mais curto ate ela.
2. Aplicar as heuristicas e marcar violacoes (atrito, estado faltante, contexto oculto).
3. Definir o modelo de navegacao e os estados obrigatorios.
4. Traduzir cada decisao em criterio de aceite verificavel.
5. Encaminhar os criterios para `automated-test-builder` cobrir em `test_aut` (Playwright por viewport).
6. Registrar metricas-alvo e medir antes/depois.

## Dependencias operacionais

1. `automated-test-builder`: transforma criterios de UX em testes Playwright/`test_aut`.
2. `frontend-assets-specialist`: assets/otimizacao visual.
3. `sci-content-flow`: fluxos de conteudo do SCI quando a navegacao envolver artefatos.
4. `technical-writer`: redacao de guias de navegacao.
5. `maintain-planner` / `maintain-activities`: planejamento e status.
