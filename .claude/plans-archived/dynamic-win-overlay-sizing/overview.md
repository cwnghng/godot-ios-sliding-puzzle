# Plan: Dynamic Win Overlay Sizing

## Objective
Scale all win overlay UI elements (WinLabel, MovesLabel, RestartButton) and the gameplay MoveCounterLabel proportionally to viewport size. Currently all sizes are hardcoded pixel values that appear tiny on high-resolution iPhones. PuzzleBoard already does this correctly using `min(vp.x, vp.y) * factor` — the win overlay needs the same treatment.

## Background & context
- **Critical files:** `godot/scenes/Main.tscn`, `godot/scripts/Main.gd`
- **Current flow:** `Main.tscn` defines all win overlay nodes with hardcoded pixel offsets and a shared `LabelSettings` sub-resource with `font_size = 32`. `Main.gd` only holds onready refs for `win_moves_label` and `restart_button` — `WinLabel` and `MoveCounterLabel` have no code references.
- **Existing pattern:** `PuzzleBoard.gd:35` derives `tile_size = min(vp.x, vp.y) * 0.20` from the viewport at `_ready()` and uses it as the base unit for all board geometry. We use the same `tile_size` value as the reference unit here, keeping both subsystems in sync.
- **Shared resource hazard:** `LabelSettings_1` is reused by `WinLabel`, `MovesLabel`, and `MoveCounterLabel`. Modifying that resource at runtime would affect all three simultaneously. We use `add_theme_font_size_override("font_size", value)` on each node individually instead — this overrides at runtime without touching the tscn resource.

## Approach
In `Main.gd _ready()`, after getting the viewport size, derive `tile_size` identically to PuzzleBoard, compute `font_size` and all offsets as multiples of `tile_size`, and apply them via theme overrides and direct offset assignments.

## Constraints & decisions
- Portrait-only: use `min(vp.x, vp.y)` as the scale axis
- Sizing unit: `tile_size = vp_min * 0.20` — mirrors PuzzleBoard exactly
- Font scale: `font_size = int(tile_size * 0.43)` — reproduces the current 32px at 375px viewport (375 × 0.20 × 0.43 ≈ 32)
- Geometry: all offsets expressed as `tile_size` multiples, derived from original pixel values ÷ 75 (tile_size at 375px)
- Font override method: `add_theme_font_size_override` — no resource mutation needed

## Out of scope
- Landscape orientation
- Any UI beyond the four listed nodes
- Godot Theme resource infrastructure

## Steps (overview)
1. [Add missing onready refs](./step_1.md) — wire up `WinLabel` and `MoveCounterLabel` in `Main.gd`
2. [Add `_apply_dynamic_sizing()` and call it](./step_2.md) — compute font sizes and offsets from viewport; apply to all four nodes

## Testing strategy
Verify visually on a high-resolution iPhone (physical device or simulator) — confirm overlay text and button are comfortably sized.

## Migration & rollback
Pure code change; `git revert` is sufficient. No data or API impact.

## Risks & open questions
- If the Godot project uses a fixed stretch/viewport override that makes `get_viewport_rect().size` always return a constant, the scaling won't respond to physical resolution — but since PuzzleBoard's tile scaling already works, this is not a concern.
