# Poopy Clicker 2.0 — Bloco 1: Visão de Produto, Identidade e Princípios de UX

> **Poopy Clicker is allowed to be stupid. It is not allowed to feel cheaply made.**

Data: 2026-08-14
Status: Constituição (fundamento de todo o redesign)
Próximo bloco: Bloco 2 — arquitetura da tela principal, HUD, área de jogo, hierarquia de recursos e modelo de navegação.

---

## 1. Visão do produto

Poopy Clicker 2.0 não é "um clicker simples com várias telas". É um jogo pequeno em escopo,
mas deliberado em execução: cada sistema, animação, informação e interação precisa parecer
parte do mesmo produto.

O objetivo não é competir em quantidade de conteúdo — é competir em **personalidade,
clareza e sensação ao jogar**.

Experiência ideal:

> abrir o jogo, entender imediatamente o que está acontecendo, clicar porque é gostoso clicar,
> perceber coisas estranhas acontecendo ao redor, descobrir sistemas aos poucos e ter
> constantemente pequenas recompensas visuais e mecânicas.

O jogo pode ser idiota. A implementação não.

Humor não é desculpa para UI improvisada, acessibilidade ruim, animação excessiva ou sistemas
escondidos atrás de menus ruins. A piada funciona melhor quando o produto em volta dela
parece extremamente bem feito.

### North Star

> "isso é absurdamente besta, mas fizeram essa besta MUITO bem."

Esse é o filtro para decisões futuras.

---

## 2. Posicionamento

O jogo ocupa o espaço entre três coisas:

- **Incremental/clicker** — progressão clara, crescimento constante, números subindo, upgrades
  e resets satisfatórios.
- **Arcade casual** — interação direta, elementos se movimentando, eventos inesperados,
  momentos rápidos de atenção.
- **Toy/game feel** — divertido mesmo sem "progredir": apertar, abrir, comprar, capturar e
  desbloquear são ações prazerosas por si mesmas.

Não queremos um idle onde 90% é ler tabela. Nem um arcade que torne os sistemas incrementais
irrelevantes. O centro é:

> progressão de clicker + interação de brinquedo + caos controlado.

---

## 3. Identidade visual

Direção aprovada: **D — Dark Polished + Expressive Game Layer** (não "fundo preto + neon").

Duas camadas visuais deliberadamente diferentes:

### Camada estrutural
HUD, navegação, painéis, cards, diálogos, configurações, informação numérica, estrutura das lojas.
- **escura, calma, refinada, previsível e legível** — existe para dar estabilidade.

### Camada expressiva
Goobers, botão CLICK, eventos, raridades, combo, recompensas, Prestige, achievements, bosses,
particles, unlocks, feedback de interação.
- **colorida, exagerada, elástica, engraçada e ocasionalmente caótica** — existe para dar personalidade.

Quando um evento Legendary explodir visualmente, ele realmente parece especial porque o resto
da interface não está gritando o tempo todo.

---

## 4. Personalidade visual

Cinco palavras que descrevem qualquer tela final:

> estranho — fofo — energético — polido — legível

Quatro que não queremos:

> corporativo — genérico — infantilizado — sobrecarregado

Existe diferença entre infantil e brincalhão. Um Goober pode fazer uma cara absolutamente
estúpida; ele não precisa, por causa disso, ter fonte Comic Sans, gradiente arco-íris e sete
botões gigantes de cores diferentes. O humor vem do conteúdo e das reações, não da falta de
disciplina visual.

---

## 5. Hierarquia emocional

Quanto cada parte pode "gritar":

- **Nível 0 — ambiente**: background, superfícies, chrome. Quase silenciosos.
- **Nível 1 — informação**: money, CPS, recursos, labels. Alta legibilidade, baixo ruído.
- **Nível 2 — ações**: botões, upgrades, navegação, escolhas. Claros e responsivos.
- **Nível 3 — gameplay**: CLICK, Goobers, combo, evento ativo. Devem chamar atenção.
- **Nível 4 — momentos especiais**: Prestige, boss, achievement raro, unlock importante,
  evento Legendary/Mythic. Aqui podemos perder a compostura por alguns segundos.

Evita o clássico "tudo parece importante, logo nada parece importante".

---

## 6. Princípios de UX (requisitos de projeto, não sugestões)

1. **Gameplay first** — a área jogável é sempre protagonista. HUD e navegação existem ao redor
   dela, não sobre ela. Nada de "cockpit de avião" durante o gameplay.
2. **Glanceability** — sem abrir menu, o jogador responde: quanto dinheiro tenho? quanto gero?
   existe combo? existe evento? algum recurso mudou? há ação urgente? Detalhes vivem nos painéis.
