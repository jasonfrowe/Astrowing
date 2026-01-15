draw_enemies
   for iter = 0 to 3
      if elife[iter] = 0 then goto skip_draw_enemy
      
      ; Calculate Screen X
      temp_v = ex[iter] - cam_x
      
      ; Manual Culling
      if temp_v > 165 then if temp_v < 240 then goto skip_draw_enemy
      
      temp_w = ey[iter] - cam_y
      if temp_w > 200 then goto skip_draw_enemy
      
      plotsprite fighter_conv 3 temp_v temp_w

skip_draw_enemy
   next
   return
