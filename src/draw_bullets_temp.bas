draw_player_bullets
   for iter = 0 to 3
      if blife[iter] = 0 then goto skip_draw_bul
      
      ; 16-bit Distance Check
      ; Calculate High Byte difference (handling wrap)
      temp_val_hi = bul_x_hi[iter] - cam_x_hi
      if temp_val_hi = 3 then temp_val_hi = 255 ; Treated as -1
      if temp_val_hi = 253 then temp_val_hi = 1 ; -3 -> 1 (e.g. 0 - 3 = -3 = 253)
      
      ; Now temp_val_hi is 0, 1, or 255 (-1) if close.
      ; If > 1 and < 255, it's far.
      if temp_val_hi > 1 && temp_val_hi < 255 then goto skip_draw_bul
      
      ; Calculate Screen X
      temp_v = bul_x[iter] - cam_x
      
      ; Filter Ghosts
      ; If Hi=1 (Right), we expect Bul < Cam (wrapped).
      ; e.g. Bul=10, Cam=250. 10 < 250.
      ; temp_v = 16. Correct.
      ; If Bul > Cam (e.g. Bul=100, Cam=50), Hi=1 implies dist = 256+50 = 306.
      ; temp_v = 50. Ghost!
      ; So if Hi=1, we require Bul < Cam?
      ; bul_x < cam_x is not safe signed comparison.
      ; Use temp_v.
      ; If Hi=1, temp_v should be "small positive" corresponding to the wrap.
      ; And `bul_x` should be less than `cam_x` (unsigned).
      if temp_val_hi = 1 then
          if bul_x[iter] >= cam_x then goto skip_draw_bul
      endif
      
      ; If Hi=-1 (Left), we expect Bul > Cam.
      ; e.g. Bul=250, Cam=10. 250 > 10.
      ; temp_v = 240 (-16).
      ; Drawn at 240 (off screen left?).
      ; If Bul < Cam (Bul=50, Cam=100), Hi=-1 implies dist = -256-50 = -306.
      ; temp_v = -50 (206).
      ; Drawn at 206. Ghost?
      if temp_val_hi = 255 then
          if bul_x[iter] <= cam_x then goto skip_draw_bul
      endif

      temp_w = bul_y[iter] - cam_y
      
      plotsprite bullet_conv 1 temp_v temp_w
      
skip_draw_bul
   next
   return
