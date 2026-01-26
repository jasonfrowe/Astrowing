   set romsize 128k
   set 7800header 'name Astro Wing Banked'
   set hssupport $4157
   set pokeysupport $450
   set zoneheight 16
   displaymode 160A
   set doublewide on
   
   bank 1

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
   dim bul_x = var18 ; uses 18, 19, 20, 21
   dim bul_y = var22 ; uses 22, 23, 24, 25
   dim bul_vx = var26 ; uses 26, 27, 28, 29
   dim bul_vy = var30 ; uses 30, 31, 32, 33
   dim blife = var34 ; uses 34, 35, 36, 37
   
   dim player_lives = $254B ; Lives Variable (Safe from collisions)

   ; Enemy Bullet Variables (Pool of 2)
   dim ebul_x  = var60 ; 60-63
   dim ebul_y  = var64
   dim ebul_vx = var68 ; 68-71
   dim ebul_vy = $2560 ; Moved to 160 safe zone
   dim eblife  = $2564 ; 164-167

   dim temp_val_hi = $2590
   dim ecooldown = var72
   dim temp_w = var73
   
   ; Level Difficulty Config
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
   
   ; Starfield Variables (4 stars used)
   dim star_x = var80 ; 80-83 (Array [4])
   dim star_y = $2500 ; 2500-2519
   dim star_c = $2520 ; 2520-2539
   dim sc1 = $2544
   dim sc2 = $2545
   dim sc3 = $2546
   dim cycle_state = $2547

   ; Enemy Variables (Pool of 4)
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

   ; Music State (Safe Zone per MEMORY_MAP)
   dim music_active = $25AC ; 0=Stopped, 1=Playing
   dim music_ptr_lo = $25AA
   dim music_ptr_hi = $25AB
   dim current_song = $25AF ; 1=Song_01, 2=Song_02 
   
   ; ASM Driver uses dedicated ZP vars
   dim music_zp_lo = var98
   dim music_zp_hi = var99
   
   dim rand_val = $254C
   dim screen_timer = $254D ; Generic timeout timer
   
   ; Asteroid Variables
   dim ax = $2550
   dim ay = $2551
   dim avx = $2552
   dim avy = $2553
   dim alife = $2554
   dim ax_hi = $2555
   dim ay_hi = $2556
   dim asteroid_timer = $2559  
   dim boss_asteroid_cooldown = $255A 
   dim boss_attack_timer = $255A      
   dim ast_acc_x = $255B 
   dim ast_acc_y = $255C 
   
   ; Blue Fighter Variables (Separate Pool of 2)
   dim bfx = $25D8      
   dim bfy = $25DA      
   dim bflife = $25DC   
   dim bfx_hi = $25DE   
   dim bfy_hi = $25E0   
   dim bfby   = $25E2   
   dim bfx_scr = $25E4  
   dim bfy_scr = $25E6  
   dim bf_on   = $25E8  
   dim bfx_acc = $25EA  
   dim bfy_acc = $25EC  
   
   ; Blue Fighter Bullet
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
   dim title_display_state = $25FA
   dim title_rendered_state = $25FB  ; FF=Dirty
   dim hst_scr = $25FC ; 3 bytes
   dim h_char = $25FF  ; Temp char for plotting
   
   ; Aliases
   dim bul_x0 = var18 : dim bul_x1 = var19 : dim bul_x2 = var20 : dim bul_x3 = var21
   dim bul_y0 = var22 : dim bul_y1 = var23 : dim bul_y2 = var24 : dim bul_y3 = var25
   dim blife0 = var34 : dim blife1 = var35 : dim blife2 = var36 : dim blife3 = var37

   ; Cached Render Coordinates
   dim px_scr = $2591
   dim py_scr = $2592
   dim ex_scr = $2593 
   dim ey_scr = $2597 
   dim ax_scr = $259B
   dim ay_scr = $259C
   dim e_on   = $259D 
   dim a_on   = $25A1
   
   dim fighters_remaining = $2548
   dim player_shield = $2549
   dim current_level = $25A4
   dim fighters_bcd = $2557
   dim game_difficulty = $2558 ; 0=Pro, 1=Easy
   
   dim cached_lives = $2572
   dim cached_level = $2573
   dim cached_boss_hp = $2574
   dim cached_shield = $2575
   dim px_hi = $2570
   dim py_hi = $2571
   dim prize_active0 = $25A5
   dim prize_active1 = $25A6
   dim prize_active2 = $25A7
   dim prize_active3 = $25A8
   dim prize_active4 = $25A9

cold_start
   ; Wait for Reset button to be released!
