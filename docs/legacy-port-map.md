# Mapa de Migração — Poopy Clicker Python (PyQt6) → Godot 4

## Paridade

| LEGACY PYTHON                  | GODOT                          | STATUS  |
|--------------------------------|--------------------------------|---------|
| `count`                        | `GameState.money`              | portado |
| `upgrade_level`                | `GameState.click_level`        | portado |
| `auto_level`                   | `GameState.auto_level`         | portado |
| `get_click_value()`            | `Economy.get_click_value()`    | portado |
| `get_auto_value()`             | `Economy.get_auto_value()`     | portado |
| `get_click_upgrade_cost()`     | `Economy.get_click_upgrade_cost()` | portado |
| `get_auto_upgrade_cost()`      | `Economy.get_auto_upgrade_cost()` | portado |
| `get_difficulty_step()`        | `ClickController.get_difficulty_step()` | portado |
| `move_click_button_randomly()` | `ClickController.move_click_button_randomly()` | portado |
| `format_number()`              | `NumberFormat.format()`        | portado |
| `Goober`                       | `Goober` (scripts/goobers)     | portado |
| `PlayArea` / layout PyQt       | Control programático           | feito   |
| `save()/load()` (JSON local)   | `SaveManager` (user://)       | portado |
| `Shop` (`upgrade_btn`/`auto_btn`) | `ShopUI` + `GameState.try_buy_*` | portado |
| `secret_shop` / `goober_coins` | `SecretShopUI` + `GameState`    | portado |
| `try_spawn_goober`             | `GooberManager`                | portado |
| `auto_loop` (QTimer)           | `Timer` em main.gd             | portado |

## Preservar fielmente

- Economia: `click_value = 2^click_level`, custo `200 * 2^click_level`,
  `auto_value = 0` no nível 0 senão `2^(auto_level-1)`, custo `500 * 2^auto_level`
- Botão móvel: drift horizontal/vertical, chance extra de empurrão em X,
  margem de 12px, sempre dentro da área, reposicionado em resize
- Dificuldade dinâmica: `min(28 + ((click_level + auto_level) * 3), 120)`
- Progressão principal e identidade dos Goobers (estados walk/idle/scare/panic)

## Reimplementar melhor

- Arquitetura: estado centralizado (`GameState`), economia pura (`Economy`), UI desacoplada
- Timers: um único Timer de auto-click orquestrado em main.gd, sem QTimer por entidade
- Movimento contínuo por `delta` quando Goobers entrarem
- Save: `user://` com `save_version` e migrações
- UID de jogo (canvas_items + expand), não janela PyQt fixa

## Não portar literalmente

- `global` Python → estado vive em `GameState`
- arquivo monolítico (807 linhas) → pastas `core/`, `systems/`, `ui/`, `goobers/`
- `QTimer` por entidade → managers/update central
- detalhes específicos de PyQt (QDialog, QMovie, layouts Qt)