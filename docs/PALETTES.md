# Astrowing Starfighter - Palette Definitions

This document outlines the 8 palettes (P0-P7) configured in `astrowing.bas`. Each palette consists of 3 colors (C1, C2, C3). The background color (`BACKGRND`) is shared globally.

## Summary

| Palette | Usage | Primary Colors | Notes |
| :--- | :--- | :--- | :--- |
| **P0** | UI / HUD | Orange/Brown, Grey | Used for Score, Lives, Level text. |
| **P1** | Player Bullets | Greens | Gradient from dark to light green. |
| **P2** | Asteroids | Greys | Gradient for rock texture. |
| **P3** | Enemies | Cyan, Red, Yellow | Multi-color sprite mapping for enemy ships. |
| **P4** | Stars | Dark Greys/White | Used for the starfield background. |
| **P5** | Player Ship | Red-Orange, Blue, Silver | The hero ship colors. |
| **P6** | Enemy Bullets | Red/Pink | Gradient for danger/enemy fire. |
| **P7** | Title/Screens | Green, Red, Yellow | Animated on Title Screen. |

## Detailed Definitions

### Global Background
*   **BACKGRND**: `$00` (Black)

### P0 - UI & HUD
Used for the status bar (Score, Lives, Shield Bar text).
*   **C1**: `$26` (Dark Orange)
*   **C2**: `$24` (Brown/Red-Orange)
*   **C3**: `$04` (Dark Grey)

### P1 - Player Projectiles
Used for the player's laser blasts.
*   **C1**: `$C2` (Dark Green)
*   **C2**: `$C6` (Medium Green)
*   **C3**: `$CA` (Light Green)

### P2 - Asteroids
Used for the asteroid obstacles. Creates a rocky appearence.
*   **C1**: `$04` (Dark Grey)
*   **C2**: `$08` (Medium Grey)
*   **C3**: `$0C` (Light Grey)

### P3 - Enemy Ships
Used for standard enemies.
*   **C1**: `$B4` (Cyan/Aqua)
*   **C2**: `$46` (Redish-Purple/Pink)
*   **C3**: `$1C` (Yellow/Gold)

### P4 - Starfield
Used for the scrolling stars in the background.
*   **C1**: `$08` (Dark Grey)
*   **C2**: `$0C` (Medium Grey)
*   **C3**: `$0F` (White)

### P5 - Player Ship (Hero)
Used for the main character's ship.
*   **C1**: `$34` (Red-Orange) - Fuselage details
*   **C2**: `$86` (Blue) - Wings/Body
*   **C3**: `$0A` (Light Grey/Silver) - Cockpit/Highlights

### P6 - Enemy Projectiles
Used for enemy bullets.
*   **C1**: `$42` (Dark Red/Purple)
*   **C2**: `$46` (Medium Red)
*   **C3**: `$4A` (Light Red/Pink)

### P7 - Title & Screens
Used for the Title Screen logo and transition screens (Game Over, Level Complete).
*   **Default**: `$C8` (Green), `$46` (Red), `$1C` (Yellow)
*   **Animation**: The Title Screen cycles these colors to create a rainbow effect.