reset_release_wait
   if switchreset then goto reset_release_wait
   
   screen_timer = 60 ; 1s input delay
   music_active = 0 
   current_song = 1 

   ; Palette Setup
   P0C1=$26: P0C2=$24: P0C3=$04 ; Background/UI
   P1C1=$C2: P1C2=$C6: P1C3=$CA ; Player Bullets (Green)
   P2C1=$04: P2C2=$08: P2C3=$0C ; Asteroids (Greys)
   P3C1=$B4: P3C2=$46: P3C3=$1C ; Enemy (Green, Red, Yellow)
   P4C1=$08: P4C2=$0C: P4C3=$0F ; Stars
   P5C1=$34: P5C2=$86: P5C3=$0A ; Spaceship
   P6C1=$42: P6C2=$46: P6C3=$4A ; Enemy Bullets (Red)
   P7C1=$C8: P7C2=$46: P7C3=$1C ; Title Screen (Vibrant)

   BACKGRND=$00
   
   ; Initialize difficulty settings
   enemy_move_mask = 1
   enemy_fire_cooldown = 60
   asteroid_move_mask = 3
   asteroid_base_speed = 1
   
   player_lives = 3
   current_level = 1
   asteroid_timer = 0
   boss_asteroid_cooldown = 0

   goto title_entry_point bank3

init_game
     clearscreen
     gosub StopMusic
     music_ptr_hi = 0
     
     player_lives = 3
     current_level = 1
     fighters_remaining = 20
     fighters_bcd = converttobcd(20)
     
     px = 72 : px_hi = 1
     py = 90 : py_hi = 1
     
     goto cold_start

   ; --- BANK 3: Title Screen ---
   bank 3
   incbanner graphics/title_screen_conv.png 160A 0 1 2 3
   
title_entry_point
title_loop
title_release_wait
    if joy0fire1 || switchreset then goto title_release_wait

    clearscreen
    alife=0
    for iter=0 to 3
       elife[iter]=0
    next
    
    plotbanner title_screen_conv 7 0 46
    
    characterset unified_font
    plotchars 'VERSION' 1 20 11
    plotchars '*+-/<' 7 60 1
    plotchars '20260126' 1 84 11
    
    plotchars 'DIFFICULTY' 1 20 9
    if switchleftb then plotchars 'EASY' 5 108 9 else plotchars 'PRO ' 5 108 9
    
    drawscreen
    
    ; Hue Cycle Animation
    temp_acc = frame / 4
    temp_v = (12 + temp_acc) & 15
    temp_v = (temp_v * 16) + 8
    P7C1 = temp_v
    
    temp_v = (4 + temp_acc) & 15
    temp_v = (temp_v * 16) + 6
    P7C2 = temp_v
    
    temp_v = (1 + temp_acc) & 15
    temp_v = (temp_v * 16) + 12
    P7C3 = temp_v

    if joy0fire1 then goto restore_pal_story
    
    frame = frame + 1
   asteroid_timer = asteroid_timer + 1 
   if asteroid_timer = 0 then boss_asteroid_cooldown = boss_asteroid_cooldown + 1 
   
   if boss_asteroid_cooldown >= 28 then gosub rotate_music bank3

    gosub PlayMusic 

    if !switchreset then goto title_no_reset
title_reset_wait
    if switchreset then goto title_reset_wait
    goto restore_pal_game
title_no_reset
    if screen_timer > 0 then screen_timer = screen_timer - 1
    if screen_timer > 0 then goto title_loop
    
    goto title_loop

restore_pal_story
   P7C1=$C8: P7C2=$46: P7C3=$1C
   goto init_game bank1

restore_pal_game
   P7C1=$C8: P7C2=$46: P7C3=$1C
   goto init_game bank1
   
rotate_music
   boss_asteroid_cooldown = 0
   asteroid_timer = 0
   current_song = current_song + 1
   if current_song > 3 then current_song = 1
   
   gosub StopMusic
   music_ptr_hi = 0
   gosub PlayMusic
   return

   ; --- BANK 8 (Fixed): Drivers & Globally accessible data ---
   bank 8
   
StopMusic
   asm
   lda #0
   sta $0450 ; AUDC0
   sta $0451 ; AUDC1
   sta $0452 
   sta $0453 
   sta $0454
   sta $0455
   sta $0456
   sta $0457
   sta music_active
   rts
end

PlayMusic
   asm
   lda music_active
   bne .Continue
   
   lda #1
   sta music_active
   
   lda current_song
   cmp #1
   beq .UseSong1
   jmp .UseSong1 ; Fallback
   
.UseSong1:
   lda #<Song_01_Data
   sta music_ptr_lo
   lda #>Song_01_Data
   sta music_ptr_hi
   
.Continue:
   lda music_ptr_lo
   sta $E2
   lda music_ptr_hi
   sta $E3
   
   ldy #0
.Loop:
   lda ($E2),y
   cmp #$FF
   beq .EndFrame
   cmp #$FE
   beq .EndSong
   
   tax            ; X = Register
   iny
   lda ($E2),y  ; A = Value
   sta $0450,x    ; Write to POKEY
   iny
   cpy #64
   bcs .EndFrame
   bne .Loop
   
.EndFrame:
   iny
   tya
   clc
   adc music_ptr_lo
   sta music_ptr_lo
   lda music_ptr_hi
   adc #0
   sta music_ptr_hi
   rts
   
.EndSong:
   lda #<Song_01_Data
   sta music_ptr_lo
   lda #>Song_01_Data
   sta music_ptr_hi
   rts
end
   
   asm
Song_01_Data:
   incbin "music/Song_01.bin"
end
   
   ; Font is Fixed - visible to all banks
   incgraphic graphics/unified_font.png 160A 0 1 2 3
