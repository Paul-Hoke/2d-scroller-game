# 2D Scroller Game - Gemini Context

## Project Overview

This is a 2D scroller game project built with **Godot Engine 4.5**. The project has evolved from an initial setup to a functional prototype featuring platforming mechanics, enemies, collectibles, UI, and audio.

## Getting Started

### Prerequisites
*   **Godot Engine 4.5**: Ensure you have the Godot binary accessible in your path.

### Running the Project
*   **Main Entry Point:** The project is configured to start at `scenes/ui/TitleScreen.tscn`.
*   **Run Game:**
    *   **Editor:** Press **F5**.
    *   **CLI:** `godot --path .`

## Project Structure

The project follows a standard Godot organization pattern:

*   `assets/`: Art and audio resources.
    *   `audio/`: Generated WAV files (jump, music).
    *   `title_bg.png`: Generated background art.
    *   `player_spritesheet.png`: Character animations.
*   `scenes/`: Godot scene files (`.tscn`).
    *   `actors/`: Entities like `Player` and `Enemy`.
    *   `levels/`: Level geometry and backgrounds (e.g., `ParallaxBackground`).
    *   `objects/`: Interactables like `Coin` and `Goal`.
    *   `ui/`: Interface elements like `HUD` and `TitleScreen`.
    *   `Main.tscn`: The primary gameplay level.
*   `scripts/`: GDScript files (`.gd`).
    *   Mirrors the `scenes` structure for logic separation.
    *   `GameState.gd`: Autoloaded singleton for global state.

## Key Components

### Core Mechanics
*   **Player (`Player.gd`):** Uses `CharacterBody2D`. Features include:
    *   Double Jump logic.
    *   AnimatedSprite2D with state machine-like logic (Idle, Walk, Jump).
    *   SFX integration.
*   **Enemies (`Enemy.gd`):** Basic AI that patrols platforms.
    *   Turns around on walls or cliffs (raycast detection).
    *   **Combat:** Player kills enemy by landing on top (stomp); Enemy damages player on touch.
*   **Global State (`GameState.gd`):**
    *   Manages `score` and `health`.
    *   Handles "Game Over" by reloading the scene when health <= 0.
    *   Autoloaded as `GameState` singleton.

### UI & Audio
*   **HUD:** Displays real-time Score and Health via signals.
*   **Title Screen:** Simple "Start Game" menu with generated art and background music.
*   **Audio:** Procedurally generated sound effects for jumping and background music.

## Development Conventions

### Code Style (GDScript)
*   **Naming:** `PascalCase` for Nodes/Classes, `snake_case` for variables/functions.
*   **Typing:** Static typing is preferred (e.g., `var speed: float = 300.0`).
*   **Groups:** Use Godot groups for interaction checks (e.g., `body.is_in_group("player")`).

### Asset Workflow
*   **Images:** Assets are currently generated placeholder art located in `assets/`.
*   **Audio:** Placeholder audio is generated via `scripts/generate_audio.py`.

## Future Roadmap (Potential)
*   [ ] Main Menu "Exit" button.
*   [ ] "Game Over" and "Victory" screens (currently just reloads).
*   [ ] More complex level design (TileMaps).
*   [ ] varied Enemy types.