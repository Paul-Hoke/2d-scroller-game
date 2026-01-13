# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a 2D scroller game built with Godot Engine 4.5. The project uses the Forward Plus rendering method.

## Development Commands

### Running the Game
- Open the project in Godot Editor and press F5, or use the play button
- Alternatively, export and run: `godot --path . --headless` (headless mode for testing)
- Run with specific scene: `godot --path . res://path/to/scene.tscn`

### Project Management
- Open in Godot Editor: `godot --path . --editor`
- Export project: Use Godot Editor's Project > Export menu

## Code Architecture

### Project Structure
```
scripts/
  actors/          # Player and Enemy scripts
  objects/         # Coin and Goal scripts
  ui/              # HUD and TitleScreen scripts
  GameState.gd     # Autoload singleton for global state
scenes/
  actors/          # Player and Enemy scene definitions
  objects/         # Coin and Goal scene definitions
  levels/          # ParallaxBackground and level scenes
  ui/              # HUD and TitleScreen UI scenes
  Main.tscn        # Main game scene
```

### Global State Management (GameState Singleton)
The `GameState.gd` script is autoloaded as a singleton (defined in project.godot) and provides:
- **Score tracking**: `add_score(amount)` method, `score_changed` signal
- **Health system**: `take_damage(amount)` method, `health_changed` signal
- **Game lifecycle**: `reset()` and `restart_game()` methods

UI components (like HUD) connect to these signals to update displays. Game objects (Coin, Enemy) call methods directly via the global `GameState` reference.

### Actor System
- **Player** (scripts/actors/Player.gd): CharacterBody2D with double-jump, physics-based movement, and animation states (idle, walk, jump). Uses built-in input actions (ui_accept, ui_left, ui_right).
- **Enemy** (scripts/actors/Enemy.gd): CharacterBody2D with patrol AI using RayCast2D nodes for wall/floor detection. Dies when player jumps on top (stomps), damages player on side collision with knockback.

Both actors must be added to the "player" group respectively for collision detection to work (Enemy checks `body.is_in_group("player")`).

### Object Interaction Pattern
- **Coin**: Area2D that adds score via `GameState.add_score()` when player enters
- **Goal**: Area2D that triggers level completion or scene reload

All collectibles/interactables use `body_entered` signal and check for "player" group membership.

### Godot-Specific Conventions
- **Scenes (.tscn)**: Define game objects and their hierarchy; the primary unit of composition in Godot
- **Scripts (.gd)**: GDScript files attached to scene nodes to define behavior
- **Autoloads/Singletons**: Globally accessible scripts defined in project.godot for cross-scene functionality

### GDScript Syntax Notes
- Godot uses GDScript (Python-like syntax) as the primary scripting language
- Indentation-based blocks (use tabs or spaces consistently per .editorconfig)
- Type hints are optional but recommended: `var speed: float = 100.0`
- Node access uses `$NodeName` or `get_node("NodeName")`
- Signals are Godot's event system: `signal_name.emit()` to fire, `signal_name.connect()` to listen
- `@export` decorator exposes variables in the Godot editor
- `@onready` decorator initializes variables when node enters scene tree

## Key Development Patterns

### Node Lifecycle
- `_ready()`: Called when node enters the scene tree
- `_process(delta)`: Called every frame
- `_physics_process(delta)`: Called every physics frame (fixed timestep)

### Scene Instancing
Godot uses scene instancing for prefabs/templates. Create reusable objects as scenes and instance them in code or other scenes.

### Input Handling
Define input actions in project.godot's input map, then check in code:
```gdscript
if Input.is_action_pressed("move_right"):
    position.x += speed * delta
```

## File Encoding
All text files use UTF-8 encoding (per .editorconfig).
