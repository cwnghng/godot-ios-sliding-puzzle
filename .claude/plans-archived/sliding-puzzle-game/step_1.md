# Step 1: Configure project settings

## Goal
Lock the game to portrait orientation and enable touch-from-mouse emulation for editor testing. Set the main scene so the project opens correctly.

## Prerequisites
None.

## Files to touch
- `godot/project.godot` — add orientation lock, touch emulation, and main scene path

## Changes
Add the following to `project.godot` under the appropriate sections:

```ini
[application]
config/name="Sliding Puzzle"
config/features=PackedStringArray("4.7", "Mobile")
config/icon="res://icon.svg"
run/main_scene="res://scenes/Main.tscn"   ; add this line

[display]
window/stretch/mode="canvas_items"
window/stretch/aspect="expand"
window/handheld/orientation=1             ; 1 = portrait

[input_devices]
pointing/emulate_touch_from_mouse=true    ; enables editor mouse → touch testing

[physics]
3d/physics_engine="Jolt Physics"

[rendering]
rendering_device/driver.windows="d3d12"
renderer/rendering_method="mobile"
```

`window/handheld/orientation=1` maps to `SCREEN_PORTRAIT` in Godot 4. The `emulate_touch_from_mouse` setting means mouse clicks and drags in the editor will fire `InputEventScreenTouch` and `InputEventScreenDrag`, matching real device behavior.

## Acceptance criteria
- [ ] `project.godot` contains `run/main_scene="res://scenes/Main.tscn"`
- [ ] `project.godot` contains `window/handheld/orientation=1`
- [ ] `project.godot` contains `pointing/emulate_touch_from_mouse=true`

## Test commands
```bash
# No automated test — open Godot editor and verify Project Settings reflects portrait + touch emulation
grep -n "orientation\|emulate_touch\|main_scene" godot/project.godot
```

## Rollback
`git revert` the commit, or manually delete the three added lines from `project.godot`.

## Notes
Godot 4 uses integer values for orientation: 0=landscape, 1=portrait, 2=reverse landscape, 3=reverse portrait, 4=sensor landscape, 5=sensor portrait, 6=sensor. We want 1.
