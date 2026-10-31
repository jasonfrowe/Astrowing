   set romsize 48k
   
   set 7800header 'name Astro Wing Starfighter'

   ; High score table (High Score Cart / AtariVox-SaveKey). $4157 = 'AW'.
   ; Reserve the number in the AtariAge thread before release:
   ; https://atariage.com/forums/topic/128432-high-score-cart-values/
   set hssupport $4157
   set hsgamename 'astro wing'
   set hsdifficultytext 'easy' 'pro' 'easy' 'pro'
   set hsscoresize 6
   set hsgameranks 100000 'ace' 50000 'commander' 25000 'captain' 10000 'pilot' 0 'cadet'
   set zoneheight 16

   displaymode 160A
   set doublewide on
   set pokeysupport $450
 
   ; Import graphics
   ; Block 0 ($C000): title banner (240 bytes a line) + small sprites (14)
   incbanner graphics/title_screen_conv.png 160A 0 1 2 3
   incgraphic graphics/bullet_conv.png
   incgraphic graphics/fighter.png
   incgraphic graphics/blue_fighter.png
   incgraphic graphics/Energy.png
   ; Explosion Frames (Split for animation)
   incgraphic graphics/fighter_explode_00_conv.png
   incgraphic graphics/fighter_explode_01_conv.png
   incgraphic graphics/fighter_explode_02_conv.png
   incgraphic graphics/fighter_explode_03_conv.png
   incgraphic graphics/fighter_explode_04_conv.png
   incgraphic graphics/fighter_explode_05_conv.png
   incgraphic graphics/fighter_explode_06_conv.png
   incgraphic graphics/fighter_explode_07_conv.png

   ; Block 1 ($E000): the high score font must be the first graphic in its block
   newblock
   incgraphic graphics/hiscorefont.png 320A
   incgraphic graphics/sprite_spaceship1.png
   incgraphic graphics/sprite_spaceship2.png
   incgraphic graphics/sprite_spaceship3.png
   incgraphic graphics/sprite_spaceship4.png
   incgraphic graphics/sprite_spaceship5.png
   incgraphic graphics/sprite_spaceship6.png
   incgraphic graphics/sprite_spaceship7.png
   incgraphic graphics/sprite_spaceship8.png
   incgraphic graphics/sprite_spaceship9.png
   incgraphic graphics/sprite_spaceship10.png
   incgraphic graphics/sprite_spaceship11.png
   incgraphic graphics/sprite_spaceship12.png
   incgraphic graphics/sprite_spaceship13.png
   incgraphic graphics/sprite_spaceship14.png
   incgraphic graphics/sprite_spaceship15.png
   incgraphic graphics/sprite_spaceship16.png

   incgraphic graphics/arrows_01.png 160A
   incgraphic graphics/arrows_02.png 160A
   incgraphic graphics/arrows_03.png 160A
   incgraphic graphics/arrows_04.png 160A
   
   incgraphic graphics/asteroid_M_conv.png
   incgraphic graphics/BossV2_01.png
   incgraphic graphics/BossV2_02.png
   incgraphic graphics/BossV2_03.png
   incgraphic graphics/BossV2_04.png
   
   ; Define custom mapping for scoredigits (0-9 + A-F)
   incgraphic graphics/unified_font.png 160A 0 1 2 3
   alphachars '0123456789 ABCDEFGHIJKLMNOPQRSTUVWXYZ.!?,"$():*+-/<>'
   
   ; ---- Dimensions ----
   dim px = var0
   dim py = var1
   dim vx_p = var2
   dim vx_m = var3
   dim vy_p = var4
   dim vy_m = var5
   dim rx = var6
   dim ry = var7
   dim angle = var8 
   dim shpfr = var9
   dim rot_timer = var10
   dim move_step = var11
   dim temp_acc = var12
   dim frame = var13
   dim common = var14
   dim temp_v = var15
   dim bcooldown = var16
   dim iter = var17
   dim temp_bx = var38
   dim temp_by = var39

   ; Bullet Arrays (mapped to var space)
   ; Positions are 8.8 fixed point for smooth movement (using word if possible, but let's stick to byte for coords + remainder logic if we want, or just simple integers for bullets?)
   ; Bullets are fast (4px/frame), so integer math is probably fine, but we need direction.
   ; Let's use the same dual-velocity system or just simple signed logic if possible.
   ; To match player physics style (dual-var) might be complex for arrays.
   ; Let's use simple Signed 8-bit Math for bullets: 0=Stop, 1-127=Pos, 128-255=Neg.
   dim bul_x = var18 ; uses 18, 19, 20, 21
   dim bul_y = var22 ; uses 22, 23, 24, 25
   dim bul_vx = var26 ; uses 26, 27, 28, 29
   dim bul_vy = var30 ; uses 30, 31, 32, 33
   dim blife = var34 ; uses 34, 35, 36, 37
   
   dim player_lives = $254B ; Lives Variable (Safe from collisions)

   ; Enemy Bullet Variables (Pool of 2)
   ; Using var60+
   dim ebul_x  = var60 ; 60-63 ... Need High Bytes for these too?
   ; For now, keep bullets/enemies strictly Screen Space?
   ; User said "Infinite World". Everything needs to be World Space eventually.
   ; Let's keep them Screen Space temporarily to confirm Player scrolling first.
   dim ebul_y  = var64
   dim ebul_vx = var68 ; 68-71
   dim ebul_vy = $2560 ; Moved to 160 safe zone
   dim eblife  = $2564 ; 164-167

   ; High Byte Arrays for Bullets (World Coords)
   ; dim bul_x_hi = $2580 ; Removed (Unused)
   ; dim bul_y_hi = $2584 ; Removed (Unused)
   ; dim ebul_x_hi = $2588 ; Removed (Unused)
   ; dim ebul_y_hi = $258C ; Removed (Unused)
   dim temp_val_hi = $2590
   dim ecooldown = var72
   dim temp_w = var73
   
   ; Level Difficulty Config (MOVED to avoid collision with ex_hi at var74-77)
   dim enemy_move_mask = $25A2     ; Frame mask for enemy movement speed
   dim enemy_fire_cooldown = $25A3 ; Cooldown frames after enemy fires
   
   dim asteroid_move_mask = $25AD
   dim asteroid_base_speed = $25AE
   
   ; Boss Variables (Phase 4)
   dim boss_x = $25B0
   dim boss_y = $25B1
   dim boss_hp = $25B2
   dim boss_state = $25B3
   dim bvx = $25B4           ; Boss Velocity X
   dim bvy = $25B5           ; Boss Velocity Y
   dim boss_x_hi = $25B6     ; Boss X High Byte (World)
   dim boss_y_hi = $25B7     ; Boss Y High Byte (World)
   dim boss_scr_x = $25B8    ; Boss Screen X (Cached)
   dim boss_scr_y = $25B9    ; Boss Screen Y (Cached)
   dim ready_flag = $254E    ; Level start ready flag (1=waiting, 0=active)
   dim boss_on = $25BA       ; Boss Visible Flag
   dim boss_fighter_timer = $25BB ; Timer for fighter spawning
   dim boss_move_phase = $25BC    ; Boss Oscillation Phase
   dim boss_osc_x = $2568 ; Targeting Oscillation X
   dim boss_osc_y = $2569 ; Targeting Oscillation Y
   dim boss_acc_x = $256A ; Boss Sub-pixel X
   dim boss_acc_y = $256B ; Boss Sub-pixel Y
   dim boss_checkpoint = $256C ; Boss Health Gate (0=Full, 1=Half)
   
   ; Safety Buffer 76-79
      ; Starfield Variables (4 stars used)
   ; Moved to var80+ to prevent memory corruption from scratch vars
   dim star_x = var80 ; 80-83 (Array [4]) 
   dim star_y = $2500 ; 2500-2519
   dim star_c = $2520 ; 2520-2539
   dim sc1 = $2544
   dim sc2 = $2545
   dim sc3 = $2546
   dim cycle_state = $2547

   ; Enemy Variables (Single Enemy for now)
   ; Enemy Variables (Pool of 4)
   ; var40-59 (20 bytes)
   dim ex = var40 ; 40,41,42,43
   dim ey = var44 ; 44,45,46,47
   dim evx = var48 ; 48,49,50,51
   dim evy = var52 ; 52,53,54,55
   dim elife = var56 ; 56,57,58,59
   
   ; High Byte Arrays for Enemies (World Support)
   dim ex_hi = var74 ; 74,75,76,77 (Using Buffer)
   dim ey_hi = $2540 ; 2540-2543
   
   ; Physics Accumulators (Dedicated)
   dim acc_mx = var78
   dim acc_my = var79

   ; Music State (the player's own state is on the $2600 page)
   dim music_ptr_hi = $25AB ; 0 = PlayMusic picks and starts a song, 1 = playing
   dim current_song = $25AF ; 1=Song_01, 2=Song_02, 3=Song_03, 4=Boss
   
   
   
   dim rand_val = $254C
   dim screen_timer = $254D ; Generic timeout timer
   
   ; Asteroid Variables (Single Large Asteroid)
   ; Moved to var150 to make room for enemy arrays
   dim ax = $2550
   dim ay = $2551
   dim avx = $2552
   dim avy = $2553
   dim alife = $2554
   dim ax_hi = $2555
   dim ay_hi = $2556
   dim asteroid_timer = $2559  ; 4-second despawn timer (Safe address)
   dim boss_asteroid_cooldown = $255A ; Cooldown for boss asteroid throws (Safe address)
   dim boss_attack_timer = $255A      ; Shared timer for boss attacks
   dim ast_acc_x = $255B ; Asteroid sub-pixel accumulator X
   dim ast_acc_y = $255C ; Asteroid sub-pixel accumulator Y
   
   ; Blue Fighter Variables (Separate Pool of 2)
   dim bfx = $25D8      ; 25D8-25D9 - Blue Fighter X (Low)
   dim bfy = $25DA      ; 25DA-25DB - Blue Fighter Y (Low)
   dim bflife = $25DC   ; 25DC-25DD - Blue Fighter Life (0=dead, 1=alive)
   dim bfx_hi = $25DE   ; 25DE-25DF - Blue Fighter X (High)
   dim bfy_hi = $25E0   ; 25E0-25E1 - Blue Fighter Y (High)
   dim bfby   = $25E2   ; 25E2-25E3 - Base Y for oscillation
   dim bfx_scr = $25E4  ; 25E4-25E5 - Screen X
   dim bfy_scr = $25E6  ; 25E6-25E7 - Screen Y
   dim bf_on   = $25E8  ; 25E8-25E9 - Visible flag
   dim bfx_acc = $25EA  ; 25EA-25EB - Acc X
   dim bfy_acc = $25EC  ; 25EC-25ED - Acc Y
   
   ; Blue Fighter Bullet (Single Shared Bullet)
   dim bf_bul_x = $25EE
   dim bf_bul_y = $25EF
   dim bf_bul_vx = $25F0
   dim bf_bul_vy = $25F1
   dim bf_bul_life = $25F2
   dim bf_fire_cooldown = $25F3

   ; Energy Item Variables ($25F4-$25F9)
   dim energy_x = $25F4
   dim energy_y = $25F5
   dim energy_x_hi = $25F6
   dim energy_y_hi = $25F7
   dim energy_on = $25F8
   dim bf_kill_count = $25F9
   dim energy_timer = $25FA ; 4-second timeout timer

   ; HUD bars: RAM text plotted once into the saved screen, so changing
   ; these bytes updates the bars with no re-plotting (see update_bars)
   dim shield_bar = $25BD ; 10 chars
   dim boss_bar = $25C7   ; 10 chars (must follow shield_bar)
   dim arrow_x = $25D1    ; boss indicator, worked out in calc_boss_indicator
   dim arrow_y = $25D2
   dim arrow_f = $25D3    ; 0-3 = left/up/right/down, 255 = hidden
   dim cached_bossbar = $25D4 ; 1 while the boss bar is in the saved screen
   dim attract_timer = $25D5  ; title time before the high score tables (2 frames a tick)
   dim hs_mute = $25D6        ; 1 = cancel TIA sound effects (initials entry clicks)


   ; Aliases for plotsprite usage
   dim bul_x0 = var18 : dim bul_x1 = var19 : dim bul_x2 = var20 : dim bul_x3 = var21
   dim bul_y0 = var22 : dim bul_y1 = var23 : dim bul_y2 = var24 : dim bul_y3 = var25
   dim blife0 = var34 : dim blife1 = var35 : dim blife2 = var36 : dim blife3 = var37

   ; Cached Render Coordinates (Optimization)
   dim px_scr = $2591
   dim py_scr = $2592
   dim ex_scr = $2593 ; 199-202
   dim ey_scr = $2597 ; 203-206
   dim ax_scr = $259B
   dim ay_scr = $259C
   dim e_on   = $259D ; 209-212
   dim a_on   = $25A1



   ; 0 = inactive, >0 = active frames
   
   ; Remainder arrays for bullets (optional, if we want sub-pixel accuracy)
   ; For 4px/frame speed, sub-pixel is less critical, but angles might need it.
   ; Let's try without reminders first for simplicity/RAM saving.


cold_start
   ; Wait for Reset button to be released!
reset_release_wait
   if switchreset then goto reset_release_wait
   
   gosub StopMusic ; Ensure music state is clean (also sets music_ptr_hi = 0)

title_restart
   ; (after high score entry we come in here, so the title song keeps playing)
   screen_timer = 60 ; 1s input delay
   attract_timer = 0
   hs_mute = 0
   boss_state = 0 ; Reset boss state (prevents music logic from thinking boss is active)
   asteroid_timer = 0 ; Reset rotation timer
   boss_asteroid_cooldown = 0 ; Reset rotation timer
   
    if current_song = 0 then current_song = 1 ; Default to song 1 on first boot only


   gosub set_palettes
   
   ; Initialize difficulty settings (will be overridden by set_level_config)
   enemy_move_mask = 1        ; Default: slow movement
   enemy_fire_cooldown = 60
   
   asteroid_move_mask = 3
   asteroid_base_speed = 1
   
   ; Sound channelst: slow fire

   ; Game State Variables
   dim fighters_remaining = $2548  ; Enemies left to destroy (was score_p)
   dim player_shield = $2549       ; Current shield value 0-99 (was score_e)
   dim bcd_score = $254A           ; Temporary for BCD conversion
   dim current_level = $25A4       ; Current level (1-5) - moved from var166 (collision with eblife array)
   
   ; Prize Collection System (moved to safe zone var223-227)
   dim prize_active0 = $25A5
   dim prize_active1 = $25A6
   dim prize_active2 = $25A7
   dim prize_active3 = $25A8
   dim prize_active4 = $25A9
   
   ; Cached BCD Variables (Optimization)
   dim fighters_bcd = $2557        ; BCD version for display (was score_p_bcd)
   
   ; UI Cache Variables (Bug Fix #3: Optimize plotchars)
   dim cached_lives = $2572        ; Last rendered player_lives value
   dim cached_level = $2573        ; Last rendered current_level value
   dim cached_boss_hp = $2574      ; Last rendered boss_hp value
    dim cached_shield = $2575       ; Last rendered shield value   
   ; Player High Bytes
   dim px_hi = $2570
   dim py_hi = $2571
   
   ; Camera Removed
   ; Global Coords Only

   ; Initialize music rotation timer (2 minutes = 7200 frames)
    dim game_difficulty = $2558 ; 0=Pro, 1=Easy
   asteroid_timer = 0
   boss_asteroid_cooldown = 0

title_loop
    current_level = 0 ; Ensure title music rotation works
    ; Wait for button release first (prevent skipping from game over/win screens)
title_release_wait
    if joy0fire1 || switchreset then goto title_release_wait

    
    clearscreen
    ; Reset critical sprite state to hide game objects
    alife=0
    for iter=0 to 3
       elife[iter]=0
    next
    
    ; Draw Title Graphic (Banner)
    plotbanner title_screen_conv 7 0 46
    
    ; Version Text (Bottom of Screen - Zone 11)
    characterset unified_font
    plotchars 'VERSION' 1 12 11
    plotchars '*+-/<' 7 60 1
    plotchars '20261030' 1 84 11
    
    ; Difficulty Display
    plotchars 'DIFFICULTY' 1 20 9
    if switchleftb then plotchars 'EASY' 5 108 9 else plotchars 'PRO ' 5 108 9
    
    ; Draw Score
    plotvalue unified_font 0 score0 6 56 0
    
    drawscreen
    
    ; Hue Cycle Animation (Safe calculation)
    ; C1 (Base C, Lum 8)
    temp_acc = frame / 4
    temp_v = (12 + temp_acc) & 15
    temp_v = (temp_v * 16) + 8
    P7C1 = temp_v
    
    ; C2 (Base 4, Lum 6)
    temp_v = (4 + temp_acc) & 15
    temp_v = (temp_v * 16) + 6
    P7C2 = temp_v
    
    ; C3 (Base 1, Lum 12[C])
    temp_v = (1 + temp_acc) & 15
    temp_v = (temp_v * 16) + 12
    P7C3 = temp_v

    if joy0fire1 then goto restore_pal_game
    
    ; Music Rotation Timer (2 Minutes)
   ; Use frame counter to tick seconds
   frame = frame + 1
   
   ; Reuse asteroid vars for 16-bit timer (Safety: cleared in init_game)
   asteroid_timer = asteroid_timer + 1 ; Lo Byte
   if asteroid_timer = 0 then boss_asteroid_cooldown = boss_asteroid_cooldown + 1 ; Hi Byte
   
   if boss_asteroid_cooldown >= 28 then gosub rotate_music
   ; After ~8.5s of title, show the high score tables
   if frame & 1 then attract_timer = attract_timer + 1 : if attract_timer = 0 then goto title_attract

    gosub PlayMusic ; Continue music playback (allows rotation to take effect)

    if !switchreset then goto title_no_reset
title_reset_wait
    if switchreset then goto title_reset_wait
    goto restore_pal_game
title_no_reset
    if screen_timer > 0 then screen_timer = screen_timer - 1
    if screen_timer > 0 then goto title_loop
    
    goto title_loop

restore_pal_game
   P7C1=$C8: P7C2=$46: P7C3=$1C
   goto init_game

set_palettes
   ; (also needed after drawhiscores, which changes the palettes)
   P0C1=$26: P0C2=$24: P0C3=$04 ; Background/UI
   P1C1=$C2: P1C2=$C6: P1C3=$CA ; Player Bullets (Green)
   P2C1=$04: P2C2=$08: P2C3=$0C ; Asteroids (Greys)
   P3C1=$B4: P3C2=$46: P3C3=$1C ; Enemy (Green, Red, Yellow)
   P4C1=$08: P4C2=$0C: P4C3=$0F ; Stars
   P5C1=$34: P5C2=$86: P5C3=$0A ; Spaceship
   P6C1=$42: P6C2=$46: P6C3=$4A ; Enemy Bullets (Red)
   P7C1=$C8: P7C2=$46: P7C3=$1C ; Title Screen (Vibrant)
   BACKGRND=$00
   return

title_attract
   ; The table for the difficulty on the switch, then the other one (~6s
   ; each), then the title again. Fire during a table goes straight back.
   if switchleftb then gamedifficulty = 0 else gamedifficulty = 1
   drawhiscores attract
   if joy0fire1 then goto title_attract_done
   gamedifficulty = gamedifficulty ^ 1
   drawhiscores attract
title_attract_done
   gosub set_palettes
   attract_timer = 0
   goto title_loop

enter_hiscore
   ; Game over or won: initials entry if the score made the table, to the
   ; title song (which carries on into the title screen)
   gosub StopMusic
   boss_state = 0 : current_level = 0
   gosub PlayMusic
   if game_difficulty = 1 then gamedifficulty = 0 else gamedifficulty = 1
   hs_mute = 1 ; no letter clicks, just the music
   drawhiscores single
   hs_mute = 0
   gosub set_palettes
   goto title_restart

rotate_music
   boss_asteroid_cooldown = 0
   asteroid_timer = 0
   
   ; Cycle through all 3 songs: 1 → 2 → 3 → 1
   current_song = current_song + 1
   if current_song > 3 then current_song = 1
   
   gosub StopMusic
   music_ptr_hi = 0
   gosub PlayMusic
   return


init_game
     ; Clear any previous screen content (title, story, etc)
     clearscreen
     
     ; Stop title music
     gosub StopMusic
     music_ptr_hi = 0 ; Force reset on next PlayMusic call
     ; Initialize Variables (Reset)
     ; Initialize Player at (256+80, 256+90) -> Center of 512x512
     px = 72 : px_hi = 1
     py = 90 : py_hi = 1
     
    ; Capture Difficulty Setting (Lock it in)
    if switchleftb then game_difficulty = 1 else game_difficulty = 0
     
     
     ; Camera removed (Player Centric)
    
    ; Initialize Lives
    player_lives = 3  ; Start with 3 lives (display will show 2 hearts = 2 extra lives)
    
    ; Initialize Level
    current_level = 1
    boss_checkpoint = 0 ; Reset Health Gate
    
    ; Initialize UI cache (Bug Fix #3)
    ; Set to invalid values to force initial draw
    cached_lives = 255
    cached_level = 255
    
    ; Initialize Game State
    player_shield = 100
    boss_state = 0
    boss_on = 0

    
    fighters_remaining = 20  ; Level 1 starting value
    fighters_bcd = converttobcd(20)
    
    gosub set_level_config
    
    
    score0 = 0
    ; Initialize boss (Level 6)
    
    ; Initialize prize system (all active)
    prize_active0 = 1
    prize_active1 = 1
    prize_active2 = 1
    prize_active3 = 1
    prize_active4 = 1
    
    energy_on = 0
    bf_kill_count = 0
    ; Init Camera centered on 80,90 initially? 
    ; Let's start camera at 0,0 for now to match legacy behavior
     ; Init Done
    ; Init Done
    
    ; Init Physics (Prevent Jitter)
    vx_p = 0 : vx_m = 0 : acc_mx = 0
    vy_p = 0 : vy_m = 0 : acc_my = 0
    
    ; Other vars
    angle = 0
    rx = 0
    ry = 0
    temp_bx = 0
    temp_by = 0
    angle = 0
    rot_timer = 0
    shpfr = 0
    frame = 0
    bcooldown = 0
   
   ; Clear bullets
   for iter = 0 to 3
      blife[iter] = 0
   next
   
   alife = 0 ; Asteroid inactive
   ; ecooldown is set by set_level_config
   eblife[0] = 0 : eblife[1] = 0
   
   ; Clear enemies
   elife[0]=0 : elife[1]=0 : elife[2]=0 : elife[3]=0
   
   ; Clear Blue Fighters (separate pool)
   bflife[0]=0 : bflife[1]=0
   bf_bul_life = 0
   bf_fire_cooldown = 0


   
   gosub init_stars
   
   ; Initial UI draw (force first render)
   gosub update_bars
   gosub refresh_static_ui
   
   ready_flag = 2


main_loop
   clearscreen
   restorescreen  ; Restore static UI (lives, treasures, boss hp)
   
   ; score_p = cam_x ; DEBUG
   ; score_e = px    ; DEBUG
   
   ; ---- Frame Counter ----
   frame = frame + 1

   ; ---- Level Start Button Wait ----
   ; (PRESS FIRE is plotted with the rest of the frame: plotting waits for vblank)
   if ready_flag = 2 then if !joy0fire1 then ready_flag = 1
   if ready_flag = 1 then if joy0fire1 then ready_flag = 0
   if ready_flag > 0 then goto skip_enemy_updates

ready_done

   
   if switchreset then goto cold_start

   ; ---- Rotation Control ----
   if rot_timer > 0 then rot_timer = rot_timer - 1
   if rot_timer = 0 then gosub check_rotation
   shpfr = angle

   ; ---- Thrust Control ----
   if joy0up then gosub apply_thrust

   ; ---- Firing Control ----
   if bcooldown > 0 then bcooldown = bcooldown - 1
   ; joy0fire1 is the first button
   if joy0fire1 && bcooldown = 0 then gosub fire_bullet

   ; ---- Neutralize Forces ----
   gosub neutralize_forces
   
   ; ---- Starfield Update ----
   gosub cycle_stars
   
   ; ---- Physics Update ----

   ; ---- Energy Orb Timeout ----
   if energy_on = 1 then energy_timer = energy_timer - 1 : if energy_timer = 0 then energy_on = 0

   ; ---- Physics Update (Shifting World) ----
   ; Calculate Global Scroll Deltas (temp_bx, temp_by)
   temp_bx = 0
   temp_by = 0

   ; X Axis
   ; Positive
   temp_v = vx_p + rx
   rx = temp_v & 63
   temp_w = temp_v / 64
   
   if temp_w > 0 then temp_bx = temp_w
   
   ; Negative
   temp_v = vx_m + acc_mx
   acc_mx = temp_v & 63
   temp_w = temp_v / 64
   
   if temp_w > 0 then temp_bx = 0 - temp_w ; Signed result
   
   ; Y Axis
   ; Positive (Down)
   temp_v = vy_p + ry
   ry = temp_v & 63
   temp_w = temp_v / 64
   
   if temp_w > 0 then temp_by = temp_w
   
   ; Negative (Up)
   temp_v = vy_m + acc_my
   acc_my = temp_v & 63
   temp_w = temp_v / 64
   
   if temp_w > 0 then temp_by = 0 - temp_w
   
   ; ---- Blue Fighter Update (BEFORE shift) ----
   ; Self-movement must commit first so shift_universe sees updated state
   gosub update_blue_fighters
   
   ; Apply Shift to Universe
   if temp_bx <> 0 || temp_by <> 0 then gosub shift_universe


   ; ---- Bullet Update ----
   gosub update_bullets

   ; (Button wait logic handled above)

   ; ---- Enemy Update ----
   if ecooldown > 0 then ecooldown = ecooldown - 1
   gosub update_enemy
   
   ; ---- Enemy Bullet Update ----
   gosub update_enemy_bullets
   
   ; ---- Asteroid Update ----
   gosub update_asteroid
   
   
   ; Blue Fighter update now runs BEFORE shift_universe (see above)
   
   ; ---- BF Bullet Update ----
   gosub update_bf_bullet

   ; ---- BF Cooldown ----
   if bf_fire_cooldown > 0 then bf_fire_cooldown = bf_fire_cooldown - 1
   
   ; ---- Boss Update (All Levels) ----
   gosub update_boss
   
   ; ---- Collisions ----
   gosub check_collisions
   
skip_enemy_updates

   ; Check for Game State Changes (Stack Safe)
   ; If fighters cleared, check boss state
   if fighters_remaining <= 0 then if boss_state = 0 then gosub init_boss
   if fighters_remaining <= 0 then if boss_state = 5 then goto level_complete
   if player_shield <= 0 then goto lose_life

   ; ---- Friction ----
   gosub apply_friction

   ; ---- Boundaries (REMOVED - World Wraps) ----
   ; if px > 150 then px = 150 ...

   ; Blue Fighter spawn chance (temporary high rate for testing)
   temp_v = rand
   if temp_v < 25 then gosub spawn_blue_fighter
   
   ; ---- Camera Update ----

   gosub update_render_coords
   gosub update_bf_render_coords
   gosub calc_boss_indicator

    ; ---- Work that doesn't plot (runs while the screen is drawn) ----
    ; 7800basic only lets us plot during vblank (~8000 cycles), so keep
    ; everything that isn't a plot above the first plot of the frame.
    gosub PlayMusic

    ; HUD bars are RAM text in the saved screen: just rewrite their bytes
    if player_shield <> cached_shield then gosub update_bars
    if boss_hp <> cached_boss_hp then gosub update_bars

    ; Rebuild the saved screen only when lives, level or the boss bar change
    temp_v = 0 : if boss_state > 0 && boss_state < 5 then temp_v = 1
    if temp_v <> cached_bossbar then gosub refresh_static_ui
    if player_lives <> cached_lives then gosub refresh_static_ui
    if current_level <> cached_level then gosub refresh_static_ui

    ; ---- Low Health Warning (Palette Swap) ----
    if player_shield >= 20 then P5C2=$86 : goto skip_health_warn
    if (frame & 32) > 0 then P5C2=$34 else P5C2=$86
skip_health_warn

    ; ---- Draw (vblank) ----
    if ready_flag > 0 then plotchars 'PRESS FIRE' 5 40 8 : plotchars 'TO START' 5 48 9
    ; Score (Center, Palette 5)
    plotvalue unified_font 0 score0 6 56 0
    
    ; Fighters Remaining (Right, Red, Palette 5)
    plotchars 'E' 5 120 0
    plotvalue unified_font 5 fighters_bcd 2 128 0

    ; Use cached screen position
    plotsprite sprite_spaceship1 5 px_scr py_scr shpfr
     
    gosub draw_stars
    gosub draw_player_bullets
    gosub draw_enemies
    gosub draw_blue_fighters
    if energy_on <> 0 then if energy_x_hi = px_hi then if energy_y_hi = py_hi then plotsprite Energy 1 energy_x energy_y
    gosub draw_bf_bullet

     if alife > 0 then gosub draw_asteroid
     if boss_on = 1 then gosub draw_boss
     if arrow_f < 4 then plotsprite arrows_01 6 arrow_x arrow_y arrow_f
     gosub draw_enemy_bullets

     drawscreen
    goto main_loop

check_rotation
   if joy0left  then angle = angle - 1 : rot_timer = 4
   if joy0right then angle = angle + 1 : rot_timer = 4
   if angle > 250 then angle = 15
   if angle > 15 then angle = 0
   return

apply_thrust

   ; X Axis
   temp_acc = sin_table[angle]
   if temp_acc < 128 then vx_p = vx_p + temp_acc 
   if temp_acc >= 128 then temp_acc = 0 - temp_acc : vx_m = vx_m + temp_acc

   ; Y Axis (Inverted) - Subtract Cos
   temp_acc = cos_table[angle]
   if temp_acc < 128 then vy_m = vy_m + temp_acc
   if temp_acc >= 128 then temp_acc = 0 - temp_acc : vy_p = vy_p + temp_acc
   
   ; Max speed Logic
   temp_v = 120 ; Slower start
   if current_level >= 3 then temp_v = 190 ; Normal Speed
   
   if vx_p > temp_v then vx_p = temp_v
   if vx_m > temp_v then vx_m = temp_v
   if vy_p > temp_v then vy_p = temp_v
   if vy_m > temp_v then vy_m = temp_v
   return

neutralize_forces
   ; X Axis
   if vx_p = 0 || vx_m = 0 then goto skip_nx
   if vx_p < vx_m then common = vx_p else common = vx_m
   vx_p = vx_p - common
   vx_m = vx_m - common
skip_nx
   ; Y Axis
   if vy_p = 0 || vy_m = 0 then goto skip_ny
   if vy_p < vy_m then common = vy_p else common = vy_m
   vy_p = vy_p - common
   vy_m = vy_m - common
skip_ny
   return

apply_friction
   ; Snap to zero logic
   if vx_p < 2 then vx_p = 0
   if vx_p >= 2 then vx_p = vx_p - 1
   
   if vx_m < 2 then vx_m = 0
   if vx_m >= 2 then vx_m = vx_m - 1
   
   if vy_p < 2 then vy_p = 0
   if vy_p >= 2 then vy_p = vy_p - 1
   
   if vy_m < 2 then vy_m = 0
   if vy_m >= 2 then vy_m = vy_m - 1
   return

update_bullets
   for iter = 0 to 3
      if blife[iter] = 0 then goto skip_bul_move
      ; Screen Space Movement (Simple 8-bit)
      ; X Axis
      temp_v = bul_vx[iter]
      bul_x[iter] = bul_x[iter] + temp_v
      
      ; Bounds Check X (Kill if off screen)
      if bul_x[iter] > 170 then if bul_x[iter] < 240 then blife[iter] = 0

      ; Y Axis
      temp_v = bul_vy[iter]
      bul_y[iter] = bul_y[iter] + temp_v
      
      ; Bounds Check Y
      if bul_y[iter] > 200 then blife[iter] = 0
      
      ; Lifetime Check
      if blife[iter] > 0 then blife[iter] = blife[iter] - 1
skip_bul_move
   next
   return


fire_bullet
   ; Find free slot
   for iter = 0 to 3
      if blife[iter] = 0 then goto spawn_bullet
   next
   return

spawn_bullet
   blife[iter] = 60 ; Last 60 frames ~ 1 sec
   ; Screen Space Bullet Spawn (Tie to Screen)
   ; Center Bullet (Px + 8, Py + 8) -> Center of 16x16 sprite
   
   bul_x[iter] = px + 6
   bul_y[iter] = py + 6
   
   ; No Hi Bytes needed for Screen Space Bullets

   
   ; Set velocity based on angle
   ; Use sin_table values * factor ~ 10-15?
   ; sin_table current max is 6 (acceleration). 
   ; We want 4px/frame. 4 / 6 is not right.
   ; Let's just create a quick separate scaling or just use the table * 1 (too slow)
   ; The table 'sin_table' has values like 0,2,4,6.
   ; If we treat them as pixel speed, 6px/frame is very fast. 4px/frame is target.
   ; Let's assume table values are roughly "direction * magnitude".
   ; We can divide by 2? 6/2 = 3px/frame. Close enough.
   
   ; Set velocity based on angle
   ; Use sin_table values directly (Max 6px/frame)
   ; Previous logic divided by 2 (Max 3px/frame) which was slower than player.
   
   ; Wait, 7800Basic doesn't handle negative assignment well in one line?
   ; Let's respect the table format.
   
   temp_v = sin_table[angle]
   ; Table: 0, 2, 4, 6... 254(-2), 252(-4)...
   ; Just copy it directly?
   ; Yes, table is already in signed byte format.
   bul_vx[iter] = temp_v
   
   temp_v = cos_table[angle]
   ; Invert logic for Y? 
   ; Cos Table: Pos (0-127) = Down. Neg (128-255) = Up.
   ; We want "Forward" to be "Up" if angle is 0?
   ; So if Cos is Positive, we want Negative Velocity.
   ; So we Negate the Cos table value.
   
   if temp_v < 128 then bul_vy[iter] = 0 - temp_v
   
   if temp_v >= 128 then temp_v = 0 - temp_v : bul_vy[iter] = temp_v
   
   ; Play sound
   playsfx sfx_laser 0
   
   bcooldown = 25 ; Slow (Level 1)
   if current_level >= 2 then bcooldown = 15 ; Normal (Level 2-4)
   if current_level >= 5 then bcooldown = 8  ; Fast (Level 5+)
   return

update_enemy
    ; Loop through all potential enemies
    for iter = 0 to 3
       if elife[iter] = 0 then goto try_spawn_enemy
       if elife[iter] > 1 then goto update_explosion_state
       
       ; --- Movement Logic (per enemy) ---
       ; Move based on level difficulty (mask checks frame bits)
       temp_v = frame & enemy_move_mask
       if temp_v > 0 then goto enemy_logic_done
       
       ; --- Inertia Logic (Strategy A) ---
       ; --- Inertia Logic (Strategy A + Squad Formation + Rotation) ---
       ; Calculate Circular Target Index (Changes every ~2s)
       temp_v = frame / 128
       temp_v = temp_v + iter
       temp_v = temp_v & 3
       
       ; Gray Code for Circular Path (0->1->3->2 : TL->TR->BR->BL)
       temp_acc = temp_v / 2
       temp_v = temp_v ^ temp_acc
       rand_val = temp_v ; Store Target Index in temp var
       
       ; Calculate Target X with Offset using Target Index
       ; Use 16-bit aware targeting: check high bytes first
       temp_w = px
       temp_v = rand_val & 1
       if temp_v > 0 then temp_w = temp_w + 30 else temp_w = temp_w - 30
       
       ; Check if in same X segment (high bytes match)
       if px_hi = ex_hi[iter] then goto same_x_segment
       
       ; Different segments - determine direction from high byte difference
       temp_acc = px_hi - ex_hi[iter]
       ; Handle 4-segment wrap: 
       ; Right direction: 1, 2 (wrap?), no.. 1 or 253 (-3) which is 3->0
       ; Left direction: 255 (-1), 254 (-2), 3 (0->3)
       
       if temp_acc = 1 then goto want_right_hb
       if temp_acc = 2 then goto want_right_hb ; Chase right if far
       if temp_acc = 253 then goto want_right_hb ; 3 -> 0 Wrap
       
       goto want_left
       
want_right_hb
       ; High bytes say go right
       temp_acc = 64  ; Positive delta to trigger right movement
       goto do_x_accel

same_x_segment
       ; Same segment - use low byte difference
       temp_acc = temp_w - ex[iter]
       
do_x_accel
       ; Accelerate every 4th frame (mask 3)
       if (frame & 3) > 0 then goto skip_accel
       
       ; X Acceleration
       if temp_acc >= 128 then goto want_left
       ; Want Right (Target +3)
       ; Increment if < 3 OR Negative (>128)
       if evx[iter] < 3 || evx[iter] > 128 then evx[iter] = evx[iter] + 1
       goto check_y_accel
want_left
       ; Want Left (Target -3 ie 253)
       ; Decrement if > 253 OR Positive (<128)
       if evx[iter] > 253 || evx[iter] < 128 then evx[iter] = evx[iter] - 1

check_y_accel
       ; Y Acceleration with Offset using Target Index (16-bit aware)
       temp_w = py
       temp_v = rand_val & 2
       if temp_v > 0 then temp_w = temp_w + 55 else temp_w = temp_w - 55
       
       ; Check if in same Y segment (high bytes match)
       if py_hi = ey_hi[iter] then goto same_y_segment
       
       ; Different segments - determine direction from high byte difference
       temp_acc = py_hi - ey_hi[iter]
       ; Handle 4-segment wrap: if diff is 1-2, go down; if diff is 254-255 (or 3), go up
       ; Down: 1, 2, 253 (3->0)
       ; Up: 255 (-1), 254 (-2), 3 (0->3)
       
       if temp_acc = 1 then goto want_down_hb
       if temp_acc = 2 then goto want_down_hb
       if temp_acc = 253 then goto want_down_hb
       
       goto want_up
       
want_down_hb
       ; High bytes say go down
       temp_acc = 64  ; Positive delta to trigger down movement
       goto do_y_accel

same_y_segment
       ; Same segment - use low byte difference
       temp_acc = temp_w - ey[iter]
       
do_y_accel
       if temp_acc >= 128 then goto want_up
       ; Want Down (Target +3)
       ; Increment if < 3 OR Negative (>128)
       if evy[iter] < 3 || evy[iter] > 128 then evy[iter] = evy[iter] + 1
       goto skip_accel
want_up
       ; Want Up (Target -3 ie 253)
       ; Decrement if > 253 OR Positive (<128)
       if evy[iter] > 253 || evy[iter] < 128 then evy[iter] = evy[iter] - 1

skip_accel
       ; Apply Velocity X
       temp_v = evx[iter]
       if temp_v >= 128 then goto apply_neg_x
       ; Pos
       ex[iter] = ex[iter] + temp_v
       if ex[iter] < temp_v then ex_hi[iter] = ex_hi[iter] + 1
       goto apply_x_done
apply_neg_x
       temp_w = 0 - temp_v
       temp_acc = ex[iter]
       ex[iter] = ex[iter] - temp_w
       if ex[iter] > temp_acc then ex_hi[iter] = ex_hi[iter] - 1
apply_x_done
       ; Wrap World X (4 segments = 1024)
       if ex_hi[iter] = 255 then ex_hi[iter] = 1
       if ex_hi[iter] >= 2 then ex_hi[iter] = 0

       ; Apply Velocity Y
       temp_v = evy[iter]
       if temp_v >= 128 then goto apply_neg_y
       ; Pos
       ey[iter] = ey[iter] + temp_v
       if ey[iter] < temp_v then ey_hi[iter] = ey_hi[iter] + 1
       goto apply_y_done
apply_neg_y
       temp_w = 0 - temp_v
       temp_acc = ey[iter]
       ey[iter] = ey[iter] - temp_w
       if ey[iter] > temp_acc then ey_hi[iter] = ey_hi[iter] - 1
apply_y_done
       ; Wrap World Y (4 segments = 1024)
       if ey_hi[iter] = 255 then ey_hi[iter] = 1
       if ey_hi[iter] >= 2 then ey_hi[iter] = 0
       
       ; Firing Chance (Global Cooldown)
       if ecooldown > 0 then goto skip_firing_chance
       
       ; Chance to fire (1 in 16 per frame)
       rand_val = frame + iter
       rand_val = rand_val & 15
       if rand_val = 0 then gosub fire_enemy_bullet
          
skip_firing_chance
       goto enemy_logic_done

update_explosion_state
   elife[iter] = elife[iter] - 1
   if elife[iter] = 1 then elife[iter] = 0 ; Done, set to Dead
   goto enemy_logic_done

try_spawn_enemy
       ; Random spawn chance (1 in 128 per frame)
       rand_val = frame & 127
       if rand_val > 5 then goto enemy_logic_done
       
do_spawn_regular_enemy
       
       ; Spawn logic inline
       elife[iter] = 1
       evx[iter] = 0 : evy[iter] = 0 ; Reset velocity
       
       ; Set High Byte to Camera High Byte (Spawn locally initially)
       ; Set High Byte to Px High Byte (Locally)
       ex_hi[iter] = px_hi
       
       ; Randomize Side (L/R) using rand
       temp_v = rand
       if temp_v < 128 then goto spawn_left
       goto spawn_right

spawn_left
       ; Spawn Left (Px - 90)
       ; 80 center + 10 margin
       temp_v = px - 90
       ex[iter] = temp_v
       if temp_v > px then ex_hi[iter] = ex_hi[iter] - 1 ; Underflow
       if ex_hi[iter] = 255 then ex_hi[iter] = 1 ; Wrap Down
       goto spawn_set_y

spawn_right
       ; Spawn Right (Px + 90)
       temp_v = px + 90
       ex[iter] = temp_v
       if temp_v < px then ex_hi[iter] = ex_hi[iter] + 1 ; Overflow
       if ex_hi[iter] >= 2 then ex_hi[iter] = 0 ; Wrap Up
       if ex_hi[iter] = 255 then ex_hi[iter] = 1 ; Wrap Down (Safety)

spawn_set_y
       ; Random Y (10 to 180) -> Screen Space
       ; Convert to World: Ey = Py + (ScreenY - 90)
       temp_v = rand
       if temp_v < 10 then temp_v = 10
       if temp_v > 180 then temp_v = 180
       
       ; Calculate Offset from Center (90)
       temp_acc = temp_v - 90
       
       ; Default to same High Byte
       ey_hi[iter] = py_hi
       
       ; Add Offset to Py
       if temp_acc < 128 then goto add_pos_offset
       
       ; Negative Offset (ScreenY < 90)
       ; ey = py + neg_offset
       temp_w = py + temp_acc
       ey[iter] = temp_w
       if temp_w > py then ey_hi[iter] = ey_hi[iter] - 1 ; Borrow
       goto check_wrap_y_spawn

add_pos_offset
       ; Positive Offset (ScreenY > 90)
       temp_w = py + temp_acc
       ey[iter] = temp_w
       if temp_w < py then ey_hi[iter] = ey_hi[iter] + 1 ; Carry

check_wrap_y_spawn
       if ey_hi[iter] = 255 then ey_hi[iter] = 1
       if ey_hi[iter] >= 2 then ey_hi[iter] = 0
       
enemy_logic_done
    next
    return

fire_enemy_bullet
   ; ITER holds current enemy index
   ; Find free bullet slot
   for temp_acc = 0 to 3
      if eblife[temp_acc] = 0 then goto spawn_ebul
   next
   return

spawn_ebul
   ; temp_acc is bullet index
   ; iter is enemy index
   if e_on[iter] = 0 then return ; Use cached visibility
   
   eblife[temp_acc] = 120 ; Increased lifetime
   
   temp_v = ex_scr[iter]
   temp_w = ey_scr[iter]
   ebul_x[temp_acc] = temp_v
   ebul_y[temp_acc] = temp_w
   
   ; Aim at player (already in screen space)
   ; Speed set to 4px/frame
   ; temp_bx = delta X
   temp_bx = px_scr + 8 ; Target Center Screen X
   temp_bx = temp_bx - temp_v ; Delta Screen X
   
   if temp_bx >= 128 then ebul_vx[temp_acc] = 252 : temp_bx = 0 - temp_bx else ebul_vx[temp_acc] = 4
   
   temp_by = py_scr + 8 ; Target Center Screen Y
   temp_by = temp_by - temp_w ; Delta Screen Y

   if temp_by >= 128 then ebul_vy[temp_acc] = 252 : temp_by = 0 - temp_by else ebul_vy[temp_acc] = 4
   
   ; 8-way logic
   temp_v = temp_bx / 2
   if temp_v > temp_by then ebul_vy[temp_acc] = 0
   
   temp_v = temp_by / 2
   if temp_v > temp_bx then ebul_vx[temp_acc] = 0
   
   ecooldown = enemy_fire_cooldown ; Set from level config
   
   ; Play enemy fire sound
   playsfx sfx_enemyfire 0
   
   return

update_enemy_bullets
   for iter = 0 to 3
      if eblife[iter] = 0 then goto skip_ebul_update
      
      eblife[iter] = eblife[iter] - 1
      
      ; Move X (screen space - simple addition)
      temp_v = ebul_vx[iter]
      if temp_v >= 128 then goto ebul_x_neg
      
      ; Positive X
      ebul_x[iter] = ebul_x[iter] + temp_v
      goto ebul_x_done

ebul_x_neg
      temp_v = 0 - temp_v
      ebul_x[iter] = ebul_x[iter] - temp_v

ebul_x_done
      ; Move Y (screen space - simple addition)
      temp_v = ebul_vy[iter]
      if temp_v >= 128 then goto ebul_y_neg
      
      ; Positive Y
      ebul_y[iter] = ebul_y[iter] + temp_v
      goto ebul_y_done

ebul_y_neg
      temp_v = 0 - temp_v
      ebul_y[iter] = ebul_y[iter] - temp_v

ebul_y_done
      ; Off-Screen Culling (screen space)
      temp_v = ebul_x[iter]
      if temp_v > 165 then if temp_v < 240 then eblife[iter] = 0
      
      temp_v = ebul_y[iter]
      if temp_v > 200 then eblife[iter] = 0

skip_ebul_update
   next
   return

update_asteroid
   if alife = 0 then gosub spawn_asteroid
   if alife = 0 then return
   
   ; Move Asteroid using sub-pixel accumulator for smooth movement
   ; X Axis - accumulate velocity and only move when overflow
   temp_v = avx
   if temp_v >= 128 then goto ast_acc_neg_x
   
   ; Positive X velocity
   temp_w = ast_acc_x + temp_v
   ast_acc_x = temp_w & 3 ; Keep fractional part (divide by 4)
   temp_v = temp_w / 4    ; Integer movement
   if temp_v = 0 then goto ast_x_done
   goto ast_move_pos_x
   
ast_acc_neg_x
   ; Negative X velocity
   temp_v = 0 - temp_v
   temp_w = ast_acc_x + temp_v
   ast_acc_x = temp_w & 3
   temp_v = temp_w / 4
   if temp_v = 0 then goto ast_x_done
   temp_w = ax
   ax = ax - temp_v
   if ax > temp_w then ax_hi = ax_hi - 1
   goto ast_x_done

ast_move_pos_x
   ax = ax + temp_v
   if ax < temp_v then ax_hi = ax_hi + 1

ast_x_done
   ; Wrap X (0-3, 4 segments = 1024)
   if ax_hi = 255 then ax_hi = 1
   if ax_hi >= 2 then ax_hi = 0

   ; Y Axis - accumulate velocity and only move when overflow
   temp_v = avy
   if temp_v >= 128 then goto ast_acc_neg_y
   
   ; Positive Y velocity
   temp_w = ast_acc_y + temp_v
   ast_acc_y = temp_w & 3
   temp_v = temp_w / 4
   if temp_v = 0 then goto ast_y_done
   goto ast_move_pos_y
   
ast_acc_neg_y
   ; Negative Y velocity
   temp_v = 0 - temp_v
   temp_w = ast_acc_y + temp_v
   ast_acc_y = temp_w & 3
   temp_v = temp_w / 4
   if temp_v = 0 then goto ast_y_done
   temp_w = ay
   ay = ay - temp_v
   if ay > temp_w then ay_hi = ay_hi - 1
   goto ast_y_done

ast_move_pos_y
   ay = ay + temp_v
   if ay < temp_v then ay_hi = ay_hi + 1

ast_y_done
   ; Wrap Y (0-3, 4 segments = 1024)
   if ay_hi = 255 then ay_hi = 1
   if ay_hi >= 2 then ay_hi = 0
   
   ; Despawn Timer (only for boss-thrown asteroids in Level 6)
   if current_level = 6 then if asteroid_timer > 0 then asteroid_timer = asteroid_timer - 1
   if current_level = 6 then if asteroid_timer = 0 then if a_on = 0 then alife = 0
   
   return

spawn_asteroid
   ; Don't spawn random asteroids during boss level
   if current_level = 6 then return
   
   ; Spawn chance
   rand_val = frame & 127
   if rand_val > 5 then return
   
   ; Initialize safe off-screen position first (Upwind in Segment 0)
   ax = 128 : ax_hi = 0
   ay = 128 : ay_hi = 0
   ax_scr = 240 : ay_scr = 240
   
   ; 1. Pick Random Angle (0-15)
   rand_val = (frame + px + py) & 15
   
   ; 2. Determine Velocity from Angle
   temp_v = sin_table[rand_val]
   avx = temp_v ; Base X speed
   
   temp_v = cos_table[rand_val] 
   avy = temp_v ; Base Y speed
   
   ; Speed Variance (Random Boost)
   if (frame & 16) > 0 then avx = avx + avx / 2 : avy = avy + avy / 2
   
   ; Level Scaling (Speed up on higher levels)
   if current_level >= 3 then avx = avx + avx : avy = avy + avy
   
   ; 4. Finalize Life
   alife = 1
   return


check_collisions
   ; 0. Player vs Energy (Priority Check)
   if energy_on = 0 then goto skip_energy_coll
   if energy_x_hi <> px_hi then goto skip_energy_coll
   if energy_y_hi <> py_hi then goto skip_energy_coll
   
   ; Ship center (80, 98), Orb center (x+2, y+2). Center distance = abs(78 - ex)
   temp_v = energy_x - 78
   if temp_v >= 128 then temp_v = 0 - temp_v
   if temp_v >= 12 then goto skip_energy_coll ; Tightened radius check
   
   temp_v = energy_y - 96
   if temp_v >= 128 then temp_v = 0 - temp_v
   if temp_v >= 12 then goto skip_energy_coll
   
   ; Collection!
   energy_on = 0
   playsfx sfx_laser 0
   player_shield = player_shield + 10
   if player_shield > 100 then player_shield = 100
   
skip_energy_coll

   ; 1. Bullets vs Enemies
   for iter = 0 to 3 ; Bullets
      if blife[iter] = 0 then goto skip_bullet_coll
      
      for temp_acc = 0 to 3 ; Enemies
         if e_on[temp_acc] = 0 then goto skip_enemy_coll
         if elife[temp_acc] <> 1 then goto skip_enemy_coll
         
         ; Bullet (4) vs Fighter (8x8, 6x6 visual). Center bullet (+2), Fighter (+4)
         temp_w = ex_scr[temp_acc]
         temp_v = bul_x[iter] - temp_w
         temp_v = temp_v - 2 ; Center Offset (Delta Center: Bul+2 - Enemy+4 = -2)
         if temp_v >= 128 then temp_v = 0 - temp_v
         temp_w = 15 : if game_difficulty = 1 then temp_w = 16
         if temp_v >= temp_w then goto skip_enemy_coll
         
         ; Check Y Collision
         temp_w = ey_scr[temp_acc]
         temp_v = bul_y[iter] - temp_w
         temp_v = temp_v - 2 ; Center Offset
         if temp_v >= 128 then temp_v = 0 - temp_v
         temp_w = 15 : if game_difficulty = 1 then temp_w = 16
         if temp_v >= temp_w then goto skip_enemy_coll
         
         ; Hit!
         blife[iter] = 0
         elife[temp_acc] = 18 ; Start Explosion (18 frames)
         playsfx sfx_damage 0 ; Destruction sound
                  ; Decrement Fighters Remaining
          if current_level < 6 then if fighters_remaining > 0 then fighters_remaining = fighters_remaining - 1
          score0 = score0 + 100
          if current_level < 6 then fighters_bcd = converttobcd(fighters_remaining)
         if fighters_remaining <= 0 then goto coll_done
         
         goto skip_enemy_coll ; Bullet used up
         
skip_enemy_coll
      next
      
      ; 1b. Bullets vs Blue Fighters
      for temp_acc = 0 to 1
         if bf_on[temp_acc] = 0 then goto skip_bul_bf
         if bflife[temp_acc] <> 1 then goto skip_bul_bf
         
         ; Centre to centre: bullet dot (+2,+2), blue fighter (+4,+4)
         temp_w = 18 : if game_difficulty = 1 then temp_w = 19
         temp_v = bul_x[iter] - bfx_scr[temp_acc]
         temp_v = temp_v - 2
         if temp_v >= 128 then temp_v = 0 - temp_v
         if temp_v >= temp_w then goto skip_bul_bf

         temp_v = bul_y[iter] - bfy_scr[temp_acc]
         temp_v = temp_v - 2
         if temp_v >= 128 then temp_v = 0 - temp_v
         if temp_v >= temp_w then goto skip_bul_bf
         
         ; Hit!
         blife[iter] = 0
         bflife[temp_acc] = 18 ; Trigger explosion
         playsfx sfx_damage 0
         score0 = score0 + 250
          if current_level < 6 then if fighters_remaining > 0 then fighters_remaining = fighters_remaining - 1
          if current_level < 6 then fighters_bcd = converttobcd(fighters_remaining)
         
         ; Energy Item Drop Logic
         bf_kill_count = bf_kill_count + 1
         if bf_kill_count >= 4 then if energy_on = 0 then energy_on = 1 : energy_timer = 240 : energy_x = bfx[temp_acc] : energy_y = bfy[temp_acc] : energy_x_hi = bfx_hi[temp_acc] : energy_y_hi = bfy_hi[temp_acc] : bf_kill_count = 0
         if fighters_remaining <= 0 then goto coll_done
         goto skip_bullet_coll ; Bullet spent
skip_bul_bf
        next
      
skip_bullet_coll
   next
   
   ; 1c. Player vs Blue Fighter Bullet
   if bf_bul_life = 0 then goto skip_bf_bul_coll
   
   temp_v = px_scr - bf_bul_x
   temp_v = temp_v + 7
   if temp_v >= 128 then temp_v = 0 - temp_v
   if temp_v >= 8 then goto skip_bf_bul_coll
   
   temp_v = py_scr - bf_bul_y
   temp_v = temp_v + 7
   if temp_v >= 128 then temp_v = 0 - temp_v
   if temp_v >= 8 then goto skip_bf_bul_coll
   
   ; Hit Player
   bf_bul_life = 0
   playsfx sfx_damage 0
   temp_v = 1
   if player_shield < temp_v then player_shield = 0 else player_shield = player_shield - temp_v
   if player_shield <= 0 then goto coll_done

skip_bf_bul_coll

   ; 2. Player vs Enemies
   for iter = 0 to 3
      if e_on[iter] = 0 then goto skip_p_e
      if elife[iter] <> 1 then goto skip_p_e
      
      ; X Check (Screen Space)
      temp_v = px_scr - ex_scr[iter]
      temp_v = temp_v + 4 ; Offset to shrink left side
      if temp_v >= 128 then temp_v = 0 - temp_v
      if temp_v >= 11 then goto skip_p_e
      
      ; Y Check
      temp_v = py_scr - ey_scr[iter]
      if temp_v >= 128 then temp_v = 0 - temp_v
      if temp_v >= 11 then goto skip_p_e
      
      ; Hit Player
      elife[iter] = 18 ; Explode
      playsfx sfx_damage 0 ; Crash sound for player-fighter collision
      
      ; Decrement Shields (Standard 2)
      temp_v = 2
      if player_shield < temp_v then player_shield = 0 else player_shield = player_shield - temp_v

      
      ; Also decrement fighter count (fighter destroyed) - not during boss level
      ; Also decrement fighter count (fighter destroyed)
      if current_level < 6 then if fighters_remaining > 0 then fighters_remaining = fighters_remaining - 1
      score0 = score0 + 100
      if current_level < 6 then fighters_bcd = converttobcd(fighters_remaining)
      if fighters_remaining <= 0 then goto coll_done
      
      ; Check for death
      if player_shield <= 0 then goto coll_done
      
skip_p_e
   next
   
   ; 2b. Player vs Blue Fighters
   for iter = 0 to 1
      if bf_on[iter] = 0 then goto skip_p_bf
      if bflife[iter] <> 1 then goto skip_p_bf
      
      temp_v = px_scr - bfx_scr[iter]
      temp_v = temp_v + 4
      if temp_v >= 128 then temp_v = 0 - temp_v
      if temp_v >= 11 then goto skip_p_bf
      
      temp_v = py_scr - bfy_scr[iter]
      if temp_v >= 128 then temp_v = 0 - temp_v
      if temp_v >= 11 then goto skip_p_bf
      
      ; Hit!
      bflife[iter] = 18 ; Trigger explosion
      playsfx sfx_damage 0
      temp_v = 2
      if player_shield < temp_v then player_shield = 0 else player_shield = player_shield - temp_v
      
      ; Decrement fighter count (fighter destroyed) - not during boss level
      ; Decrement fighter count (fighter destroyed)
      if current_level < 6 then if fighters_remaining > 0 then fighters_remaining = fighters_remaining - 1
      score0 = score0 + 100
      if current_level < 6 then fighters_bcd = converttobcd(fighters_remaining)
      
      ; Energy Item Drop Logic
      bf_kill_count = bf_kill_count + 1
      if bf_kill_count >= 4 then if energy_on = 0 then energy_on = 1 : energy_timer = 240 : energy_x = bfx[iter] : energy_y = bfy[iter] : energy_x_hi = bfx_hi[iter] : energy_y_hi = bfy_hi[iter] : bf_kill_count = 0
      if fighters_remaining <= 0 then goto coll_done
      
      if player_shield <= 0 then goto coll_done
skip_p_bf
   next
   
   ; Only check if visible
   if a_on = 0 then goto check_player_ebul

   ; 3. Bullets vs Asteroid (Indestructible)
   for iter = 0 to 3
      if blife[iter] = 0 then goto skip_bul_ast

      ; X Check
      temp_v = bul_x[iter] - ax_scr
      temp_v = temp_v - 6 ; Center Offset (+6)
      if temp_v >= 128 then temp_v = 0 - temp_v
      if temp_v >= 12 then goto skip_bul_ast ; Match Asteroid Box (12)
      
      ; Y Check
      temp_v = bul_y[iter] - ay_scr
      temp_v = temp_v - 6
      if temp_v >= 128 then temp_v = 0 - temp_v
      if temp_v >= 22 then goto skip_bul_ast ; Match Asteroid Box (22)
      
      ; Hit! Bullet dies, Asteroid lives.
      blife[iter] = 0
      ; playsfx sfx_ping ?

skip_bul_ast
   next
   
   ; 4. Player vs Asteroid
   temp_w = px_scr - ax_scr
   ; Center-to-center check
   if temp_w >= 128 then temp_v = 0 - temp_w else temp_v = temp_w
   if temp_v >= 14 then goto check_enemy_ast_coll ; Widened to 14 (Center Logic)
   
   ; Y Check
   temp_acc = py_scr - ay_scr
   if temp_acc >= 128 then temp_v = 0 - temp_acc else temp_v = temp_acc
   if temp_v >= 24 then goto check_enemy_ast_coll ; Widened to 24 (Center Logic)
   
   ; Hit Player!
    ; 1. Damage Shield (Base 10)
    temp_v = 10
    if player_shield < temp_v then player_shield = 0 else player_shield = player_shield - temp_v
    if player_shield <= 0 then goto coll_done
   
   ; 2. Bounce Logic (Large bounce to avoid multiple collisions)
   ; If Player is Left of Ast (temp_w < 0 -> >128), Bounce Left.
   ; px_scr < ax_scr -> temp_w is "negative" (high byte)
   if temp_w >= 128 then vx_m = 128 : vx_p = 0 else vx_p = 128 : vx_m = 0
   
   ; Y Bounce
   if temp_acc >= 128 then vy_m = 128 : vy_p = 0 else vy_p = 128 : vy_m = 0
   
   ; Play crash sound for collision
   playsfx sfx_damage 0
   
   ; 3. Push asteroid away to prevent re-collision
   ; Push asteroid velocity in opposite direction of player bounce
   ; If player bounced left (vx_m=128), push asteroid right (avx=positive)
   if temp_w >= 128 then avx = 3 else avx = 253  ; 253 = -3 in signed byte
   if temp_acc >= 128 then avy = 3 else avy = 253
   
   ; Sound Effect?
   
check_enemy_ast_coll
   ; 5. Enemy vs Asteroid (Strategic Kill)
   for iter = 0 to 3
      if elife[iter] = 0 then goto skip_e_ast
      if elife[iter] > 1 then goto skip_e_ast ; Do not hit if already exploding
      if e_on[iter] = 0 then goto skip_e_ast
      
      ; X Check
      temp_v = ex_scr[iter] - ax_scr
      if temp_v >= 128 then temp_v = 0 - temp_v
      if temp_v >= 14 then goto skip_e_ast ; Tightened (Was 20)

      ; Y Check
      temp_v = ey_scr[iter] - ay_scr
      if temp_v >= 128 then temp_v = 0 - temp_v
      if temp_v >= 24 then goto skip_e_ast ; Tightened (Was 20 - adjusted for height)
      
      ; Hit! Destroy Enemy
      elife[iter] = 18 ; Explode
      playsfx sfx_damage 0 ; Destruction sound (Enemy hits Asteroid)
      score0 = score0 + 50
      
      ; Decrement fighter count
      if current_level < 6 then if fighters_remaining > 0 then fighters_remaining = fighters_remaining - 1
      if current_level < 6 then fighters_bcd = converttobcd(fighters_remaining)
      if fighters_remaining <= 0 then goto coll_done

skip_e_ast
   next

   ; 5b. Blue Fighter vs Asteroid
   for iter = 0 to 1
      if bflife[iter] = 0 then goto skip_bf_ast
      if bflife[iter] > 1 then goto skip_bf_ast
      if bf_on[iter] = 0 then goto skip_bf_ast
      
      temp_v = bfx_scr[iter] - ax_scr
      if temp_v >= 128 then temp_v = 0 - temp_v
      if temp_v >= 14 then goto skip_bf_ast
      
      temp_v = bfy_scr[iter] - ay_scr
      if temp_v >= 128 then temp_v = 0 - temp_v
      if temp_v >= 24 then goto skip_bf_ast
      
      ; Hit!
      bflife[iter] = 18 ; Explode
      playsfx sfx_damage 0
      score0 = score0 + 50
      
      ; Decrement fighters
      if current_level < 6 then if fighters_remaining > 0 then fighters_remaining = fighters_remaining - 1
      if current_level < 6 then fighters_bcd = converttobcd(fighters_remaining)
      if fighters_remaining <= 0 then goto coll_done
skip_bf_ast
   next

   ; 6. Enemy Bullet vs Asteroid (Missing)
   for iter = 0 to 3
      if eblife[iter] = 0 then goto skip_ebul_ast
      if a_on = 0 then goto skip_ebul_ast
      
      ; X Check
      temp_v = ebul_x[iter] - ax_scr
      if temp_v >= 128 then temp_v = 0 - temp_v
      if temp_v >= 12 then goto skip_ebul_ast
      
      ; Y Check
      temp_v = ebul_y[iter] - ay_scr
      if temp_v >= 128 then temp_v = 0 - temp_v
      if temp_v >= 22 then goto skip_ebul_ast
      
      ; Hit! Bullet dies. Asteroid lives.
      eblife[iter] = 0

skip_ebul_ast
   next
   
   
check_player_ebul
   ; Check vs Enemy Bullets (Screen Space)
   for iter = 0 to 3
      if eblife[iter] = 0 then goto skip_ebul_coll
      
      ; --- Screen Space Collision ---
      temp_w = px_scr - ebul_x[iter]
      temp_w = temp_w + 7 ; Offset Check
      
      if temp_w >= 128 then temp_w = 0 - temp_w
      if temp_w >= 8 then goto skip_ebul_coll ; Widen to ~8 (Size 16)
      
      ; Y Check
      temp_w = py_scr - ebul_y[iter]
      temp_w = temp_w + 7 
      
      if temp_w >= 128 then temp_w = 0 - temp_w
      if temp_w >= 8 then goto skip_ebul_coll
      
      ; Hit Player
      eblife[iter] = 0
      playsfx sfx_damage 0 ; Harsh damage feedback for player hit
      
      ; Decrement Shields (Standard 1)
      temp_v = 1
      if player_shield < temp_v then player_shield = 0 else player_shield = player_shield - temp_v
      if player_shield <= 0 then goto coll_done
      
skip_ebul_coll
   next

   ; Only check if boss is active
   if boss_state = 0 then goto coll_done
   if boss_on = 0 then goto coll_done
   
   ; Define Dynamic Hitbox based on Level
   ; 1. BULLET HITBOXES (Larger: 16x16, 32x16, 32x32)
   if current_level = 1 || current_level = 3 then temp_bx = 8 : temp_by = 8 : temp_w = 8 : temp_acc = 8
   if current_level = 2 || current_level = 4 then temp_bx = 16 : temp_by = 8 : temp_w = 16 : temp_acc = 8
   if current_level >= 5 then temp_bx = 16 : temp_by = 16 : temp_w = 16 : temp_acc = 16
   
   ; 1. Bullets vs Boss
   for iter = 0 to 3
      if blife[iter] = 0 then goto skip_bul_boss
      
      ; X Check
      temp_v = bul_x[iter] - boss_scr_x
      temp_v = temp_v - temp_bx ; Center Offset X
      if temp_v >= 128 then temp_v = 0 - temp_v
      if temp_v >= temp_w then goto skip_bul_boss ; Width Threshold
      
      ; Y Check
      temp_v = bul_y[iter] - boss_scr_y
      temp_v = temp_v - temp_by ; Center Offset Y
      if temp_v >= 128 then temp_v = 0 - temp_v
      if temp_v >= temp_acc then goto skip_bul_boss ; Height Threshold
      

      
      ; Hit!
       blife[iter] = 0
       
       ; Damage Scaling: Level 1=6, Level 6=1
       temp_w = 7 - current_level
       if temp_w < 1 then temp_w = 1 ; Safety
       
       if boss_hp < temp_w then boss_hp = 0 else boss_hp = boss_hp - temp_w
       playsfx sfx_damage 0
       score0 = score0 + 10
       
       ; Check Phase Thresholds (75, 50, 25)
       if boss_hp <= 75 && boss_state = 4 then boss_state = 3 : gosub teleport_boss
       
       ; Health Gate Checkpoint
       if boss_hp <= 50 then boss_checkpoint = 1
       
       if boss_hp <= 50 && boss_state = 3 then boss_state = 2 : gosub teleport_boss
       if boss_hp <= 25 && boss_state = 2 then boss_state = 1 : gosub teleport_boss
  ; Check for boss death
      if boss_hp <= 0 then goto boss_defeated
      
skip_bul_boss
   next
   
   ; 1b. Boss vs Asteroid (Defensive Warp - Levels 1-5)
   if current_level >= 6 then goto skip_boss_ast
   if boss_state = 0 then goto skip_boss_ast
   if boss_on = 0 then goto skip_boss_ast
   if a_on = 0 then goto skip_boss_ast
   
   temp_bx = 8 : temp_by = 8 ; Default 16x16 (L1, L3)
   temp_w = 16 ; X Threshold (8+8)
   temp_acc = 16 ; Y Threshold (8+8)
   
   if current_level = 2 || current_level = 4 then temp_bx = 16 : temp_w = 24
   if current_level = 5 then temp_bx = 16 : temp_by = 16 : temp_w = 24 : temp_acc = 24
   
   ; X Check (Center-to-Center)
   temp_v = ax_scr + 8
   var92 = boss_scr_x + temp_bx
   temp_v = temp_v - var92
   if temp_v >= 128 then var90 = 0 - temp_v else var90 = temp_v
   if var90 >= temp_w then goto skip_boss_ast
   
   ; Y Check
   temp_v = ay_scr + 8
   var92 = boss_scr_y + temp_by
   temp_v = temp_v - var92
   if temp_v >= 128 then var90 = 0 - temp_v else var90 = temp_v
   if var90 >= temp_acc then goto skip_boss_ast

   ; Collision Confirmed - Warp Boss!
   gosub teleport_boss
   
skip_boss_ast
   
   ; 2. Player vs Boss (Tight Hitboxes: 12x12, 24x12, 24x24)
   ; Reset thresholds for player safety
   if current_level = 1 || current_level = 3 then temp_w = 6 : temp_acc = 6
   if current_level = 2 || current_level = 4 then temp_w = 12 : temp_acc = 6
   if current_level >= 5 then temp_w = 12 : temp_acc = 12

   ; Player: 16x16 at (px_scr, py_scr) top-left
   ; Boss: 32x32 at (boss_scr_x, boss_scr_y) top-left
   ; Check if rectangles overlap
   
   ; X overlap: px_scr < boss_scr_x + 32 AND px_scr + 16 > boss_scr_x
   ; Simplified: distance between centers < (16+32)/2 = 24
   
   ; X Check - distance from player center to boss center
   temp_v = px_scr + 8 ; Player center X
   var92 = boss_scr_x + temp_bx ; Boss center X (Use var92 to preserve temp_w)
   temp_v = temp_v - var92
   if temp_v >= 128 then temp_v = 0 - temp_v
   ; Radius check: Player(8) + Boss Threshold(temp_w)
   var90 = 8 + temp_w 
   if temp_v >= var90 then goto coll_done ; No X overlap
   
   ; Y Check - distance from player center to boss center
   temp_v = py_scr + 8 ; Player center Y
   var92 = boss_scr_y + temp_by ; Boss center Y (Use var92 to preserve temp_acc)
   temp_v = temp_v - var92
   if temp_v >= 128 then temp_v = 0 - temp_v
   var90 = 8 + temp_acc ; Player Radius(8) + Boss Threshold Y(temp_acc)
   if temp_v >= var90 then goto coll_done ; No Y overlap
   
   ; Hit Player - Heavy Damage
   playsfx sfx_damage 0
   if player_shield < 20 then player_shield = 0 else player_shield = player_shield - 20
   
   ; Bounce player away
   if px_scr < boss_scr_x then vx_m = 128 : vx_p = 0 else vx_p = 128 : vx_m = 0
   if py_scr < boss_scr_y then vy_m = 128 : vy_p = 0 else vy_p = 128 : vy_m = 0

coll_done
   return

boss_defeated
   ; Boss destroyed - trigger level complete
   gosub update_bars ; empty the boss bar before the explosion freezes the HUD

   ; Play Explosion Sound
   gosub StopMusic
   playsfx sfx_explode
   
   ; Boss Explosion Animation (8 frames)
   boss_on = 0 ; Hide the actual boss sprite immediately
   
   for temp_val_hi = 0 to 7
      for screen_timer = 0 to 10
         restorescreen
         
         ; Draw Game State (Frozen)
         gosub draw_stars
         gosub draw_player_bullets
         gosub draw_enemies
         if alife > 0 then gosub draw_asteroid
         gosub draw_enemy_bullets
         
         ; Draw Player (Use cached pos)
         plotsprite sprite_spaceship1 5 px_scr py_scr 0
         
         ; Draw Explosion at Boss Location
         ; Center the 16x16 explosion relative to the boss
         ; L1/3 (16x16): Center +8,+8. Explosion Center +8,+8. Diff 0.
         ; L2/4 (32x16): Center +16,+8. Diff X+8.
         ; L5 (32x32): Center +16,+16. Diff X+8, Y+8.
         
         ; Simplified: Just use Boss top-left or centered based on level?
         ; Let's align to the "main" part.
         ; Simplified logic:
         temp_v = boss_scr_x
         temp_w = boss_scr_y
         if current_level = 2 then temp_v = temp_v + 8
         if current_level = 4 then temp_v = temp_v + 8
         if current_level >= 5 then temp_v = temp_v + 8
         if current_level >= 5 then temp_w = temp_w + 8
         
         plotsprite fighter_explode_00_conv 1 temp_v temp_w temp_val_hi
         
         drawscreen
         frame = frame + 1
      next
   next

   boss_state = 5 ; State 5 = Defeated/Level Complete
   boss_on = 0
   fighters_remaining = 0
   score0 = score0 + 5000
   gosub refresh_static_ui
   goto coll_done

init_stars
   for iter = 0 to 3
      ; Random X (0-159)
      rand_val = frame & 127 : temp_v = rand_val
      rand_val = frame & 32 : temp_v = temp_v + rand_val
      if temp_v > 159 then temp_v = 159
      star_x[iter] = temp_v
      
      ; Random Y (0-190)
      rand_val = frame & 127
      rand_val = rand_val + 50 ; padding?
      if rand_val > 180 then rand_val = rand_val - 100
      star_y[iter] = rand_val
      
      ; Random Color (1-3)
      rand_val = frame & 3
      if rand_val = 0 then rand_val = 1
      star_c[iter] = rand_val
      
      ; Advance frame to mix RNG
      frame = frame + 1
   next
   return

draw_stars
   ; Unrolled loop for performance (4 stars)
   ; Star X is world coordinate. Screen X = StarX - PX + 80
   temp_v = star_x[0] - px + 80
   if temp_v > 165 then goto skip_s0
   temp_w = star_y[0] - py + 90
   if temp_w > 200 then goto skip_s0
   plotsprite bullet_conv 4 temp_v temp_w
skip_s0
   temp_v = star_x[1] - px + 80
   if temp_v > 165 then goto skip_s1
   temp_w = star_y[1] - py + 90
   if temp_w > 200 then goto skip_s1
   plotsprite bullet_conv 4 temp_v temp_w
skip_s1
   temp_v = star_x[2] - px + 80
   if temp_v > 165 then goto skip_s2
   temp_w = star_y[2] - py + 90
   if temp_w > 200 then goto skip_s2
   plotsprite bullet_conv 4 temp_v temp_w
skip_s2
   temp_v = star_x[3] - px + 80
   if temp_v > 165 then goto skip_s3
   temp_w = star_y[3] - py + 90
   if temp_w > 200 then goto skip_s3
   plotsprite bullet_conv 4 temp_v temp_w
skip_s3
   return

cycle_stars
   ; Twinkle every 8 frames
   if (frame & 7) > 0 then return
   
   cycle_state = cycle_state + 1
   if cycle_state > 2 then cycle_state = 0
   
   if cycle_state = 0 then P4C1=$08: P4C2=$0C: P4C3=$0F
   if cycle_state = 1 then P4C1=$0C: P4C2=$0F: P4C3=$08
   if cycle_state = 2 then P4C1=$0F: P4C2=$08: P4C3=$0C
   return



update_render_coords
   ; Simple Window Logic with Edge Handling (Hi=1 and Hi=2)
   ; Player (Center) is at Hi=2.
   ; Neighbors: Hi=1 (Left/Top) and Hi=2 (Right/Bottom/Center)
   
   px_scr = 72
   py_scr = 90
   
   for iter = 0 to 3
      if elife[iter] = 0 then e_on[iter] = 0 : goto next_r_simple
      
      ; --- X Axis --- 
      if ex_hi[iter] = 1 then goto check_x_center
      if ex_hi[iter] = 0 then goto check_x_left
      e_on[iter] = 0 : goto next_r_simple

check_x_center
      ; Hi=1 (Center): Use Low Byte directly.
      ex_scr[iter] = ex[iter]
      if ex_scr[iter] > 170 then e_on[iter] = 0 : goto next_r_simple
      goto x_ok

check_x_left
      ; Hi=0 (Left): Use Low Byte. Must be escaping left (255..240)
      ex_scr[iter] = ex[iter]
      if ex_scr[iter] < 240 then e_on[iter] = 0 : goto next_r_simple

x_ok
      
      ; --- Y Axis ---
      if ey_hi[iter] = 1 then goto check_y_center
      if ey_hi[iter] = 0 then goto check_y_top
      e_on[iter] = 0 : goto next_r_simple

check_y_center
      ; Hi=1: Center/Bottom
      ey_scr[iter] = ey[iter]
      if ey_scr[iter] > 210 then e_on[iter] = 0 : goto next_r_simple
      goto y_ok

check_y_top
      ; Hi=0: Top Edge
      ey_scr[iter] = ey[iter]
      if ey_scr[iter] < 240 then e_on[iter] = 0 : goto next_r_simple

y_ok
      
      e_on[iter] = 1
next_r_simple
   next
   
    a_on = 0
    if alife = 0 then goto boss_coords_check

    ; --- Asteroid Visibility ---
    if ax_hi = 1 then goto a_x_c
    if ax_hi = 0 then goto a_x_l
    goto boss_coords_check

a_x_c
    ax_scr = ax
    if ax_scr > 170 then goto boss_coords_check
    goto a_x_done

a_x_l
    ax_scr = ax
    if ax_scr < 230 then goto boss_coords_check

a_x_done
    ; X is valid. Check Y.
    if ay_hi = 1 then goto a_y_c
    if ay_hi = 0 then goto a_y_t
    goto boss_coords_check

a_y_c
    ay_scr = ay
    if ay_scr > 192 then goto boss_coords_check
    goto a_y_done

a_y_t
    ay_scr = ay
    if ay_scr < 192 then goto boss_coords_check

a_y_done
    ; Both Visible!
    a_on = 1
    goto boss_coords_check

; --- Boss (Level 6) ---
boss_coords_check
   ; Boss is active, check visibility
   if boss_state = 0 then boss_on = 0 : return
   
   ; Boss X
   if boss_x_hi = 1 then goto boss_x_center
   if boss_x_hi = 0 then goto boss_x_left
   boss_on = 0 : return
   
boss_x_center
   boss_scr_x = boss_x
   ; Right edge: hide when fully offscreen (x > 160 + 10 margin)
   if boss_scr_x > 170 then boss_on = 0 : return
   goto boss_x_ok
   
boss_x_left
   boss_scr_x = boss_x
   ; Left edge: allow partial (32px wide), hide below 224 - 10 margin = 214
   if boss_scr_x < 214 then boss_on = 0 : return
   
boss_x_ok
   ; Boss Y
   if boss_y_hi = 1 then goto boss_y_center
   if boss_y_hi = 0 then goto boss_y_top
   boss_on = 0 : return
   
boss_y_center
   boss_scr_y = boss_y
   ; Bottom edge: prevent zone wrap (64px tall), hide when y > 192
   if boss_scr_y > 192 then boss_on = 0 : return
   goto boss_y_ok
   
boss_y_top
   boss_scr_y = boss_y
   ; Top edge: allow partial (64px tall), hide below 192 (256-64)
   if boss_scr_y < 192 then boss_on = 0 : return
   
boss_y_ok
   boss_on = 1
   return

   return

shift_universe
   ; temp_bx = Scroll X, temp_by = Scroll Y
   
   ; --- X Shift ---
   if temp_bx = 0 then goto skip_shift_x
   
   ; Enemies
   for iter = 0 to 3
      if elife[iter] = 0 then goto next_shift_x_e
      temp_v = ex[iter]
      ex[iter] = ex[iter] - temp_bx
      
      if temp_bx >= 128 then goto shift_add_x_e
      ; Subtraction (Pos Scroll)
      if ex[iter] > temp_v then ex_hi[iter] = ex_hi[iter] - 1
      goto check_wrap_x_e
shift_add_x_e
      ; Addition (Neg Scroll)
      if ex[iter] < temp_v then ex_hi[iter] = ex_hi[iter] + 1
check_wrap_x_e
      if ex_hi[iter] = 255 then ex_hi[iter] = 1
      if ex_hi[iter] >= 2 then ex_hi[iter] = 0
next_shift_x_e
   next
   
   ; Blue Fighters (separate pool)
   for iter = 0 to 1
      if bflife[iter] = 0 then goto next_shift_x_bf
      temp_v = bfx[iter]
      bfx[iter] = bfx[iter] - temp_bx
      if temp_bx >= 128 then goto shift_add_x_bf
      if bfx[iter] > temp_v then bfx_hi[iter] = bfx_hi[iter] - 1
      goto check_wrap_x_bf
shift_add_x_bf
      if bfx[iter] < temp_v then bfx_hi[iter] = bfx_hi[iter] + 1
check_wrap_x_bf
      if bfx_hi[iter] = 255 then bfx_hi[iter] = 1
      if bfx_hi[iter] >= 2 then bfx_hi[iter] = 0
next_shift_x_bf
   next
   
   ; Asteroid
   if alife = 0 then goto skip_shift_x_a
      temp_v = ax
      ax = ax - temp_bx
      if temp_bx >= 128 then goto shift_add_x_a
      if ax > temp_v then ax_hi = ax_hi - 1
      goto check_wrap_x_a
shift_add_x_a
      if ax < temp_v then ax_hi = ax_hi + 1
check_wrap_x_a
      if ax_hi = 255 then ax_hi = 1
      if ax_hi >= 2 then ax_hi = 0
skip_shift_x_a

   ; Energy Item
   if energy_on = 0 then goto skip_shift_x_en
      temp_v = energy_x
      energy_x = energy_x - temp_bx
      if temp_bx >= 128 then goto shift_add_x_en
      if energy_x > temp_v then energy_x_hi = energy_x_hi - 1
      goto check_wrap_x_en
shift_add_x_en
      if energy_x < temp_v then energy_x_hi = energy_x_hi + 1
check_wrap_x_en
      if energy_x_hi = 255 then energy_x_hi = 1
      if energy_x_hi >= 2 then energy_x_hi = 0
skip_shift_x_en
   ; Boss (Level 6)
   if boss_state = 0 then goto skip_shift_x_boss
      temp_v = boss_x
      boss_x = boss_x - temp_bx
      if temp_bx >= 128 then goto shift_add_x_boss
      if boss_x > temp_v then boss_x_hi = boss_x_hi - 1
      goto check_wrap_x_boss
shift_add_x_boss
      if boss_x < temp_v then boss_x_hi = boss_x_hi + 1
check_wrap_x_boss
      if boss_x_hi = 255 then boss_x_hi = 1
      if boss_x_hi >= 2 then boss_x_hi = 0

skip_shift_x_boss
   
   ; Player Bullets (Screen Space - Do NOT shift, they have absolute velocity)
   ; Bullets move independently and are not affected by universe shift
   
   ; Enemy Bullets (still shift with world)
   for iter = 0 to 3
      if eblife[iter] > 0 then ebul_x[iter] = ebul_x[iter] - temp_bx
   next

   ; Blue Fighter Bullet (Shift with world)
   if bf_bul_life > 0 then bf_bul_x = bf_bul_x - temp_bx


   ; Stars (Screen Wrap 0-160)
   ; FIX: Loop only 0-3 (4 stars) to match array size and prevent var84+ corruption
   for iter = 0 to 3
      star_x[iter] = star_x[iter] - temp_bx
      if star_x[iter] > 160 && star_x[iter] < 240 then star_x[iter] = 0
      if star_x[iter] >= 240 then star_x[iter] = 159
   next

skip_shift_x

   ; --- Y Shift ---
   if temp_by = 0 then return
   
   ; Enemies
   for iter = 0 to 3
      if elife[iter] = 0 then goto next_shift_y_e
      temp_v = ey[iter]
      ey[iter] = ey[iter] - temp_by
      
      if temp_by >= 128 then goto shift_add_y_e
      if ey[iter] > temp_v then ey_hi[iter] = ey_hi[iter] - 1
      goto check_wrap_y_e
shift_add_y_e
      if ey[iter] < temp_v then ey_hi[iter] = ey_hi[iter] + 1
check_wrap_y_e
      if ey_hi[iter] = 255 then ey_hi[iter] = 1
      if ey_hi[iter] >= 2 then ey_hi[iter] = 0
next_shift_y_e
   next
   
   ; Blue Fighters (separate pool)
   for iter = 0 to 1
      if bflife[iter] = 0 then goto next_shift_y_bf
      temp_v = bfy[iter]
      bfy[iter] = bfy[iter] - temp_by
      if temp_by >= 128 then goto shift_add_y_bf
      if bfy[iter] > temp_v then bfy_hi[iter] = bfy_hi[iter] - 1
      goto check_wrap_y_bf
shift_add_y_bf
      if bfy[iter] < temp_v then bfy_hi[iter] = bfy_hi[iter] + 1
check_wrap_y_bf
      if bfy_hi[iter] = 255 then bfy_hi[iter] = 1
      if bfy_hi[iter] >= 2 then bfy_hi[iter] = 0
next_shift_y_bf
   next
   
   ; Asteroid
   if alife = 0 then goto skip_shift_y_a
      temp_v = ay
      ay = ay - temp_by
      if temp_by >= 128 then goto shift_add_y_a
      if ay > temp_v then ay_hi = ay_hi - 1
      goto check_wrap_y_a
shift_add_y_a
      if ay < temp_v then ay_hi = ay_hi + 1
check_wrap_y_a
      if ay_hi = 255 then ay_hi = 1
      if ay_hi >= 2 then ay_hi = 0

skip_shift_y_a

   ; Energy Item
   if energy_on = 0 then goto skip_shift_y_en
      temp_v = energy_y
      energy_y = energy_y - temp_by
      if temp_by >= 128 then goto shift_add_y_en
      if energy_y > temp_v then energy_y_hi = energy_y_hi - 1
      goto check_wrap_y_en
shift_add_y_en
      if energy_y < temp_v then energy_y_hi = energy_y_hi + 1
check_wrap_y_en
      if energy_y_hi = 255 then energy_y_hi = 1
      if energy_y_hi >= 2 then energy_y_hi = 0
skip_shift_y_en
   ; Boss (Level 6)
   if boss_state = 0 then goto skip_shift_y_boss
      temp_v = boss_y
      boss_y = boss_y - temp_by
      if temp_by >= 128 then goto shift_add_y_boss
      if boss_y > temp_v then boss_y_hi = boss_y_hi - 1
      goto check_wrap_y_boss
shift_add_y_boss
      if boss_y < temp_v then boss_y_hi = boss_y_hi + 1
check_wrap_y_boss
      if boss_y_hi = 255 then boss_y_hi = 1
      if boss_y_hi >= 2 then boss_y_hi = 0
skip_shift_y_boss
   
   ; Player Bullets (Screen Space - No shift needed for independent velocity)
   ; Bullets already have their own velocity and should not inherit player movement
   
   ; Enemy Bullets (still shift with world)
   for iter = 0 to 3
      if eblife[iter] > 0 then ebul_y[iter] = ebul_y[iter] - temp_by
   next
   
   ; Blue Fighter Bullet (Shift with world)
   if bf_bul_life > 0 then bf_bul_y = bf_bul_y - temp_by

   
   ; Stars (Screen Wrap 0-192)
   for iter = 0 to 3
      star_y[iter] = star_y[iter] - temp_by
      if star_y[iter] > 192 && star_y[iter] < 240 then star_y[iter] = 0
      if star_y[iter] >= 240 then star_y[iter] = 191
   next
   
   return

; ---- UI Rendering Subroutines (Bug Fix #3: Optimization) ----

draw_lives
   ; Update lives display and cache
   ; Hearts (Lives) as '>', Palette 5 (Red)
   ; Draw current lives (savescreen will handle persistence)
   ; Display hearts as (lives - 1) to show remaining extra lives
   if player_lives >= 2 then plotchars '>' 5 16  0
   if player_lives >= 3 then plotchars '>' 5 24  0
   if player_lives >= 4 then plotchars '>' 5 32  0
   
   ; Update cache
   cached_lives = player_lives
   return

draw_treasures
   ; Update treasure display and cache
   ; Draw Treasures based on Level Completion (Index 10/'A'), Palette 7
   ; Draw completed level treasures (savescreen will handle persistence)
   if current_level > 1 then plotchars '*' 7 120 11
   if current_level > 2 then plotchars '+' 7 128 11
   if current_level > 3 then plotchars '-' 7 136 11
   if current_level > 4 then plotchars '/' 7 144 11
   if current_level > 5 then plotchars '<' 7 152 11
   
   ; Update cache
   cached_level = current_level
   return

refresh_static_ui
    ; Rebuild the saved screen: hearts, treasures, the bars (RAM text).
    ; Only needed when lives, level or the boss bar's presence change.
    clearscreen
    gosub draw_lives
    gosub draw_treasures

    cached_bossbar = 0
    if boss_state > 0 && boss_state < 5 then cached_bossbar = 1 : plotchars 'BOSS' 5 64 10 : plotchars boss_bar 2 40 10 10
    plotchars shield_bar 5 0 11 10

    savescreen
    return

update_bars
    ; Rewrite the bar characters from shield and boss HP (0-100 -> 0-80 px)
    temp_v = player_shield / 5 : temp_v = player_shield - temp_v
    asm
    lda temp_v
    ldx #0
    jsr fill_bar
end
    temp_v = boss_hp / 5 : temp_v = boss_hp - temp_v
    asm
    lda temp_v
    ldx #10
    jsr fill_bar
end
    cached_shield = player_shield
    cached_boss_hp = boss_hp
    return

    asm
; A = pixels (0-80), X = 0 (shield_bar) or 10 (boss_bar). 10 chars, 8 px each.
fill_bar
    sta temp1
    txa
    clc
    adc #10
    sta temp2
fill_bar_loop
    lda temp1
    cmp #8
    bcc fill_bar_part
    lda #8
fill_bar_part
    tay
    sty temp3
    lda temp1
    sec
    sbc temp3
    sta temp1
    lda bar_chars,y
    sta shield_bar,x
    inx
    cpx temp2
    bne fill_bar_loop
    rts
; characters for 0-8 lit pixels  : ( ) . , ! ? " $
bar_chars
    .byte <(unified_font+90), <(unified_font+86), <(unified_font+88)
    .byte <(unified_font+74), <(unified_font+80), <(unified_font+76)
    .byte <(unified_font+78), <(unified_font+82), <(unified_font+84)
end



   ; ---- Data Tables (ROM) ----
   ; Boosted max acceleration to 6 (was 3) to fix crawling
   data sin_table

   0, 2, 3, 4, 4, 4, 3, 2, 0, 254, 253, 252, 252, 252, 253, 254
end

   data cos_table
   6, 6, 4, 2, 0, 254, 252, 250, 250, 250, 252, 254, 0, 2, 4, 6
end
   
   ; Player Laser Sound - High-pitched pew for player shots
   data sfx_laser
   16, 1, 3 ; version, priority, frames per chunk (3 frames = very quick)
   $1F,$04,$04 ; freq (high pitch), channel 4 (pure tone), volume (quiet)
   $1C,$04,$03 ; slight pitch bend down
   $00,$00,$00
end

   ; Enemy Fire Sound - Lower F# tone for enemy shots
   data sfx_enemyfire
   16, 1, 3 ; version, priority, frames per chunk
   $0C,$04,$05 ; freq ~F# (lower tone), channel 4, volume (medium)
   $0A,$04,$04
   $00,$00,$00
end

   ; Player Damage Sound - Harsh descending buzz for pain feedback
   data sfx_damage
   16, 1, 5 ; version, priority, frames per chunk (longer for impact)
   $08,$08,$0A ; freq (mid-low), channel 8 (harsh/buzz), volume (loud)
   $0A,$08,$08 ; descending pitch
   $0C,$08,$06 ; fade out
   $0E,$08,$04
   $00,$00,$00
end

   ; Explosion - noise falling in pitch and fading (player death, boss death)
   data sfx_explode
   16, 2, 6 ; version, priority, frames per chunk
   $06,$08,$0F
   $0A,$08,$0E
   $0E,$08,$0C
   $12,$08,$0A
   $16,$08,$08
   $1A,$08,$06
   $1E,$08,$04
   $1F,$08,$02
   $00,$00,$00
end

draw_player_bullets
   for iter = 0 to 3
      if blife[iter] = 0 then goto skip_draw_bul
      
      ; Screen Space: Coordinates are already relative.
      temp_v = bul_x[iter]
      temp_w = bul_y[iter]
      
      ; Manual Culling (Redundant but safe)
      if temp_v > 165 then if temp_v < 240 then goto skip_draw_bul
      if temp_w > 200 then goto skip_draw_bul
      
      plotsprite bullet_conv 1 temp_v temp_w
      
skip_draw_bul
   next
   return
draw_enemy_bullets
   for iter = 0 to 3
      if eblife[iter] = 0 then goto skip_draw_ebul
      
      temp_v = ebul_x[iter]
      temp_w = ebul_y[iter]
      plotsprite bullet_conv 6 temp_v temp_w
      
skip_draw_ebul
   next
   return
draw_enemies
   ; Loop 0-3
   for iter = 0 to 3
      if e_on[iter] = 0 then goto skip_draw_enemy
      temp_v = ex_scr[iter]
      temp_w = ey_scr[iter]
      if elife[iter] > 1 then goto draw_explosion
      plotsprite fighter 3 temp_v temp_w
      goto skip_draw_enemy

draw_explosion
      ; Frame = (18 - elife[iter]) / 2 + offset
      temp_acc = 18 - elife[iter]
      temp_acc = temp_acc / 2
      if temp_acc > 7 then temp_acc = 7
      
      plotsprite fighter_explode_00_conv 3 temp_v temp_w temp_acc

skip_draw_enemy
   next
   return

draw_asteroid
   if a_on = 0 then return
   ; Plot at screen position - let hardware handle clipping for partial visibility
   plotsprite asteroid_M_conv 2 ax_scr ay_scr
   return

draw_boss
   if boss_on = 0 then return
   
   if current_level >= 5 then goto draw_boss_composite
   
   ; Mini-Boss Rendering (Levels 1-4)
   ; L1=01, L2=02, L3=03, L4=04
   if current_level = 1 then plotsprite BossV2_01 6 boss_scr_x boss_scr_y
   if current_level = 2 then plotsprite BossV2_01 6 boss_scr_x boss_scr_y
   if current_level = 2 then temp_v = boss_scr_x + 16 : plotsprite BossV2_02 6 temp_v boss_scr_y
   
   if current_level = 3 then plotsprite BossV2_03 6 boss_scr_x boss_scr_y
   
   if current_level = 4 then plotsprite BossV2_03 6 boss_scr_x boss_scr_y
   if current_level = 4 then temp_v = boss_scr_x + 16 : plotsprite BossV2_04 6 temp_v boss_scr_y
   return

draw_boss_composite
   ; Top Left
   plotsprite BossV2_01 6 boss_scr_x boss_scr_y
   
   ; Top Right
   temp_v = boss_scr_x
   temp_v = temp_v + 16
   plotsprite BossV2_02 6 temp_v boss_scr_y
   
   ; Bottom Left
   temp_w = boss_scr_y
   temp_w = temp_w + 16
   plotsprite BossV2_03 6 boss_scr_x temp_w
   
   ; Bottom Right
   plotsprite BossV2_04 6 temp_v temp_w
   
   return

calc_boss_indicator
   ; Arrow pointing the short way (the world wraps at 512) from the screen
   ; centre to the boss's centre. Worked out in half pixels so a 9-bit
   ; signed distance fits a byte. Hidden while the boss is well on screen.
   asm
   lda #255
   sta arrow_f
   lda boss_state
   beq ci_off
   cmp #5
   bcc ci_on
ci_off
   rts
ci_on
   ; boss half width: 8 on levels 1 and 3, else 16; half height: 16 from level 5
   ldx #16
   ldy #8
   lda current_level
   cmp #5
   bcc ci_short
   ldy #16
ci_short
   cmp #1
   beq ci_narrow
   cmp #3
   bne ci_wide
ci_narrow
   ldx #8
ci_wide
   stx temp1
   sty temp2
   ; dx/2 = ((boss_x_hi:boss_x) + half width - (1:80)) >> 1, bit 8 as sign
   lda boss_x
   clc
   adc temp1
   tax
   lda boss_x_hi
   adc #0
   tay
   txa
   sec
   sbc #80
   tax
   tya
   sbc #1
   lsr
   txa
   ror
   sta temp3
   ; dy/2, the same from (1:96)
   lda boss_y
   clc
   adc temp2
   tax
   lda boss_y_hi
   adc #0
   tay
   txa
   sec
   sbc #96
   tax
   tya
   sbc #1
   lsr
   txa
   ror
   sta temp4
   ; |dx/2| -> temp5, |dy/2| -> temp6
   lda temp3
   bpl ci_absx
   eor #255
   clc
   adc #1
ci_absx
   sta temp5
   lda temp4
   bpl ci_absy
   eor #255
   clc
   adc #1
ci_absy
   sta temp6
   ; at least 8 px of the boss on screen both ways: no arrow
   ; (|dx| < 80 + half width - 8 and |dy| < 96 + half height - 8, in half px)
   lda temp1
   lsr
   adc #36
   cmp temp5
   bcc ci_show
   beq ci_show
   lda temp2
   lsr
   adc #44
   cmp temp6
   beq ci_show
   bcs ci_done
ci_show
   ; past the side edges by more than past top/bottom (|dx|-80 >= |dy|-96)?
   lda temp5
   clc
   adc #8
   cmp temp6
   bcc ci_vertical
   ; left (frame 0) at x 4 or right (frame 2) at x 150
   ldx #0
   lda #4
   bit temp3
   bmi ci_hset
   ldx #2
   lda #150
ci_hset
   stx arrow_f
   sta arrow_x
   ; y = 92 + 2 * clamp(dy/2, -44..44) -> 4..180
   lda temp4
   bmi ci_yneg
   cmp #44
   bcc ci_yok
   lda #44
   bne ci_yok
ci_yneg
   cmp #212
   bcs ci_yok
   lda #212
ci_yok
   asl
   clc
   adc #92
   sta arrow_y
   rts
ci_vertical
   ; up (frame 1) at y 4 or down (frame 3) at y 180
   ldx #1
   lda #4
   bit temp4
   bmi ci_vset
   ldx #3
   lda #180
ci_vset
   stx arrow_f
   sta arrow_y
   ; x = 76 + 2 * clamp(dx/2, -36..37) -> 4..150
   lda temp3
   bmi ci_xneg
   cmp #37
   bcc ci_xok
   lda #37
   bne ci_xok
ci_xneg
   cmp #220
   bcs ci_xok
   lda #220
ci_xok
   asl
   clc
   adc #76
   sta arrow_x
ci_done
   rts
end

init_boss
   ; Initialize Boss for Level 6
   
   if boss_checkpoint = 1 then goto init_boss_checkpoint
   
   boss_hp = 100                     ; Boss health
   ; Always 100 HP. Difficulty is managed by damage scaling.
   boss_state = 4                    ; Active state (Phase 4..1)
   
   ; Switch Music to Boss Theme
   gosub StopMusic
   music_ptr_hi = 0 ; Force re-init in PlayMusic
   goto init_boss_teleport

init_boss_checkpoint
   boss_hp = 50
   boss_state = 2

init_boss_teleport
   gosub teleport_boss
   
   boss_on = 0  ; Calculated by update_render_coords
   
    ; Clear Enemy Bullets (used by boss)
    for iter = 0 to 3
       eblife[iter] = 0
    next
   
   ; Set Boss Palette (P6)
   P6C1 = $46 ; Red
   P6C2 = $96 ; Blue
   P6C3 = $0A ; Gray
   
   boss_fighter_timer = 60 ; Initial delay (1s)
   boss_asteroid_cooldown = 120 ; 2 second initial delay
   return

teleport_boss
   ; Randomize Boss Position (Ensure off-screen)
boss_spawn_retry
   
   ; Use Hardware RNG (rand)
   rand_val = rand
   boss_x = rand_val
   boss_x_hi = rand_val & 1
   
   boss_y = rand
   boss_y_hi = rand & 1 
   
   ; Check distance from player - must be far enough away
   ; Different quadrant OR far enough in same quadrant
   if boss_x_hi <> px_hi then goto boss_pos_ok
   if boss_y_hi <> py_hi then goto boss_pos_ok
   
   ; Same quadrant - check distance (must be > 100 pixels away)
   temp_v = boss_x - px
   if temp_v >= 128 then temp_v = 0 - temp_v
   if temp_v < 100 then goto boss_spawn_retry
   
   temp_v = boss_y - py
   if temp_v >= 128 then temp_v = 0 - temp_v
   if temp_v < 100 then goto boss_spawn_retry

boss_pos_ok
   bvx = 0   ; Stationary initially
   bvy = 0   ; Stationary initially (will be updated by AI)
   return


update_boss
   if boss_state = 0 then return  ; Boss inactive
   
   ; --- Timers ---
   if boss_fighter_timer > 0 then boss_fighter_timer = boss_fighter_timer - 1
   if boss_fighter_timer = 0 then gosub check_spawn_fighter
   goto skip_fighter_spawn_check
   
check_spawn_fighter
   if current_level >= 2 then gosub attempt_boss_spawn_fighter
   if current_level < 2 then boss_fighter_timer = 60
   
skip_fighter_spawn_check
   
   if boss_asteroid_cooldown > 0 then boss_asteroid_cooldown = boss_asteroid_cooldown - 1
   if boss_asteroid_cooldown = 0 then gosub boss_special_attack
   
   ; --- 0. Update Local Coordinates (Avoid Lag) ---
   ; REMOVED: Do not overwrite boss_scr_x/y with raw world coords.
   ; update_render_coords handles this properly with high-byte logic.
   ; boss_scr_x = boss_x
   ; boss_scr_y = boss_y

   ; --- Boss Movement Logic ---
   if boss_on = 0 then bvx = 0 : bvy = 0 : return

   ; 1. Base Oscillation: back and forth, faster on later levels
   ; L1-2: Speed 2. L3-4: Speed 3. L5-6: Speed 4.
   temp_v = 2
   if current_level >= 3 then temp_v = 3
   if current_level >= 5 then temp_v = 4

   bvy = 0
   boss_move_phase = boss_move_phase + 1
   if boss_move_phase >= 120 then boss_move_phase = 0
   if boss_move_phase < 60 then bvx = temp_v else bvx = 0 - temp_v

boss_apply_constraints

   ; 2. Screen Boundary Containment (Enforce staying on screen)
   ; Right Edge
   if boss_scr_x > 136 && boss_scr_x < 210 then bvx = 253 ; Force Left
   ; Left Edge (Covers wrapped range 210-255 and visible edge 0-24)
   if boss_scr_x < 24 || boss_scr_x >= 210 then bvx = 3 ; Force Right
   
   ; Bottom Edge (168..239)
   ; 168 is safety line. 192 is actual bottom.
   ; 192..239 is "Off Bottom" but not yet "Top Wrap" (240).
   if boss_scr_y > 168 && boss_scr_y < 240 then bvy = 253 ; Force Up
   
   ; Top Edge (240..255 wrap and 0..24 visible)
   if boss_scr_y < 24 || boss_scr_y >= 240 then bvy = 3 ; Force Down

   ; 3. Player Avoidance (40px safety box) - HIGHEST PRIORITY
   ; Boss Center
   temp_v = boss_scr_x + 16
   temp_w = boss_scr_y + 32
   ; Player Center
   var90 = px_scr + 8
   var91 = py_scr + 8
   ; Deltas (Absolute Distance)
   var92 = temp_v - var90
   if var92 >= 128 then var92 = 0 - var92
   var93 = temp_w - var91
   if var93 >= 128 then var93 = 0 - var93
   
   if var92 < 40 && var93 < 40 then goto boss_force_retreat
   
   goto boss_move_apply

boss_force_retreat
   ; Use computed deltas (var92, var93) which are abs-distance
   ; Recalculate signed direction based on relative position
   ; X check
   temp_v = boss_scr_x + 16
   var90 = px_scr + 8
   ; If P < B (Left), Move Right (3). If P > B (Right), Move Left (253).
   ; Check wrap-aware via subtraction
   temp_acc = temp_v - var90
   if temp_acc < 128 then bvx = 3 else bvx = 253
   
   ; Y check
   temp_w = boss_scr_y + 32
   var91 = py_scr + 8
   temp_acc = temp_w - var91
   if temp_acc < 128 then bvy = 3 else bvy = 253

boss_move_apply
   ; Apply Velocities (Integer math, wrap-aware)
   ; ... rest of movement application (handled below) ...

   ; X Axis
   temp_v = bvx
   if temp_v >= 128 then goto boss_neg_x
   
   ; Positive X
   temp_w = boss_acc_x + temp_v
   boss_acc_x = temp_w & 3
   temp_v = temp_w / 4
   if temp_v = 0 then goto boss_x_done
   
   boss_x = boss_x + temp_v
   if boss_x < temp_v then boss_x_hi = boss_x_hi + 1
   goto boss_x_done
   
boss_neg_x
   ; Negative X
   temp_v = 0 - temp_v ; Abs
   temp_w = boss_acc_x + temp_v
   boss_acc_x = temp_w & 3
   temp_v = temp_w / 4
   if temp_v = 0 then goto boss_x_done
   
   temp_w = boss_x
   boss_x = boss_x - temp_v
   if boss_x > temp_w then boss_x_hi = boss_x_hi - 1

boss_x_done
   ; Wrap X
   if boss_x_hi = 255 then boss_x_hi = 1
   if boss_x_hi >= 2 then boss_x_hi = 0
   
   ; Y Axis
   temp_v = bvy
   if temp_v >= 128 then goto boss_neg_y
   
   ; Positive Y
   temp_w = boss_acc_y + temp_v
   boss_acc_y = temp_w & 3
   temp_v = temp_w / 4
   if temp_v = 0 then goto boss_y_done
   
   boss_y = boss_y + temp_v
   if boss_y < temp_v then boss_y_hi = boss_y_hi + 1
   goto boss_y_done
   
boss_neg_y
   ; Negative Y
   temp_v = 0 - temp_v ; Abs
   temp_w = boss_acc_y + temp_v
   boss_acc_y = temp_w & 3
   temp_v = temp_w / 4
   if temp_v = 0 then goto boss_y_done
   
   temp_w = boss_y
   boss_y = boss_y - temp_v
   if boss_y > temp_w then boss_y_hi = boss_y_hi - 1
   
boss_y_done
   ; Wrap Y
   if boss_y_hi = 255 then boss_y_hi = 1
   if boss_y_hi >= 2 then boss_y_hi = 0
   
   return

attempt_boss_spawn_fighter
   ; Try to spawn a fighter at boss location
   ; Find free slot
   for iter = 0 to 3
      if elife[iter] = 0 then goto do_spawn_boss_fighter
   next
   ; No slots, reset timer slightly faster to try again
   boss_fighter_timer = 30
   return

do_spawn_boss_fighter
   elife[iter] = 1
   evx[iter] = 0 : evy[iter] = 0
   
   ; Spawn at Boss Center
   ; Boss is 32x64. Center ~ +16, +32
   temp_v = boss_x + 16
   ex[iter] = temp_v
   ex_hi[iter] = boss_x_hi
   if temp_v < boss_x then ex_hi[iter] = ex_hi[iter] + 1 ; Overflow
   if ex_hi[iter] >= 2 then ex_hi[iter] = 0
   
   temp_v = boss_y + 32
   ey[iter] = temp_v
   ey_hi[iter] = boss_y_hi
   if temp_v < boss_y then ey_hi[iter] = ey_hi[iter] + 1 ; Overflow
   if ey_hi[iter] >= 2 then ey_hi[iter] = 0
   
   ; Reset Timer (2 seconds? 120 frames)
   boss_fighter_timer = 120 
   return

boss_special_attack
   if boss_on = 0 then return
   ; Levels 1-5 shoot at the player; level 6 throws asteroids
   if current_level < 6 then goto boss_fire_bullet

boss_throw_asteroid
   ; Only throw if asteroid slot is free
   if alife > 0 then boss_asteroid_cooldown = 30 : return
   
   ; Spawn asteroid at boss center
   alife = 1
   asteroid_timer = 240 ; 4 seconds at 60fps
   
   ; Position at boss center (32x64 sprite)
   ; Asteroid M is 16x32. Center: boss_x+16, boss_y+32.
   ; Spawn asteroid top-left so its center aligns: ax = boss_x+16-8=8, ay = boss_y+32-16=16
   temp_v = boss_x + 8
   ax = temp_v
   ax_hi = boss_x_hi
   if temp_v < boss_x then ax_hi = ax_hi + 1
   if ax_hi >= 2 then ax_hi = 0
   
   temp_v = boss_y + 16
   ay = temp_v
   ay_hi = boss_y_hi
   if temp_v < boss_y then ay_hi = ay_hi + 1
   if ay_hi >= 2 then ay_hi = 0
   
   ; Aim at Dynamic Target (Player + Oscillation)
   
   ; Target X (Directly at Player)
   var90 = px
   var91 = px_hi

   ; Target Y (Directly at Player)
   var92 = py
   var93 = py_hi

   ; X Delta: Target - ax
   temp_v = var90
   var90 = var90 - ax
   var91 = var91 - ax_hi
   if temp_v < ax then var91 = var91 - 1
   
   ; Normalize X
   if var91 = 1 then var91 = 255
   if var91 = 254 then var91 = 0
   
   avx = 0
   if var91 = 0 && var90 > 10 then avx = 5
   if var91 = 255 then temp_v = 0 - var90 : if temp_v > 10 then avx = 251
   
   ; Y Delta: Target - ay
   temp_v = var92
   var92 = var92 - ay
   var93 = var93 - ay_hi
   if temp_v < ay then var93 = var93 - 1
   
   ; Apply Y Offset for center-to-center alignment
   temp_v = var92
   var92 = var92 - 8
   if var92 > temp_v then var93 = var93 - 1
   
   ; Normalize Y
   if var93 = 1 then var93 = 255
   if var93 = 254 then var93 = 0
   
   avy = 0
   if var93 = 0 && var92 > 10 then avy = 5
   if var93 = 255 then temp_v = 0 - var92 : if temp_v > 10 then avy = 251
   
   goto throw_done
   
throw_done
   boss_asteroid_cooldown = 120 ; 2 second cooldown
   return


boss_fire_bullet
   ; Boss fires enemy bullets at player
   ; Reuse Enemy Bullet System (ebul_x, ebul_y, ebul_vx, ebul_vy, eblife)
   
   ; 1. Find Free Slot
   for iter = 0 to 3
      if eblife[iter] = 0 then goto spawn_boss_bullet
   next
   return

spawn_boss_bullet
   ; iter = bullet index
   
   ; 2. Spawn at Boss Center (Variable by Level)
   boss_attack_timer = 40 ; Default Cooldown (Slower than L1)
   
   eblife[iter] = 120 ; Lifetime
   
   ; Calculate Center Offset based on Boss Size
   temp_bx = 8 : temp_by = 8 ; Default L1/L3 (16x16) center (+8, +8)
   
   if current_level = 2 || current_level = 4 then temp_bx = 16 : temp_by = 8 ; 32x16 center (+16, +8)
   if current_level >= 5 then temp_bx = 16 : temp_by = 16 ; 32x32 center (+16, +16)
   
   ; Coordinates (Screen Space)
   temp_v = boss_scr_x + temp_bx
   ebul_x[iter] = temp_v
   
   temp_w = boss_scr_y + temp_by
   ebul_y[iter] = temp_w
   
   ; 3. Aim at Player (px_scr, py_scr)
   
   ; Delta X
   temp_bx = px_scr + 8 ; Player Center X
   temp_bx = temp_bx - temp_v ; Delta X
   
   if temp_bx >= 128 then ebul_vx[iter] = 252 : temp_bx = 0 - temp_bx else ebul_vx[iter] = 4
   
   ; Delta Y
   temp_by = py_scr + 8 ; Player Center Y
   temp_by = temp_by - temp_w ; Delta Y
   
   if temp_by >= 128 then ebul_vy[iter] = 252 : temp_by = 0 - temp_by else ebul_vy[iter] = 4
   
   ; 8-way adjustment
   temp_v = temp_bx / 2
   if temp_v > temp_by then ebul_vy[iter] = 0
   
   temp_v = temp_by / 2
   if temp_v > temp_bx then ebul_vx[iter] = 0
   
   ; 4. Set Cooldown based on Level (One Level Less than Player)
   ; Player: L1=25, L2-4=15, L5=8
   ; Boss:
   ; L1 -> Slower (40)
   ; L2 -> Player L1 (25)
   ; L3-4 -> Player L2 (15)
   ; L5 -> Player L4 (15)
   
   boss_attack_timer = 40
   if current_level = 2 then boss_attack_timer = 25
   if current_level >= 3 then boss_attack_timer = 15
   
   ; Sound
   playsfx sfx_enemyfire 0
   return

   ; ============================================
   ; Ending screens: victory and game over
   ; ============================================
   ; Shared RAM on the $2600 page (free while these screens run)
   dim es_x = $2650     ; [8] star x
   dim es_y = $2658     ; [8] star y
   dim es_v = $2660     ; [8] star speed
   dim es_t = $2668     ; time on this screen (stops at 255)
   dim es_sx = $2669    ; ship x
   dim es_sy = $266A    ; ship y
   dim es_fr = $266B    ; ship frame (game over tumble)
   dim es_by = $266C    ; ship y with the bob (victory)
   dim es_ready = $266D ; 1 = fire released after the text, so fire continues
   dim deb_x = $2670    ; [4] debris
   dim deb_y = $2674    ; [4]

victory_screen
   ; Hyperspace stars, the ship rising with the five relics circling it,
   ; the story a line at a time, to the title song.
   gosub StopMusic
   boss_state = 0 : current_level = 0
   gosub PlayMusic
   gosub set_palettes
   for iter = 0 to 7
      temp_v = rand & 127 : es_x[iter] = temp_v + 16
      temp_v = rand : if temp_v > 191 then temp_v = temp_v - 64
      es_y[iter] = temp_v
      temp_v = rand & 3 : es_v[iter] = temp_v + 2
   next
   es_t = 0 : es_ready = 0 : es_sy = 200 : es_by = 200
   gosub victory_text

victory_loop
   restorescreen

   ; stars streaming down
   for iter = 0 to 7
      temp_v = es_y[iter] + es_v[iter]
      if temp_v > 191 then temp_v = 0 : temp_w = rand & 127 : es_x[iter] = temp_w + 16
      es_y[iter] = temp_v
   next

   ; the ship rises to y 84, then bobs gently
   if es_sy > 84 then es_sy = es_sy - 2
   es_by = es_sy
   if es_sy <= 84 then temp_v = (frame / 8) & 15 : es_by = 84 + bob_table[temp_v]

   ; the story, a line at a time
   if es_t < 255 then es_t = es_t + 1
   if es_t = 40 || es_t = 100 then gosub victory_text
   if es_t = 160 || es_t = 220 then gosub victory_text

   ; VICTORY and the relics glow through the title's colours
   temp_acc = frame / 4
   temp_v = (12 + temp_acc) & 15 : P7C1 = (temp_v * 16) + 8
   temp_v = (4 + temp_acc) & 15 : P7C2 = (temp_v * 16) + 6
   temp_v = (1 + temp_acc) & 15 : P7C3 = (temp_v * 16) + 12

   ; fire (a fresh press, not one held from before): skip to the end of
   ; the story, then on to the high scores
   if switchreset then goto cold_start
   if !joy0fire1 then es_ready = 1
   if es_ready = 0 || !joy0fire1 then goto victory_input_done
   es_ready = 0
   if es_t >= 220 then goto enter_hiscore
   es_t = 219
victory_input_done

   ; ---- draw ----
   for iter = 0 to 7
      temp_v = es_x[iter] : temp_w = es_y[iter]
      plotsprite bullet_conv 4 temp_v temp_w
   next
   plotsprite sprite_spaceship1 5 72 es_by 0

   ; relics join one at a time once the ship has arrived, then circle it
   if es_t < 60 then goto victory_no_relics
   temp_bx = es_t - 60 : temp_bx = temp_bx / 10
   if temp_bx > 4 then temp_bx = 4
   temp_by = frame / 4
   for iter = 0 to temp_bx
      temp_acc = relic_spacing[iter] + temp_by : temp_acc = temp_acc & 15
      temp_v = 76 + orbit_x[temp_acc]
      temp_w = es_by + orbit_y[temp_acc] : temp_w = temp_w - 3
      plotsprite relic_gfx 7 temp_v temp_w iter
   next
victory_no_relics

   if es_t >= 220 then if (frame & 32) > 0 then plotchars 'PRESS FIRE' 0 40 11
   drawscreen
   frame = frame + 1
   goto victory_loop

victory_text
   ; the parts that don't move, saved so each frame only plots what moves
   clearscreen
   plotvalue unified_font 0 score0 6 56 0
   plotchars 'VICTORY' 7 52 2
   if es_t >= 40 then plotchars 'RELICS RECOVERED' 1 16 3
   if es_t >= 100 then plotchars 'THE GALAXY IS SAFE' 3 8 9
   if es_t >= 160 then plotchars 'THANKS FOR PLAYING' 5 8 10
   savescreen
   return

gameover_screen
   ; The wreck tumbles away and fades, debris flies off, GAME OVER pulses,
   ; and how far you got: the sector and the relics you'd won.
   gosub StopMusic
   gosub set_palettes
   playsfx sfx_gameover
   for iter = 0 to 7
      temp_v = rand & 127 : es_x[iter] = temp_v + 16
      temp_v = rand : if temp_v > 191 then temp_v = temp_v - 64
      es_y[iter] = temp_v
   next
   for iter = 0 to 3
      deb_x[iter] = 78 : deb_y[iter] = 74
   next
   es_t = 0 : es_ready = 0 : es_sx = 72 : es_sy = 66 : es_fr = 0
   gosub gameover_text

gameover_loop
   restorescreen
   if es_t < 255 then es_t = es_t + 1

   ; stars drift slowly
   if (frame & 3) = 0 then gosub gameover_stars

   ; the wreck tumbles and drifts away
   if (frame & 7) = 0 then es_fr = es_fr + 1 : es_fr = es_fr & 15
   if (frame & 3) = 0 then if es_sy < 124 then es_sy = es_sy + 1
   if (frame & 7) = 0 then if es_sx < 110 then es_sx = es_sx + 1

   ; ...and fades (luminance down to 2, every 16 frames)
   if (frame & 15) = 0 then gosub gameover_fade

   ; debris flies out for the first 48 frames
   if es_t < 48 then deb_x[0] = deb_x[0] - 1 : deb_y[0] = deb_y[0] - 1 : deb_x[1] = deb_x[1] + 1 : deb_y[1] = deb_y[1] - 1
   if es_t < 48 then deb_x[2] = deb_x[2] - 2 : deb_y[2] = deb_y[2] + 1 : deb_x[3] = deb_x[3] + 2 : deb_y[3] = deb_y[3] + 1

   ; GAME OVER pulses red
   temp_v = (frame / 8) & 7 : if temp_v > 3 then temp_v = 7 - temp_v
   temp_v = temp_v * 2
   P6C1 = $40 + temp_v : P6C2 = $44 + temp_v : P6C3 = $48 + temp_v

   if es_t = 60 || es_t = 120 then gosub gameover_text

   if switchreset then goto cold_start
   if !joy0fire1 then es_ready = 1
   if es_ready = 0 || !joy0fire1 then goto gameover_input_done
   es_ready = 0
   if es_t >= 120 then goto enter_hiscore
   es_t = 119
gameover_input_done

   ; ---- draw ----
   for iter = 0 to 5
      temp_v = es_x[iter] : temp_w = es_y[iter]
      plotsprite bullet_conv 4 temp_v temp_w
   next
   if es_t >= 48 then goto gameover_no_debris
   for iter = 0 to 3
      temp_v = deb_x[iter] : temp_w = deb_y[iter]
      plotsprite bullet_conv 2 temp_v temp_w
   next
gameover_no_debris
   plotsprite sprite_spaceship1 5 es_sx es_sy es_fr
   if es_t >= 120 then if (frame & 32) > 0 then plotchars 'PRESS FIRE' 0 40 11
   drawscreen
   frame = frame + 1
   goto gameover_loop

gameover_stars
   for iter = 0 to 5
      temp_v = es_y[iter] + 1
      if temp_v > 191 then temp_v = 0
      es_y[iter] = temp_v
   next
   return

gameover_fade
   temp_v = P5C1 & 15 : if temp_v > 2 then P5C1 = P5C1 - 1
   temp_v = P5C2 & 15 : if temp_v > 2 then P5C2 = P5C2 - 1
   temp_v = P5C3 & 15 : if temp_v > 2 then P5C3 = P5C3 - 1
   return

gameover_text
   clearscreen
   plotvalue unified_font 0 score0 6 56 0
   plotchars 'GAME OVER' 6 44 2
   if es_t >= 120 then plotchars 'YOUR FATE AWAITS' 3 16 3
   if es_t < 60 then goto gameover_text_done
   ; how far you got
   plotchars 'SECTOR' 1 28 9
   plotvalue unified_font 1 current_level 1 92 9
   plotchars 'OF 6' 1 108 9
   ; the relics you'd won (one per sector cleared), centred
   temp_v = current_level - 1
   temp_bx = temp_v * 6 : temp_bx = 80 - temp_bx
   if temp_v >= 1 then plotchars '*' 7 temp_bx 10
   temp_bx = temp_bx + 12
   if temp_v >= 2 then plotchars '+' 7 temp_bx 10
   temp_bx = temp_bx + 12
   if temp_v >= 3 then plotchars '-' 7 temp_bx 10
   temp_bx = temp_bx + 12
   if temp_v >= 4 then plotchars '/' 7 temp_bx 10
   temp_bx = temp_bx + 12
   if temp_v >= 5 then plotchars '<' 7 temp_bx 10
gameover_text_done
   savescreen
   return

   ; circle for the relics (radius 30 across, 24 down) and the ship's bob
   data orbit_x
   30, 28, 21, 11, 0, 245, 235, 228, 226, 228, 235, 245, 0, 11, 21, 28
end
   data orbit_y
   0, 9, 17, 22, 24, 22, 17, 9, 0, 247, 239, 234, 232, 234, 239, 247
end
   data bob_table
   0, 1, 2, 2, 3, 2, 2, 1, 0, 255, 254, 254, 253, 254, 254, 255
end
   data relic_spacing
   0, 3, 6, 10, 13
end

   ; Game over: four falling tones
   data sfx_gameover
   16, 3, 14 ; version, priority, frames per chunk
   $0F,$0C,$08
   $12,$0C,$08
   $15,$0C,$07
   $1A,$0C,$07
   $1A,$0C,$04
   $1A,$0C,$02
   $00,$00,$00
end

   asm
; The five relic icons (* + - / <) as an 8x16 sprite: they are font
; characters 46-50, side by side, so the frame number picks the relic.
relic_gfx = unified_font + 92
relic_gfx_width = 2
relic_gfx_width_twoscompliment = $1E
relic_gfx_mode = unified_font_mode
end

   ; ============================================
   ; POKEY music player (60Hz, from the top-of-screen interrupt)
   ; Data made by tools/vgm2music.py from the Furnace VGM exports.
   ; ============================================

topscreenroutine
   ; Called by 7800basic's NMI as the visible screen starts, every frame,
   ; so the music keeps time even if the game loop drops a frame.
   ; It runs just before 7800basic services the TIA sound effects, so with
   ; hs_mute set we cancel them here (the high score entry clicks).
   asm
   lda hs_mute
   beq ts_music
   lda sfxschedulelock     ; mid-way through scheduling: leave it this frame
   bne ts_music
   lda #0
   sta sfx1pointlo
   sta sfx1pointhi
   sta sfx1pointlo+1
   sta sfx1pointhi+1
   sta AUDV0
   sta AUDV1
ts_music
   jsr mus_tick
end
   return

StopMusic
   asm
   jsr mus_stop
end
   music_ptr_hi = 0 ; pick a song again on the next PlayMusic
   return

PlayMusic
   ; Start the right song if none is chosen yet (music_ptr_hi = 0)
   if music_ptr_hi <> 0 then return
   music_ptr_hi = 1
   if boss_state > 0 && boss_state < 5 then current_song = 4 : goto play_selected
   if current_level = 0 then goto play_title_song
   ; Level songs: 1,4 -> Song_02; 2,5 -> Song_01; 3 -> Song_03; 6 -> Boss
   current_song = 1
   if current_level = 1 || current_level = 4 then current_song = 2
   if current_level = 3 then current_song = 3
   if current_level = 6 then current_song = 4
   goto play_selected
play_title_song
   ; Title rotates through songs 1-3
   if current_song = 0 || current_song > 3 then current_song = 1
play_selected
   temp_v = current_song - 1
   asm
   lda temp_v
   jsr mus_start
end
   return

   asm
; RAM ($2600 page is otherwise unused). Zero page $C0-$C5 is 7800basic's
; tracker block, which this game doesn't use.
musp        = $C0      ; 2: stream pointer
must        = $C2      ; 2: AUDF (or AUDCTL) table pointer
mutc        = $C4      ; 2: AUDC table pointer
mus_on      = $2600
mus_ptrlo   = $2601    ; [5] per voice: ch1-4, AUDCTL
mus_ptrhi   = $2606
mus_wait    = $260B    ; frames still to hold
mus_cur     = $2610    ; current state (table index)
mus_retlo   = $2615    ; where to carry on after a $C0 phrase
mus_rethi   = $261A
mus_endlo   = $261F    ; address just past the phrase
mus_endhi   = $2624
mus_incall  = $2629
mus_stlo    = $262E    ; voice start, for looping
mus_sthi    = $2633
mus_tflo    = $2638
mus_tfhi    = $263D
mus_tclo    = $2642
mus_tchi    = $2647
mus_len     = $264C    ; scratch
mus_reg     = $264D    ; scratch

; mus_start: A = song number (0-3). Called from the game, not the NMI.
mus_start
    sta mus_reg
    lda #0
    sta mus_on              ; keeps mus_tick (and its zero page) out
    lda mus_reg             ; header = mus_songs + song * 30
    asl
    sta mus_len
    asl
    asl
    asl
    asl
    sec
    sbc mus_len
    clc
    adc #<mus_songs
    sta musp
    lda #>mus_songs
    adc #0
    sta musp+1
    ldy #0
    ldx #0
ms_voice
    lda (musp),y
    sta mus_stlo,x
    sta mus_ptrlo,x
    iny
    lda (musp),y
    sta mus_sthi,x
    sta mus_ptrhi,x
    iny
    lda (musp),y
    sta mus_tflo,x
    iny
    lda (musp),y
    sta mus_tfhi,x
    iny
    lda (musp),y
    sta mus_tclo,x
    iny
    lda (musp),y
    sta mus_tchi,x
    iny
    lda #0
    sta mus_wait,x
    sta mus_incall,x
    inx
    cpx #5
    bne ms_voice
    lda #1
    sta mus_on
    rts

mus_stop
    lda #0
    sta mus_on
    sta $0451               ; AUDC1-4 silent
    sta $0453
    sta $0455
    sta $0457
    sta $0458               ; AUDCTL
    rts

; mus_tick: one frame of every voice. Runs in the NMI: uses only its own
; zero page and RAM. Nothing while paused (7800basic silences POKEY then).
mus_tick
    lda pausestate
    bne mt_rts
    lda mus_on
    bne mt_go
mt_rts
    rts
mt_go
    ldx #4
mt_voice
    lda mus_wait,x
    beq mt_read
    dec mus_wait,x
    jmp mt_apply
mt_read
    lda mus_ptrlo,x
    sta musp
    lda mus_ptrhi,x
    sta musp+1
mt_cmd
    lda mus_incall,x        ; end of a $C0 phrase: back to the caller
    beq mt_fetch
    lda musp
    cmp mus_endlo,x
    bne mt_fetch
    lda musp+1
    cmp mus_endhi,x
    bne mt_fetch
    lda mus_retlo,x
    sta musp
    lda mus_rethi,x
    sta musp+1
    lda #0
    sta mus_incall,x
mt_fetch
    ldy #0
    lda (musp),y
    bpl mt_state            ; $00-$7F state
    cmp #$C0
    bcc mt_hold             ; $80-$BF hold
    beq mt_call             ; $C0 phrase
    lda mus_stlo,x          ; $FF: start the voice over
    sta musp
    lda mus_sthi,x
    sta musp+1
    jmp mt_cmd
mt_call
    ldy #3
    lda (musp),y
    sta mus_len
    lda musp
    clc
    adc #4
    sta mus_retlo,x
    lda musp+1
    adc #0
    sta mus_rethi,x
    ldy #1
    lda (musp),y
    pha
    iny
    lda (musp),y
    sta musp+1
    pla
    sta musp
    clc
    adc mus_len
    sta mus_endlo,x
    lda musp+1
    adc #0
    sta mus_endhi,x
    lda #1
    sta mus_incall,x
    jmp mt_cmd
mt_state
    sta mus_cur,x
    jmp mt_advance
mt_hold
    and #$3F
    sta mus_wait,x
mt_advance
    inc musp
    bne mt_store
    inc musp+1
mt_store
    lda musp
    sta mus_ptrlo,x
    lda musp+1
    sta mus_ptrhi,x
mt_apply                    ; write this voice's current state every frame
    lda mus_tflo,x
    sta must
    lda mus_tfhi,x
    sta must+1
    lda mus_tclo,x
    sta mutc
    lda mus_tchi,x
    sta mutc+1
    txa
    asl
    sta mus_reg
    ldy mus_cur,x
    lda (mutc),y
    pha
    lda (must),y
    ldy mus_reg
    cpx #4
    beq mt_audctl
    sta $0450,y             ; AUDFn
    pla
    sta $0451,y             ; AUDCn
    jmp mt_next
mt_audctl
    sta $0458               ; AUDCTL
    pla
mt_next
    dex
    bmi mt_done
    jmp mt_voice
mt_done
    rts

   include "music/music_data.asm"
end

   ; ---- Everything below lives in the DMA hole at $D000 (4KB) ----
   ; Holey DMA makes this space between graphics blocks usable for code.
   dmahole 0

level_complete
   ; All fighters destroyed - level won!
   gosub StopMusic
   clearscreen
   BACKGRND=$00
   
   screen_timer = 60 ; 1s input delay
      
   plotchars 'YOU DID IT' 1 40 2
   
   ; Reward Logic
   if current_level < 6 then plotchars 'REWARD ' 0 20 4
   if current_level = 6 then plotchars 'MISSION ' 0 20 4
   
   if current_level = 1 then plotchars 'INCREASED FIREPOWER' 1 4 6
   if current_level = 2 then plotchars 'INCREASED SPEED'     1 20 6
   if current_level = 3 then plotchars 'MAX HEALTH UP'       1 28 6
   if current_level = 4 then plotchars 'FASTER RECHARGE'     1 20 6
   if current_level = 5 then plotchars 'EXTRA LIFE'          1 40 6
   if current_level = 6 then plotchars 'GALAXY SAVED'        1 32 6
   
   ; Draw Prize Icon
   
   if current_level = 1 then plotchars '*' 7 80 4
   if current_level = 2 then plotchars '+' 7 80 4
   if current_level = 3 then plotchars '-' 7 80 4
   if current_level = 4 then plotchars '/' 7 80 4
   if current_level = 5 then plotchars '<' 7 80 4
   if current_level = 6 then plotchars '<' 7 80 4 ; Human for victory

   plotchars 'PRESS FIRE'     0 40 9
   
   drawscreen
   
   ; Wait for button release
level_complete_release
   if joy0fire1 then goto level_complete_release
   
   ; Wait for button press with timeout
level_complete_wait
   drawscreen ; Sync to 60Hz
   
   frame = frame + 1
   if screen_timer > 0 then screen_timer = screen_timer - 1
   if screen_timer > 0 then goto level_complete_wait
   
   if !joy0fire1 then goto level_complete_wait

level_next_restore
   ; Reward Check
    ; Refresh Shield (+50, max 100, or full on Level 3)
    if game_difficulty = 1 then player_shield = 100
    if game_difficulty = 0 then player_shield = player_shield + 50
    if current_level = 3 then player_shield = 100 ; MAX HEALTH UP reward
    if player_shield > 100 then player_shield = 100
   
   if current_level = 5 then player_lives = player_lives + 1

   ; Advance to next level
   current_level = current_level + 1
   cached_level = current_level  ; Update cache for optimized UI (Bug Fix #3)
   if current_level > 6 then goto you_win_game
   
   ; Reset music to trigger new song selection for this level
   gosub StopMusic
   music_ptr_hi = 0
   
   goto init_level

lose_life
   ; Shields depleted - lose a life
   player_lives = player_lives - 1
   gosub update_bars       ; the killing hit empties the shield bar
   gosub refresh_static_ui ; hearts show the lives left during the explosion

   ; Stop Music
   gosub StopMusic
   
   ; Play Explosion Sound
   playsfx sfx_explode
   
   ; Death Animation Loop (8 frames)
   ; Use simple loop with frame delay
   for temp_val_hi = 0 to 7
      
      ; Delay loop (use screen_timer to avoid clobbering by subroutines)
      ; 10 frames per sprite = ~1.3 seconds total duration
      for screen_timer = 0 to 10
         restorescreen
         
         ; Draw Frozen Game State
         gosub draw_stars
         gosub draw_player_bullets
         gosub draw_enemies
         if alife > 0 then gosub draw_asteroid
         if current_level = 6 then gosub draw_boss
         gosub draw_enemy_bullets
         
         ; Draw Explosion Frame
         ; Uses frame offset (temp_val_hi) from base sprite
         plotsprite fighter_explode_00_conv 1 px_scr py_scr temp_val_hi
         
         drawscreen
      next
   next

   if player_lives <= 0 then goto you_lose

   ; Wait for button release (Debounce)
dying_wait_release
   if joy0fire1 then goto dying_wait_release
   
   screen_timer = 60 ; 1s input delay
   frame = 0
   
   ; Wait for button press to restart
   ; Wait for button press to restart
   ; Wait for button press to restart
dying_wait_press
   restorescreen
   
   ; Redraw Frozen Game State (Keep graphics visible)
   gosub draw_stars
   gosub draw_player_bullets
   gosub draw_enemies
   if alife > 0 then gosub draw_asteroid
   if current_level = 6 then gosub draw_boss
   gosub draw_enemy_bullets
   
   ; Draw final explosion frame (frame 7)
   temp_val_hi = 7
   plotsprite fighter_explode_07_conv 1 px_scr py_scr
   
   plotchars 'SHIP DESTROYED' 1 24 3
   plotchars 'PRESS FIRE'     0 40 7
   
   drawscreen
   
   frame = frame + 1
   if switchreset then goto cold_start
   if screen_timer > 0 then screen_timer = screen_timer - 1
   if screen_timer > 0 then goto dying_wait_press
   
   if !joy0fire1 then goto dying_wait_press
   
   goto restart_level

restart_level
   ; Reset level state after death
   
   player_shield = 100
   
restart_level_common
   ; Common reset logic (used by init_level too)
   ready_flag = 2

   
   ; Reset Physics (Stop movement completely)
   vx_p = 0 : vx_m = 0
   vy_p = 0 : vy_m = 0
   rx = 0 : ry = 0 : acc_mx = 0 : acc_my = 0 ; Clear accumulators
   angle = 0 : rot_timer = 0 ; Reset orientation
   
   ; Reset Boss State
   boss_state = 0 
   boss_on = 0
   ; boss_checkpoint is PRESERVED here to allow retrying boss at 50% HP
   ; Boss HP will be set by init_boss when needed
   
   ; Clear bullets
   shpfr = 0 ; Reset sprite frame
   frame = 0 ; Reset frame counter for clean start
   
   ; Initialize boss (Level 6) - Reset HP on any restart (death or level start)
   if current_level = 6 then gosub init_boss
   
   ; Reset prizes
   
   ; Reset prizes
   prize_active0 = 1
   prize_active1 = 1
   prize_active2 = 1
   prize_active3 = 1
   prize_active4 = 1
   
   ; Clear screen from level complete/death displays
   clearscreen
   
   ; Redraw and save static UI elements (hearts, treasures, bars)
   gosub update_bars
   gosub refresh_static_ui
   
   ; Reset player position - Segment 1 (Center of 512x512)
   px = 72 : py = 90
   px_hi = 1 : py_hi = 1
   ; Camera removed
   
   ; Clear enemies/bullets/asteroids
   for iter = 0 to 3
      elife[iter] = 0
      blife[iter] = 0
      eblife[iter] = 0
   next
   
   bflife[0]=0 : bflife[1]=0
   bf_bul_life = 0
   bf_fire_cooldown = 0
   energy_on = 0
   bf_kill_count = 0

   
   ; Immediate Spawn of Blue Fighters
   gosub spawn_blue_fighter ; Slot 0
   gosub spawn_blue_fighter ; Slot 1
   
   alife = 0


   ; Force asteroid to safe off-screen position (Page 0, Center)
   ax = 128 : ax_hi = 0
   ay = 128 : ay_hi = 0
   avx = 0 : avy = 0
   ax_scr = 240 : ay_scr = 240
   
   goto main_loop

init_level
   ; Initialize new level
   boss_checkpoint = 0 ; Reset checkpoint for new level
   
   ; Set fighters for the new level
   gosub set_level_fighters
   fighters_bcd = converttobcd(fighters_remaining)
   
   gosub set_level_config
   
   goto restart_level_common


set_level_fighters
   ; Set fighter count based on level
   if current_level = 1 then fighters_remaining = 20
   if current_level = 2 then fighters_remaining = 40
   if current_level = 3 then fighters_remaining = 60
   if current_level = 4 then fighters_remaining = 80
   if current_level >= 5 then fighters_remaining = 99
   
   ; Level 6: Boss Level (Keep enemies active for now as requested)
   if current_level = 6 then fighters_remaining = 99
   return

set_level_config
   ; Configure enemy speed and fire rate based on level
   ; 
   ; enemy_move_mask: Controls movement speed via frame masking
   ;   Mask = 1: Move 1px per 2 frames (slow)
   ;   Mask = 0: Move 1px per frame (fast)
   ;
   ; enemy_fire_cooldown: Frames between enemy shots
   ;   Higher = slower fire rate, Lower = rapid fire
   
   if current_level = 1 then enemy_move_mask = 2 : enemy_fire_cooldown = 60 : asteroid_move_mask = 3 : asteroid_base_speed = 1
   if current_level = 2 then enemy_move_mask = 1 : enemy_fire_cooldown = 45 : asteroid_move_mask = 1 : asteroid_base_speed = 1
   if current_level = 3 then enemy_move_mask = 1 : enemy_fire_cooldown = 30 : asteroid_move_mask = 1 : asteroid_base_speed = 1
   if current_level = 4 then enemy_move_mask = 0 : enemy_fire_cooldown = 25 : asteroid_move_mask = 0 : asteroid_base_speed = 1
   if current_level >= 5 then enemy_move_mask = 0 : enemy_fire_cooldown = 20 : asteroid_move_mask = 0 : asteroid_base_speed = 2
    ; Easy Mode Scaling (game_difficulty = 1)
    if game_difficulty = 1 then enemy_move_mask = enemy_move_mask | 1
    if game_difficulty = 1 then enemy_fire_cooldown = enemy_fire_cooldown + 10
    if game_difficulty = 1 then asteroid_base_speed = 1
   return

you_win_game
   goto victory_screen

you_lose
   goto gameover_screen

game_over_restore
   goto cold_start

spawn_blue_fighter
   ; Find free Blue Fighter slot
   for iter = 0 to 1
      if bflife[iter] = 0 then goto do_spawn_bf
   next
   return
   
do_spawn_bf
   ; Spawn Blue Fighter
   bflife[iter] = 1
   
   bfx[iter] = 200
   bfx_hi[iter] = 0
   
   temp_v = rand
   if temp_v < 20 then temp_v = 20
   if temp_v > 172 then temp_v = 172
   bfy[iter] = temp_v
   bfy_hi[iter] = 1 ; Same Y-zone as player (Zone 1)
   
   bfby[iter] = bfy[iter] ; Reset base Y for oscillation
   
   return
   
update_blue_fighters
   ; Update both Blue Fighters (runs BEFORE shift_universe)
   ; Uses proper overflow detection: if new < old, then wrapped
   for iter = 0 to 1
      if bflife[iter] = 0 then goto next_bf
      if bflife[iter] > 1 then bflife[iter] = bflife[iter] - 1 : if bflife[iter] = 1 then bflife[iter] = 0 : goto next_bf 
      
      ; --- Firing Logic ---
      if bf_bul_life > 0 then goto skip_bf_fire
      if bf_fire_cooldown > 0 then goto skip_bf_fire
      if bfx_hi[iter] <> 1 then goto skip_bf_fire

      if bfy_hi[iter] <> 1 then goto skip_bf_fire
      if bfx[iter] > 152 then goto skip_bf_fire
      if bfy[iter] > 184 then goto skip_bf_fire
      
      ; Fire!
      gosub fire_bf_bullet
skip_bf_fire

      ; --- Respawn Check (If scrolled too far right) ---
      ; Player is at X=80 in Zone 1,1. 
      ; If fighter is at X>200 in Zone 1,1, it's way behind (visible screen is ~160).
      if bfx_hi[iter] = 1 then if bfy_hi[iter] = 1 then if bfx[iter] > 200 then gosub do_spawn_bf
      
      ; --- Horizontal Movement (Accumulator linear 0.75px/frame) ---
      temp_v = bfx_acc[iter]
      bfx_acc[iter] = bfx_acc[iter] + 192
      if bfx_acc[iter] < temp_v then goto bf_move_x_pixel
      goto bf_move_x_done
      
bf_move_x_pixel
      temp_v = bfx[iter] 
      bfx[iter] = bfx[iter] + 1 
      if bfx[iter] < temp_v then bfx_hi[iter] = bfx_hi[iter] + 1 
      if bfx_hi[iter] >= 2 then bfx_hi[iter] = 0
bf_move_x_done

      ; --- Vertical Oscillation (Large Triangle Wave / Square Velocity) ---
      ; 1. Calculate Phase (Period 256 frames - Slower/Wider Pattern)
      temp_v = (frame + (iter * 128))
      
      ; 2. Set Constant Velocity (Square wave velocity centered at 0)
      ;    254 is -2, 2 is +2. 
      if temp_v & 128 then temp_acc = 254 else temp_acc = 2
      
      ; 3. Scale Velocity (Tweakable amplitude/speed)
      ;    2 * 64 = 128 subpixels/frame (0.5 px/frame)
      ;    Over 128 frames per direction = 64 pixels total travel.
      temp_w = temp_acc * 64
      
      ; 4. Add to Accumulator
      temp_v = bfy_acc[iter] ; Old Acc
      bfy_acc[iter] = bfy_acc[iter] + temp_w
      
      ; 5. Apply Pixel Change based on Sign and Carry
      if temp_acc >= 128 then goto bf_osc_neg
      
bf_osc_pos
      ; Positive Velocity: If Acc wrapped (new < old), we carried +1
      if bfy_acc[iter] < temp_v then goto bf_pixel_down 
      goto bf_osc_done

bf_osc_neg
      ; Negative Velocity: High byte is -1 ($FF). 
      ; If Acc wrapped (new < old), we carried +1. Total -1+1=0 (No pixel change).
      ; If Acc did NOT wrap, High byte stays -1. Total -1 (Pixel up).
      if bfy_acc[iter] < temp_v then goto bf_osc_done
      goto bf_pixel_up

bf_pixel_down
      temp_v = bfy[iter]
      bfy[iter] = bfy[iter] + 1
      if bfy[iter] < temp_v then bfy_hi[iter] = bfy_hi[iter] + 1
      if bfy_hi[iter] >= 2 then bfy_hi[iter] = 0
      goto bf_osc_done

bf_pixel_up
      temp_v = bfy[iter]
      bfy[iter] = bfy[iter] - 1
      if bfy[iter] > temp_v then bfy_hi[iter] = bfy_hi[iter] - 1
      if bfy_hi[iter] = 255 then bfy_hi[iter] = 1

bf_osc_done

next_bf
   next
   return

update_bf_render_coords
   ; Calculate screen coordinates based on 4-zone map: (0,0),(1,0),(0,1),(1,1)
   for iter = 0 to 1
      if bflife[iter] = 0 then bf_on[iter] = 0 : goto next_bf_render
      
      ; --- X Axis --- Zone map: (0,0)(1,0) top, (0,1)(1,1) bottom
      if bfx_hi[iter] = 1 then goto bf_check_x_center
      if bfx_hi[iter] = 0 then goto bf_check_x_left
      bf_on[iter] = 0 : goto next_bf_render

bf_check_x_center
      ; Hi=1 (Zone 1,y): Center/Right - visible 0 <= x < 160
      bfx_scr[iter] = bfx[iter]
      if bfx_scr[iter] >= 160 then bf_on[iter] = 0 : goto next_bf_render
      goto bf_x_ok

bf_check_x_left
      ; Hi=0 (Zone 0,y): Left - visible 247 < x <= 255
      bfx_scr[iter] = bfx[iter]
      if bfx_scr[iter] <= 247 then bf_on[iter] = 0 : goto next_bf_render
      if bfx_scr[iter] = 0 then bf_on[iter] = 0 : goto next_bf_render

bf_x_ok
      ; --- Y Axis ---
      if bfy_hi[iter] = 1 then goto bf_check_y_bottom
      if bfy_hi[iter] = 0 then goto bf_check_y_top
      bf_on[iter] = 0 : goto next_bf_render

bf_check_y_bottom
      ; Hi=1 (Zone x,1): Bottom - visible 0 <= y < 192
      bfy_scr[iter] = bfy[iter]
      if bfy_scr[iter] >= 192 then bf_on[iter] = 0 : goto next_bf_render
      goto bf_y_ok

bf_check_y_top
      ; Hi=0 (Zone x,0): Top - visible 247 < y <= 255
      bfy_scr[iter] = bfy[iter]
      if bfy_scr[iter] <= 247 then bf_on[iter] = 0 : goto next_bf_render
      if bfy_scr[iter] = 0 then bf_on[iter] = 0 : goto next_bf_render

bf_y_ok
      bf_on[iter] = 1
next_bf_render
   next
   return
draw_blue_fighters
   ; Draw Blue Fighters (separate pool)
   for iter = 0 to 1
      if bf_on[iter] = 0 then goto next_draw_bf
      temp_v = bfx_scr[iter]
      temp_w = bfy_scr[iter]
      
      if bflife[iter] > 1 then goto draw_bf_explosion
      plotsprite blue_fighter 3 temp_v temp_w
      goto next_draw_bf
      
draw_bf_explosion
      temp_acc = 18 - bflife[iter]
      temp_acc = temp_acc / 2
      if temp_acc > 7 then temp_acc = 7
      plotsprite fighter_explode_00_conv 3 temp_v temp_w temp_acc
next_draw_bf
   next
   return

fire_bf_bullet
   bf_bul_life = 60
   bf_fire_cooldown = 30 ; 0.5s cooldown
   
   bf_bul_x = bfx[iter] + 4

   bf_bul_y = bfy[iter] + 4
   
   if px_scr > bfx[iter] then bf_bul_vx = 4 else bf_bul_vx = 252 ; +4 or -4
   if py_scr > bfy[iter] then bf_bul_vy = 4 else bf_bul_vy = 252 ; +4 or -4
   
   playsfx sfx_enemyfire 0
   return

update_bf_bullet
   if bf_bul_life = 0 then return
   
   bf_bul_life = bf_bul_life - 1
   
   ; X Movement
   temp_v = bf_bul_vx
   bf_bul_x = bf_bul_x + temp_v
   
   ; Bounds Check X
   if bf_bul_x > 165 then if bf_bul_x < 240 then bf_bul_life = 0
   
   ; Y Movement
   temp_v = bf_bul_vy
   bf_bul_y = bf_bul_y + temp_v
   
   ; Bounds Check Y
   if bf_bul_y > 195 then if bf_bul_y < 240 then bf_bul_life = 0
   
   return

draw_bf_bullet
   if bf_bul_life = 0 then return
   plotsprite bullet_conv 6 bf_bul_x bf_bul_y
   return

