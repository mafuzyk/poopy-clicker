# Poopy Clicker (Godot rewrite)

Poopy Clicker é um clicker 2D onde você clica, ganha dinheiro, derrota goobers e desbloqueia upgrades, loja secreta, conquistas e gooberário.

Esta é a **rewrite oficial em Godot 4** (GDScript), sucessora da implementação original em Python/PyQt6.

## Como rodar

Abra o projeto com Godot 4.7+ e execute a cena `main.tscn`.

## Estrutura

- `scripts/core/` — estado do jogo e dados
- `scripts/systems/` — economia, save, clique
- `scripts/goobers/` — catálogo e gerenciamento de goobers
- `scripts/ui/` — HUD, painéis, estilos
- `docs/` — especificações de migração e source map

## Controles

- Toque no botão CLICK para ganhar dinheiro (ele foge de você!)
- Derrote goobers para ganhar rewards e moedas GC
- Menu → Loja para upgrades de click/auto
- Menu → Gooberário para ver o progresso de coleta

## Versão legacy (Python)

A antiga implementação Python/PyQt6 foi preservada e não faz parte do runtime:

- Branch: `legacy/python-v1.1.0`
- Tag: `legacy-python-v1.1.0`

Referência canônica de dados (Python v1.1.0, read-only):
`https://github.com/Cherievamp/poopy-clicker`