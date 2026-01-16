# Variable Memory Map - AtariTrader

## Purpose
Track all variable assignments to prevent memory collisions. **Critical for debugging:** Arrays occupy consecutive memory locations!

## Variable Allocation (sorted by var number)

### var40-59: Projectiles & Related
- `var40-43`: `bul_x` - Player bullet X positions (4 elements)
- `var44-47`: `bul_y` - Player bullet Y positions (4 elements)
- `var48-51`: `evx` - Enemy velocity X (4 elements)
- `var52-55`: `evy` - Enemy velocity Y (4 elements)
- `var56-59`: `elife` - Enemy life states (4 elements)

### var60-73: Enemy Bullets & Temp
- `var60-63`: `ebul_x` - Enemy bullet X positions (4 elements)
- `var64-67`: `ebul_y` - Enemy bullet Y positions (4 elements)
- `var68-71`: `ebul_vx` - Enemy bullet velocity X (4 elements)
- `var72`: `ecooldown` - Enemy firing cooldown
- `var73`: `temp_w` - Temporary variable

### var74-79: Enemy High Bytes & Safety
- `var74-77`: `ex_hi` - Enemy X high bytes (4 elements) **NOTE: COLLISION - var74 was also used for enemy_move_mask (FIXED)**
- `var78`: `acc_mx` - Physics accumulator X
- `var79`: `acc_my` - Physics accumulator Y
- **var76-79**: Marked as "Safety Buffer" but var74-77 occupied

### var80-109: Starfield
- `var80-83`: `star_x` - Star X positions (4 elements)
- `var84-87`: `star_y` - Star Y positions (4 elements)
- `var88-91`: `star_pal` - Star palettes (4 elements)

### var110-149: Player & Misc
- `var110-113`: `ex` - Enemy X positions (4 elements)
- `var114-117`: `ey` - Enemy Y positions (4 elements)
- `var118-121`: `blife` - Player bullet life (4 elements)
- `var122-125`: `bul_vx` - Player bullet velocity X (4 elements)
- `var126-129`: `bul_vy` - Player bullet velocity Y (4 elements)
- `var130-133`: `ey_hi` - Enemy Y high bytes (4 elements)
- `var140`: `sc1` - Star cycle state 1
- `var141`: `sc2` - Star cycle state 2
- `var142`: `sc3` - Star cycle state 3
- `var143`: `cycle_state` - Cycle state
- `var144`: `fighters_remaining` - Enemies to destroy (was score_p)
- `var145`: `player_shield` - Shield value 0-99 (was score_e)
- `var146`: `bcd_score` - BCD conversion temp
- `var147`: `player_lives` - Lives remaining
- `var148`: `rand_val` - Random value
- `var149`: *(appears unused)*

### var150-179: Asteroid & BCD
- `var150`: `ax` - Asteroid X position
- `var151`: `ay` - Asteroid Y position
- `var152`: `avx` - Asteroid velocity X
- `var153`: `avy` - Asteroid velocity Y
- `var154`: `alife` - Asteroid life
- `var155`: `ax_hi` - Asteroid X high byte
- `var156`: `ay_hi` - Asteroid Y high byte
- `var157`: `fighters_bcd` - BCD version for display
- `var158`: `shield_bcd` - BCD version for display
- `var159`: *(appears unused)*
- `var160-163`: `ebul_vy` - Enemy bullet velocity Y (4 elements, moved to safe zone)
- `var164-167`: `eblife` - Enemy bullet life (4 elements) **NOTE: COLLISION - var166 was used for current_level (FIXED)**
- `var170`: `px_hi` - Player X high byte
- `var171`: `py_hi` - Player Y high byte
- `var172`: `cam_x` - Camera X
- `var173`: `cam_x_hi` - Camera X high byte
- `var174`: `cam_y` - Camera Y
- `var175`: `cam_y_hi` - Camera Y high byte

### var180-220: Bullet High Bytes & Arrays
- `var180-183`: `bul_x_hi` - Player bullet X high bytes (4 elements)
- `var184-187`: `bul_y_hi` - Player bullet Y high bytes (4 elements)
- `var188-191`: `ebul_x_hi` - Enemy bullet X high bytes (4 elements)
- `var192-195`: `ebul_y_hi` - Enemy bullet Y high bytes (4 elements)
- `var196`: `temp_val_hi` - Temporary high byte
- `var197`: `px_scr` - Player X screen position
- `var198`: `py_scr` - Player Y screen position
- `var199-202`: `ex_scr` - Enemy X screen positions (4 elements)
- `var203-206`: `ey_scr` - Enemy Y screen positions (4 elements)
- `var207`: `ax_scr` - Asteroid X screen position
- `var208`: `ay_scr` - Asteroid Y screen position
- `var209-212`: `e_on` - Enemy visibility flags (4 elements)
- `var213`: `a_on` - Asteroid visibility flag

### var220-227: Difficulty Config & Prizes (SAFE ZONE)
- `var220`: `enemy_move_mask` - Frame mask for movement speed (MOVED from var74)
- `var221`: `enemy_fire_cooldown` - Cooldown frames after firing (MOVED from var75)
- `var222`: `current_level` - Current level 1-5 (MOVED from var166)
- `var223`: `prize_active0` - Prize 0 state (MOVED from var150)
- `var224`: `prize_active1` - Prize 1 state (MOVED from var151)
- `var225`: `prize_active2` - Prize 2 state (MOVED from var152)
- `var226`: `prize_active3` - Prize 3 state (MOVED from var153)
- `var227`: `prize_active4` - Prize 4 state (MOVED from var154)

## Collisions Found & Fixed

### 1. enemy_move_mask (var74) vs ex_hi array (var74-77) ✅
- **Issue**: Difficulty config was being overwritten by enemy positions
- **Fix**: Moved `enemy_move_mask` to var220

### 2. enemy_fire_cooldown (var75) vs ex_hi array (var74-77) ✅
- **Issue**: Fire cooldown was being overwritten by enemy positions
- **Fix**: Moved `enemy_fire_cooldown` to var221

### 3. current_level (var166) vs eblife array (var164-167) ✅
- **Issue**: Level number was being overwritten by enemy bullet life states
- **Fix**: Moved `current_level` to var222

### 4. prize_active vars (var150-154) vs asteroid vars (var150-156) ✅
- **Issue**: Prize variables colliding with asteroid position/velocity/life data
- **Fix**: Moved `prize_active0-4` to var223-227

## Recommendations

1. **Keep var220-255 as "safe zone"** for global state variables
2. **Always check array ranges** when adding new variables
3. **Declare all persistent variables at global scope**, not in subroutines
4. **Document array sizes** in comments: `dim array_name = varN ; varN-varM (size elements)`

## Memory Usage Summary
- **Used ranges**: 40-213, 220-222
- **Safe for allocation**: 214-219, 223+
- **Potentially fragmented**: 149, 159
