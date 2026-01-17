# Variable Memory Map - AtariTrader
**Last Updated: 2026-01-17**

## Purpose
Track all variable assignments to prevent memory collisions. 
**Critical for debugging:** Arrays occupy consecutive memory locations!

## Variable Usage Summary

| Range | Usage | Status | Notes |
|---|---|---|---|
| **var0-17** | Core Globals/Temp | **Busy** | px, py, frame, iter, etc. |
| **var18-37** | Player Bullets (4) | **Full** | x, y, vx, vy, life |
| **var38-39** | Temp vars | **Full** | temp_bx, temp_by |
| **var40-59** | Enemies (4) | **Full** | x, y, vx, vy, life |
| **var60-71** | Enemy Bullets (4) | **Partial** | x, y, vx (vy moved to 160) |
| **var72-73** | Cooldowns/Temp | **Full** | ecooldown, temp_w |
| **var74-77** | Enemy X Hi (4) | **Full** | ex_hi |
| **var78-79** | Physics Acc | **Full** | acc_mx, acc_my |
| **var80-99** | Star X (4 used) | **Partial** | Alloc 20, Using 4 (80-83) |
| **var100-119**| Star Y (4 used) | **Partial** | Alloc 20, Using 4 (100-103)|
| **var120-139**| Star Color (4 used)| **Mixed** | Alloc 20, Using 4 (120-123) **NOTE: ey_hi at 130**|
| **var130-133**| Enemy Y Hi (4) | **Full** | ey_hi (Inside unused star block)|
| **var140-149**| Player/Game State | **Full** | lives, shield, timer, internal vars |
| **var150-156**| Asteroid | **Full** | ax, ay, vx, vy, life, hi bytes |
| **var157-159**| BCD Display | **Partial** | 158, 159 mostly free? |
| **var160-169**| Enemy Bullets/Life | **Partial** | ebul_vy(160-163), eblife(164-167) |
| **var170-175**| Hi Bytes & Cam | **Full** | px_hi, cam vars |
| **var180-195**| Bullet Hi Bytes | **Full** | bul/ebul hi bytes |
| **var196** | Temp Hi | **Full** | temp_val_hi |
| **var197-213**| Screen Coords | **Full** | Cached render coords & visibility |
| **var214-219**| *Unused* | **FREE** | Available |
| **var220-222**| Config | **Full** | move_mask, cooldown, level |
| **var223-227**| Prizes (5) | **Full** | prize_active flags |
| **var228-230**| Music | **Full** | ptr_lo, ptr_hi, active |

## Detailed Allocation (Sorted by Var Number)

### Core & Player Bullets (0-39)
- `var0-17`: Globals (px, py, frame, etc.)
- `var18-21`: `bul_x` (4)
- `var22-25`: `bul_y` (4)
- `var26-29`: `bul_vx` (4)
- `var30-33`: `bul_vy` (4)
- `var34-37`: `blife` (4)
- `var38`: `temp_bx`
- `var39`: `temp_by`

### Enemies (40-59)
- `var40-43`: `ex` (4)
- `var44-47`: `ey` (4)
- `var48-51`: `evx` (4)
- `var52-55`: `evy` (4)
- `var56-59`: `elife` (4)

### Enemy Bullets & Temp (60-73)
- `var60-63`: `ebul_x` (4)
- `var64-67`: `ebul_y` (4)
- `var68-71`: `ebul_vx` (4)
- `var72`: `ecooldown`
- `var73`: `temp_w`

### Enemy High Bytes (74-79)
- `var74-77`: `ex_hi` (4)
- `var78`: `acc_mx`
- `var79`: `acc_my`

### Starfield & Collision Zone (80-139)
**NOTE:** Stars reduced to 4 elements.
- `var80-83`: `star_x` (using 4, allocated range 80-99)
- `var84-99`: *Unused* (reserved for more stars)
- `var100-103`: `star_y` (using 4, allocated range 100-119)
- `var104-119`: *Unused*
- `var120-123`: `star_c` (using 4, allocated range 120-139)
- `var124-129`: *Unused*
- `var130-133`: `ey_hi` (4) **(Defined here safely)**
- `var134-139`: *Unused*

### Game State (140-149)
- `var140-142`: `sc1, sc2, sc3` (Star cycle)
- `var143`: `cycle_state`
- `var144`: `fighters_remaining`
- `var145`: `player_shield`
- `var146`: `bcd_score`
- `var147`: `player_lives`
- `var148`: `rand_val`
- `var149`: `screen_timer`

### Asteroid (150-156)
- `var150`: `ax`
- `var151`: `ay`
- `var152`: `avx`
- `var153`: `avy`
- `var154`: `alife`
- `var155`: `ax_hi`
- `var156`: `ay_hi`

### BCD Display (157-159)
- `var157`: `fighters_bcd`
- `var158`: `shield_bcd`
- `var159`: *Unused*

### Enemy Bullets 2 (160-169)
- `var160-163`: `ebul_vy` (4)
- `var164-167`: `eblife` (4)
- `var168-169`: *Unused*

### Player High Bytes & Camera (170-179)
- `var170`: `px_hi`
- `var171`: `py_hi`
- `var172`: `cam_x`
- `var173`: `cam_x_hi`
- `var174`: `cam_y`
- `var175`: `cam_y_hi`
- `var176-179`: *Unused*

### Bullet High Bytes (180-196)
- `var180-183`: `bul_x_hi` (4)
- `var184-187`: `bul_y_hi` (4)
- `var188-191`: `ebul_x_hi` (4)
- `var192-195`: `ebul_y_hi` (4)
- `var196`: `temp_val_hi`

### Screen Coordinates (Render Cache) (197-213)
- `var197`: `px_scr`
- `var198`: `py_scr`
- `var199-202`: `ex_scr` (4)
- `var203-206`: `ey_scr` (4)
- `var207`: `ax_scr`
- `var208`: `ay_scr`
- `var209-212`: `e_on` (4)
- `var213`: `a_on`

### FREE ZONE (214-219)
- `var214-219`: *Available*

### Config & Safe Zone (220-230)
- `var220`: `enemy_move_mask`
- `var221`: `enemy_fire_cooldown`
- `var222`: `current_level`
- `var223-227`: `prize_active` 0-4
- `var228`: `music_ptr_lo`
- `var229`: `music_ptr_hi`
- `var230`: `music_active`

## Configuration Log
- **Stars:** Reduced to 4 to save performance. Memory block 80-139 is largely empty, but `ey_hi` is planted at 130.
- **Enemies:** 4 max.
- **Bullets:** 4 player, 4 enemy.