3. **Progressive disclosure** — recursos/navegação surgem conforme desbloqueados. Reduz
   complexidade inicial e dá a sensação de que o jogo está crescendo.
4. **Uma ação, uma resposta** — toda ação importante produz feedback perceptível (visual, número,
   som; compra = estado + economia + som; Prestige = sequência maior que uma compra comum).
   O jogador nunca pensa "eu apertei?".
5. **Frequência define proximidade** — quanto mais usado, menos passos. Não preservar a navegação
   atual por fidelidade: alguns sistemas vão para acesso rápido, outros para o Menu, outros
   aparecem só contextualmente.
6. **Mobile não é desktop pequeno** — arquitetura nasce para touch: targets confortáveis, sem
   hover, painéis com scroll natural, gestos/back funcionais, safe areas no layout. Desktop
   aproveita espaço extra, mas não determina a estrutura base.
7. **Movimento tem significado** — animar para comunicar origem/destino/importância/mudança/
   recompensa (ex.: dinheiro nasce no ponto da ação e converge para o contador). Não animar "porque Tween existe".
8. **O jogador nunca perde contexto sem motivo** — abrir tela secundária não deve parecer "outro
   app". Goobers podem continuar em background; eventos permanecem perceptíveis; voltar é imediato.
9. **Falha precisa ser compreensível** — botão cinza não basta; comunicar o porquê (compra,
   conteúdo bloqueado, cooldown, Prestige indisponível, habilidade sem requisito).
10. **Consistência estrutural, variedade semântica** — mesmo spacing, mesmo sistema de botão,
    mesmo back, mesmo padrão de título, mesmo feedback de seleção. Depois disso, cada tela pode
    ter personalidade própria (loja ≠ gooberário ≠ prestige ≠ stats).

---

## 7. Filosofia de progressão visual

A interface evolui junto com o save. No começo, HUD minimalista; depois aparecem GC, Essence,
combo mais elaborado, skills, indicador de Prestige, novos atalhos — **redistribuindo** informação
responsivamente conforme sistemas entram, não só empilhando itens.

---

## 8. Objetivos do redesign

- **O1 — Identidade**: qualquer screenshot deve parecer Poopy Clicker, não "Godot UI dark theme".
- **O2 — Clareza**: jogador novo identifica dinheiro, CLICK e ação principal imediatamente.
- **O3 — Responsividade**: mesma arquitetura de celular pequeno a desktop, sem clipping/controles minúsculos.
- **O4 — Componentização**: mudança visual comum não exige editar dez painéis.
- **O5 — Feedback**: toda interação importante tem feedback adequado à importância.
- **O6 — Escalabilidade**: novo recurso usa componentes existentes, não inventa outro padrão.
- **O7 — Performance**: juice não compromete aparelhos modestos; partículas/blur/shaders/animações com budget.
- **O8 — Personalidade**: mais vivo que a UI atual, sem sacrificar legibilidade.

---

## 9. Objetivos técnicos associados

O redesign deve permitir: design tokens centralizados; componentes primitivos reutilizáveis;
componentes semânticos por domínio; responsividade por espaço disponível (não lista de resoluções);
apresentação desacoplada de regras de gameplay; painéis sem lógica econômica duplicada; estados
visuais previsíveis; animações centralmente configuráveis; suporte a `reduced_motion`; safe-area
nativa; testes de layout/estado; trocar temas sem reconstruir UI manualmente.

Não refatorar tudo de uma vez — mas toda UI nova nasce nessa direção.

---

## 10. Antiobjetivos

Não pretendemos: virar live service; sistema de menus gigantesco; multiplayer; monetização;
copiar UI predatória; virar ícones sem texto; perseguir hiperrealismo; depender de shaders caros;
trocar personalidade por "minimalismo premium"; reescrever gameplay ao refazer a apresentação;
criar arquitetura empresarial desnecessária para um projeto pequeno.

O objetivo é **engenharia proporcional**: código simples quando simples resolve; estrutura forte
onde ela realmente reduz dívida.

---

## 11. Definition of Success

Colocar a UI antiga e a nova lado a lado e perceber: **mesmo jogo, mesmos Goobers, mesmos
sistemas** — mas agora parece um produto que alguém realmente dirigiu.

Não é só "ficou mais bonito". Tem que parecer:

> mais fácil de entender; mais gostoso de operar; mais expressivo; mais consistente;
> mais confiável; mais próprio.

Essa diferença entre skin nova e produto redesenhado separa nosso trabalho de um simples reskin.
