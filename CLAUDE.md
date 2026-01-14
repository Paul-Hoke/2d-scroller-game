# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a 2D platformer scroller game built with Godot Engine 4.5 featuring 20 progressive levels with multiple enemy types, theming system, full UI flow (title screen, level select, pause menu, game over, victory), statistics tracking, and dynamic audio. The project uses the Forward Plus rendering method.

## Development Commands

### Running the Game
- Open the project in Godot Editor and press F5, or use the play button
- CLI: `godot --path .` (runs the game from command line)
- Run specific scene: `godot --path . res://path/to/scene.tscn`
- Local Godot installation: `Get-Process Godot_v4.5.1-stable_win64 -ErrorAction SilentlyContinue | Stop-Process -Force; & "C:\Users\hokep\Downloads\Godot_v4.5.1-stable_win64.exe\Godot_v4.5.1-stable_win64.exe" --path . --position 96,96`

**Important**: After making code or asset changes, run the project to verify functionality before committing. Always close any running instances and open the window at position 96,96.

### Project Management
- Open in Godot Editor: `godot --path . --editor`
- Export project: Use Godot Editor's Project > Export menu

### Asset Generation
- Audio generation: `python scripts/generate_audio.py` (creates background music WAV files)
- SFX generation: `python scripts/generate_sfx.py` (creates sound effect WAV files)
- Background cleaning: `python scripts/clean_background.py` (processes background images)

## Code Architecture

### Project Structure
```
scripts/
  actors/          # Player and 3 Enemy type scripts (base, flying, flying turtle)
  objects/         # Coin and Goal scripts
  ui/              # HUD, TitleScreen, LevelSelect, GameOver, Victory, PauseMenu
  GameState.gd     # Autoload singleton for global state
  LevelLogic.gd    # Per-level theming and music system
scenes/
  Main.tscn        # Level 1 (tutorial level)
  levels/          # Level2-20.tscn + ParallaxBackground.tscn
  actors/          # Player, Enemy, EnemyFlying, EnemyFlyingTurtle, EnemyMushroom
  objects/         # Coin and Goal scene definitions
  ui/              # Complete UI flow (6 screens total)
assets/
  audio/           # Theme-based music (4 themes) + SFX (jump, damage, kill, life)
  *.png            # Player sprites, enemy sprites, backgrounds
```

### Global State Management (GameState Singleton)
The `GameState.gd` script is autoloaded as a singleton (defined in project.godot) and provides:
- **Score tracking**: `add_score(amount)` method, `score_changed` signal
  - Extra life every 100 points (emits life SFX)
- **Health system**: `take_damage(amount)` method, `health_changed` signal
  - Starts at 3 hearts
  - Game over screen when health reaches 0
- **Level progression**: `current_level` tracking, `level_changed` signal
  - 20 levels total (Main.tscn is Level 1, Level2-20.tscn)
  - Victory screen after Level 20
- **Statistics tracking**: Records health gained/lost, double jumps, playtime, level completion times
- **Audio system**: Custom WAV loader/parser, SFX playback (kill, damage, life sounds)
- **Game lifecycle**: `reset()`, `restart_game()`, `go_to_victory()` methods

UI components (HUD, Victory screen) connect to these signals. Game objects call methods directly via the global `GameState` reference.

### Actor System

**Player** (scripts/actors/Player.gd):
- CharacterBody2D with double-jump (max 2 jumps), physics-based movement
- Animation states: idle, walk, jump
- Flash red when taking damage
- Death at Y > 1000 (respawns with -1 health)
- Uses input actions: "move_left", "move_right", "jump"
- Must be in "player" group for enemy collision detection

**Enemy Types** (all check `body.is_in_group("player")` for collision):
1. **Enemy** (scripts/actors/Enemy.gd) - Ground walker
   - Horizontal patrol with RayCast2D wall/floor detection
   - Gravity-based physics
   - Dies when player stomps from above, damages player on side collision

2. **EnemyFlying** (scripts/actors/EnemyFlying.gd) - Flying bat
   - Horizontal movement with sine wave vertical oscillation
   - No gravity (wave pattern maintained)
   - Wave amplitude: 50px, frequency: 2.0Hz
   - Same stomp/damage mechanics as base enemy

3. **EnemyFlyingTurtle** - Uses EnemyFlying.gd with turtle sprite
4. **EnemyMushroom** - Uses Enemy.gd with mushroom sprite

All enemies disable collision and fall with rotation when defeated.

### Level System

**Level Progression**:
- 20 levels total: Main.tscn (Level 1), Level2.tscn through Level20.tscn
- Each level has a Goal with `next_level_path` property pointing to the next level
- Level 20's Goal triggers Victory screen via `GameState.go_to_victory()`

**LevelLogic** (scripts/LevelLogic.gd) - Attached to each level for theming:
- Theme selection based on level number:
  - Levels 1-5: Forest theme (music_forest.wav, green/brown colors)
  - Levels 6-10: Cave theme (music_cave.wav, gray/dark colors)
  - Levels 11-15: Sky theme (music_sky.wav, blue/white colors)
  - Levels 16-20: Lava theme (music_lava.wav, red/orange colors)
- Dynamically loads theme music and sets it to loop
- Colors floor and platform nodes based on theme
- Swaps background images per theme

