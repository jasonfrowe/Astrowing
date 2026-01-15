draw_enemy_bullets
   for iter = 0 to 3
      if eblife[iter] = 0 then goto skip_draw_ebul
      
      ; 16-bit Distance Check (High Byte)
      temp_val_hi = ebul_x_hi[iter] - cam_x_hi
      if temp_val_hi = 3 then temp_val_hi = 255 ; Wrap 3->0 (-1)
      if temp_val_hi = 253 then temp_val_hi = 1 ; Wrap 0->3 (1)
      
      ; Filter Far
      if temp_val_hi > 1 && temp_val_hi < 255 then goto skip_draw_ebul
      
      ; Screen X
      temp_v = ebul_x[iter] - cam_x
      
      ; Filter Ghosts
      ; Hi=1 (Right of Cam): Expect Bul < Cam.
      if temp_val_hi = 1 then
          if ebul_x[iter] >= cam_x then goto skip_draw_ebul
      endif
      
      ; Hi=-1 (Left of Cam): Expect Bul > Cam.
      if temp_val_hi = 255 then
          if ebul_x[iter] <= cam_x then goto skip_draw_ebul
      endif

      temp_w = ebul_y[iter] - cam_y
      
      plotsprite bullet_conv 3 temp_v temp_w
      
skip_draw_ebul
   next
   return
