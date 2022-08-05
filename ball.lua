#include game_loop.lua

--ball
dx=1
dy=1
clr=10
rad=2
x_prev=0
y_prev=0

function draw_ball()
	circfill(x,y,rad,clr)
end

function move_ball()
	--updates ball position
--	x_prev=x
--	y_prev=y
	if powerup==4 then
		x=mid(0+rad,x+(dx/2),127-rad)
		y+=(dy/2)
	else
		x=mid(0+rad,x+dx,127-rad)
		y+=dy
	end
	if x+rad>=127 or x-rad<=0 then
		dx=-dx
		sfx(0)
	end
	if y-rad<=7 then
		dy=-dy
		sfx(0)
	end
	if y+rad>=131 then
		lose_life()
		combo=1
	end
end

function check_collision(obj_x,obj_y,obj_w,obj_h)
	--checks if ball hits something
	if (y+dy)-rad > obj_y+obj_h then
		return false
	end
	if (y+dy)+rad < obj_y then
		return false
	end
		if (x+dx)-rad > obj_x+obj_w then
		return false
	end
	if (x+dx)+rad < obj_x then
		return false
	end
	return true
end

function collision_direction(bx,by,bdx,bdy,tx,ty,tw,th)
 local slp
 if not(bdx==0) then
 	slp = bdy / bdx
 else
 	slp = nil
 end
 local cx, cy
 if bdx == 0 then
  return false
 elseif bdy == 0 then
  return true
 elseif slp > 0 and bdx > 0 then
  cx = tx - bx
  cy = ty - by
  return cx > 0 and cy/cx < slp
 elseif slp < 0 and bdx > 0 then
	 cx = tx - bx
  cy = ty + th - by
  return cx > 0 and cy/cx >= slp
 elseif slp > 0 and bdx < 0 then
  cx = tx + tw - bx
  cy = ty + th - by
  return cx < 0 and cy/cx <= slp
 else
 	cx = tx + tw - bx
  cy = ty - by
  return cx < 0 and cy/cx >= slp
 end
end

function change_angle(ang)
 angle=ang
 if ang==0 then
 	dx=sgn(dx)*1.3
 	dy=sgn(dy)*0.5
 elseif ang==2 then
 	dx=sgn(dx)*0.5
 	dy=sgn(dy)*1.3
 else
 	dx=sgn(dx)
 	dy=sgn(dy)
 end
end