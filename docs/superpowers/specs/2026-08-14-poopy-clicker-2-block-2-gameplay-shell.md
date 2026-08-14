# Poopy Clicker 2.0 — Bloco 2: Gameplay Shell e Arquitetura da Tela Principal

Data: 2026-08-14
Status: Aprovado (arquitetura estrutural do redesign)
Base filosófica: Bloco 1 (visão/identidade/UX)

---

## Arquitetura escolhida: C — Shell híbrido adaptativo

Header compacto + gameplay livre + dock inferior contextual + elementos flutuantes
apenas para informação temporária ou de gameplay.

Rejeitadas:
- A — HUD de barras tradicional (previsível, mas não muda identidade).
- B — HUD flutuante modular (bonito, mas vira bagunça em telas pequenas).

---

## 2.1 Estrutura macro (zonas lógicas, não retângulos visíveis)

```
┌────────────────────────────────────────────┐
│           STATUS / RESOURCE HEADER         │
├────────────────────────────────────────────┤
│              GAMEPLAY FIELD                │
│      Goobers          CLICK                │
├────────────────────────────────────────────┤
│               ACTION DOCK                  │
└────────────────────────────────────────────┘
```

O jogador deve sentir que existe um campo de jogo, não "espaço vazio entre duas toolbars".

---

## 2.2 Header — informação, não navegação

- **Centro: dinheiro** (dominante) + income menor abaixo/ao lado. Sem rótulo "Dinheiro".
- Recursos secundários (GC, Essence) em **Resource Chips** — só aparecem quando desbloqueados.
- Prestige: indicador discreto (ex. `P3`) associado a Essence/progressão — não uma quarta moeda.
- Combo **sai do header** (é gameplay temporário).

---

## 2.3 Combo perto do gameplay

Surge próximo à ação, cresce visualmente com escala (x3 → x10 🔥 → x25 🔥🔥 → x75 !!),
desaparece suavemente ao acabar. Devolve espaço ao HUD.

---

## 2.4 CLICK como protagonista

Componente conceitual **ClickTarget** (não reusa visual de botão de menu): maior peso visual,
forma distinta, sombra/elevação, feedback elástico, resposta a pressão, estados de evento,
combo feedback, escala progressiva, hit target mobile generoso. Deve dizer "APERTE ISSO"
antes mesmo de ler "CLICK".

---

## 2.5 Campo de jogo (Playfield)

```
GameShell
 ├── BackgroundLayer
 ├── Playfield
 │    ├── GooberLayer
 │    ├── ClickLayer
 │    ├── RewardEffectsLayer
 │    └── GameplayOverlayLayer
 ├── HUDLayer
 ├── SurfaceLayer
 └── SystemOverlayLayer
```

Camadas com responsabilidades claras (hoje main.gd monta vários elementos direto).

---

## 2.6 Background

Escuro com profundidade sutil: gradiente leve, vignette mínima, noise quase invisível, formas
abstratas suaves por tema, iluminação sutil no centro. Nada que concorra com Goobers.

---

## 2.7 Goobers pertencem ao campo

Mesma mecânica, apresentação melhor: sombra de contato, spawn feedback, rarity glow controlado,
hit reaction, death/pop, reward text, boss presence distinta. Goober é **conteúdo do playfield**,
não UI. (Detalhe aprofundado no bloco de Game Feel.)

---

## 2.8 Eventos — região compacta e dedicada

```
╭────────────────────────────╮
│ ⚡ OVERCLOCK       6.2s    │
│ Auto ↑ • Spawn ↑           │
│ ███████████░░░░░           │
╰────────────────────────────╯
```

Flutuando logo abaixo do header. Raridade dá acento de cor. Eventos especiais podem alterar
ambientação temporariamente, mas o status continua legível e consistente.

---

## 2.9 Active Skills na interface de gameplay

Cluster compacto (não quatro botões enormes) — só as compradas. Cooldown via progress ring /
overlay radial / barra discreta / número. No mobile: skill rail lateral ou fileira compacta acima da dock.

---

## 2.10 Dock inferior

Apenas destinos de altíssima frequência:

`[ Shop ]     [ Collection ]     [ Menu ]`

- Shop → upgrades básicos.
- Collection → Gooberário (clicar goobers é atividade central; consultar progresso é natural).
- Menu → hub com o resto.

Achievements saem da navegação primária (frequência define proximidade).

---

## 2.11 Menu vira Progression Hub

Não é mais grade de botões equivalentes:

```
POOPY CLICKER

PROGRESSÃO
[ Prestige ]     [ Perks ]

ATIVIDADES
[ Missions ]     [ Achievements ]

COLEÇÃO
[ Gooberário ]   [ Themes ]

INFORMAÇÕES
[ Stats ]        [ Settings ]

         [ Secret Shop ]
```

Com badge / progress / lock / notification dot / contexto:

```
MISSIONS         3/4 completas
PRESTIGE         +17 Essence disponível
ACHIEVEMENTS     37 / 54
```

---

## 2.12 Secret Shop

Secreta de verdade: nada antes do unlock. Depois, identidade própria no Hub (posição estranha
ou visual diferenciado): `? GOOBER SHOP ?`.

---

## 2.13 Acesso rápido contextual

Atalhos temporários sem mexer na navegação permanente:
`✓ Mission complete [View]` · `✦ Prestige ready +14 Essence` · `NEW GOOBER Prism [View entry]`.

---

## 2.14 Mobile / Desktop / Tablet

- **Mobile** (conceitual): header de estado → event → gameplay (goobers + CLICK) → combo →
  skill rail → dock Shop/Goobers/Menu. Containers + safe area, sem coordenadas travadas.
- **Desktop**: espaço extra, não outra UX — chips na horizontal, skills em rail lateral,
  dock compacta centralizada, painéis largos em duas colunas.
- **Tablet/breakpoint por capacidade de layout** (`compact` / `medium` / `wide`), não por nome
  de dispositivo. Janela desktop estreita usa compact; tablet landscape usa medium/wide.

---

## 2.15 Sobreposição de painéis (3 categorias)

- **Quick Surface** — ação curta (confirmações, detalhes rápidos, skill info): modal compacto.
- **Standard Surface** — Shop, Prestige, Missions, Achievements: quase full-screen no compact;
  painel central/lateral no wide.
- **Immersive Surface** — Gooberário, Themes, Stats extensos: quase toda a viewport.

---

## 2.16 Back behavior (absolutamente previsível)

`confirmation → fecha confirmation` → `subsurface → volta para surface pai` → `surface → fecha` →
`nenhuma surface → comportamento do sistema`. Uma única forma de voltar, sempre.

---

## 2.17 Hierarquia dos recursos

- **Tier 1 — sempre visível**: Money, Income.
- **Tier 2 — visível quando desbloqueado**: GC, Essence, Prestige level.
- **Tier 3 — temporário**: Combo, Event, Skill cooldowns.
- **Tier 4 — contextual** (feedback/notificações/surfaces, não HUD): Mission progress,
  Collection completion, Achievement progress, Offline earnings.

---

## Decisões aprovadas conscientemente

1. **Shell híbrido** — header compacto + gameplay livre + dock inferior. ✔
2. **Dock = Shop / Gooberário / Menu** — Achievements sai do acesso permanente. ✔
3. **Menu = Progression Hub** — com contexto/progresso/badges. ✔

## Resultado esperado (regra perceptual)

~80% jogo · ~15% informação · ~5% navegação. A pessoa abre o jogo e vê primeiro
Goobers + CLICK + números subindo — não botões para abrir outras telas.

## Arquitetura resultante

```
Main
└── GameShell
    ├── BackgroundLayer
    ├── Playfield (GooberLayer / ClickTargetLayer / RewardFxLayer)
    ├── HudLayer (ResourceHeader / EventStatus / ComboDisplay / SkillRail / ActionDock)
    ├── SurfaceLayer (QuickSurface / StandardSurface / ImmersiveSurface)
    └── OverlayLayer (Toasts / AchievementReveal / PrestigeSequence / SystemEffects)
```

Arquitetura servindo o produto, não arquitetura pelo prazer de arquitetura.