**Object Interaction**:
- **Coin**: Area2D that adds score (default: 10 points) via `GameState.add_score()` when player enters
- **Goal**: Area2D with `next_level_path` export variable. Loads next level or triggers victory.

All collectibles/interactables use `body_entered` signal and check for "player" group membership.

### UI Flow

The game has a complete UI navigation system:

1. **TitleScreen** (scenes/ui/TitleScreen.tscn) - Entry point
   - Start Game → Main.tscn (Level 1)
   - Level Select → LevelSelect screen
   - Exit → Quit game

2. **LevelSelect** (scenes/ui/LevelSelect.tscn)
   - Grid of 20 level buttons
   - Each button loads corresponding level scene
   - Back button → TitleScreen

3. **HUD** (scenes/ui/HUD.tscn) - In-game overlay
   - Displays current score, health, level number
   - Connects to GameState signals for real-time updates

4. **PauseMenu** (scenes/ui/PauseMenu.tscn) - Activated with "pause" input (ESC/P/Gamepad Start)
   - Resume → Unpause game
   - Level Select → Return to level select
   - Main Menu → Return to title screen
   - Quit → Exit game
   - Uses `get_tree().paused` to freeze gameplay

5. **GameOver** (scenes/ui/GameOver.tscn) - Shown when health reaches 0
   - Retry → Reload current level with reset GameState
   - Menu → Return to title screen

6. **Victory** (scenes/ui/Victory.tscn) - Shown after completing Level 20
   - Displays final score and statistics grid
   - Menu button → Return to title screen

### Godot-Specific Conventions
- **Scenes (.tscn)**: Define game objects and their hierarchy; the primary unit of composition in Godot
- **Scripts (.gd)**: GDScript files attached to scene nodes to define behavior
- **Autoloads/Singletons**: Globally accessible scripts defined in project.godot (GameState is the main one)

### GDScript Syntax Notes
- Godot uses GDScript (Python-like syntax) as the primary scripting language
- Indentation-based blocks (use tabs or spaces consistently per .editorconfig)
- Type hints are optional but recommended: `var speed: float = 100.0`
- Node access uses `$NodeName` or `get_node("NodeName")`
- Signals are Godot's event system: `signal_name.emit()` to fire, `signal_name.connect()` to listen
- `@export` decorator exposes variables in the Godot editor
- `@onready` decorator initializes variables when node enters scene tree

### Code Style Conventions
- **Naming**: `PascalCase` for nodes/classes, `snake_case` for variables/functions
- **Static typing**: Prefer explicit type hints (e.g., `func _ready() -> void:`)
- **Groups**: Use Godot groups for interaction checks (e.g., `body.is_in_group("player")`)

## Key Development Patterns

### Node Lifecycle
- `_ready()`: Called when node enters the scene tree
- `_process(delta)`: Called every frame
- `_physics_process(delta)`: Called every physics frame (fixed timestep)

### Scene Instancing
Godot uses scene instancing for prefabs/templates. Create reusable objects as scenes and instance them in code or other scenes.

### Input Handling
Input actions are defined in project.godot's input map:
- **move_left** / **move_right**: Horizontal player movement (Arrow keys, A/D, Gamepad)
- **jump**: Player jump action (Space, Gamepad A button)
- **pause**: Toggle pause menu (ESC, P key, Gamepad Start)
- **ui_accept**, **ui_up**, **ui_down**, **ui_left**, **ui_right**: UI navigation

Check input in code:
```gdscript
if Input.is_action_pressed("move_right"):
    position.x += speed * delta
```

### Audio System

**Music** (Theme-based, looping):
- `music_forest.wav` - Levels 1-5
- `music_cave.wav` - Levels 6-10
- `music_sky.wav` - Levels 11-15
- `music_lava.wav` - Levels 16-20
- `title_music.wav` - Title screen

**Sound Effects**:
- `jump.wav` - Player jump
- `damage.wav` - Player takes damage
- `kill.wav` - Enemy defeated
- `life.wav` - Extra life gained (100 points)

Music is loaded and managed by LevelLogic script. SFX are played via GameState singleton. All audio uses custom WAV loader with manual header parsing in GameState.gd.

## File Encoding
All text files use UTF-8 encoding (per .editorconfig).

## GitHub Workflow

### Repository Information
- **Repository**: https://github.com/Paul-Hoke/2d-scroller-game
- **GitHub Project**: "2D Scroller Game" project board
  - Use this project board to track all issues and pull requests
  - Move issues between columns: "To Do" → "In Progress" → "In Review" → "Done"

### Branch Naming Convention
**Always** create new branches with the issue number at the beginning:
```bash
# Good
git checkout -b 3-remove-list-object
git checkout -b 42-add-user-stats

# Bad
git checkout -b remove-list-object
git checkout -b feature/add-user-stats
```

### Commit Message Format
```
Short description (50 chars or less)

Detailed explanation of changes including:
- What was changed
- Why it was changed
- Any breaking changes

Fixes #issue-number

```

### Pull Request Process
1. Create feature branch with issue number prefix
2. Move the issue to "In Progress" in the 2D Scroller Game project
3. Make changes and commit with descriptive messages
4. Push branch to origin
5. Create PR with comprehensive description
6. Link PR to issue with "Fixes #N"
7. Move the issue to "In Review" in the 2D Scroller Game project
