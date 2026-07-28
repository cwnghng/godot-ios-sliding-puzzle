# Godot iOS Sliding Puzzle

A 4x4 sliding puzzle game built with Godot 4, targeting iOS. The project is a hands-on learning exercise for three specific Godot concepts:

- **Touch input** — drag-and-drop via `InputEventScreenTouch` and `InputEventScreenDrag`
- **Atlas textures** — slicing a single image into tile regions using `AtlasTexture`
- **Dynamic UI sizing** — viewport-relative layout that adapts to any screen size

## How it works

### Touch & drag (`PuzzleBoard.gd`)

Tiles respond to finger input, not mouse clicks. On touch-down, the board checks whether the tapped tile is adjacent to the empty slot and determines the allowed drag axis (horizontal or vertical). As the finger moves, the tile follows clamped to that axis. On release, it snaps to whichever end (empty slot or origin) it is closest to.

```
InputEventScreenTouch  → start / end drag
InputEventScreenDrag   → move tile along axis
```

### Atlas textures (`PuzzleBoard.gd: _make_atlas`)

A single `art.png` image is loaded once and divided into a 4×4 grid of regions. Each tile gets an `AtlasTexture` pointing at the same base texture but a different `Rect2` region — no extra files, no runtime cropping.

```
AtlasTexture.atlas  = source_tex
AtlasTexture.region = Rect2(col * slice_w, row * slice_h, slice_w, slice_h)
```

### Dynamic sizing (`Main.gd: _apply_dynamic_sizing`)

All positions, font sizes, and offsets are derived from `get_viewport_rect().size` at runtime, so the layout works on any iPhone or iPad without hardcoded pixel values.

## Project structure

```
godot/
  assets/images/art.png   # source image sliced into 15 puzzle tiles
  scenes/Main.tscn         # root scene with CanvasLayer, labels, win overlay
  scripts/
    Main.gd                # UI wiring, move counter, win screen
    PuzzleBoard.gd         # grid logic, shuffle, touch input, atlas tiles
```

## Running the project

Open the `godot/` folder in Godot 4. Hit Play (`F5`) to run in the editor — touch input is simulated with the mouse. For a real device build, use the iOS export preset in `export_presets.cfg`.
