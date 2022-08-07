--ball
clr=10
rad=2
x_prev=0
y_prev=0

function draw_ball()
	for ball in all(balls) do
		circfill(ball.x,ball.y,rad,clr)
	end
end

function move_ball(ball)
	local x, dx, dy = ball.x, ball.dx, ball.dy
	--updates ball position
--	x_prev=x
--	y_prev=y
	if powerup==4 then
		ball.x=mid(0+rad,x+(dx/2),127-rad)
		ball.y+=(dy/2)
	else
		ball.x=mid(0+rad,x+dx,127-rad)
		ball.y+=dy
	end
	if ball.x+rad>=127 or ball.x-rad<=0 then
		ball.dx=-dx
		sfx(0)
	end
	if ball.y-rad<=7 then
		ball.dy=-dy
		sfx(0)
	end
	if  ball.y+rad>=131 then
		del(balls, ball)
		if #ball < 1 then
			lose_life()
		end
		combo=1
	end
end

function check_collision(ball, obj_x,obj_y,obj_w,obj_h)
	-- if (ball.y+ball.dy)-rad > obj_y+obj_h then
    --     return false
    -- end
    -- if (ball.y+ball.dy)+rad < obj_y then
    --     return false
    -- end
    --     if (ball.x+ball.dx)-rad > obj_x+obj_w then
    --     return false
    -- end
    -- if (ball.x+ball.dx)+rad < obj_x then
    --     return false
    -- end
    -- return true
	return check_collision2(obj_x,obj_y,obj_w,obj_h,(ball.x+ball.dx)-rad,(ball.y+ball.dy)-rad,rad*2,rad*2)
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

function change_angle(ball, ang)
	ball.ang=ang
 	if ang==0 then
 		ball.dx=sgn(ball.dx)*1.3
 		ball.dy=sgn(ball.dy)*0.5
	elseif ang==2 then
 		ball.dx=sgn(ball.dx)*0.5
 		ball.dy=sgn(ball.dy)*1.3
	else
 		ball.dx=sgn(ball.dx)
 		ball.dy=sgn(ball.dy)
 	end
end

function newball()
	local b = {
		x   = 0,
		y   = 0,
		dx  = 0,
		dy  = 0,
		ang = 0
	}
	return b
end

function update_ball(ball)
	if sticky then
		if last_dir=="right" then
			balls[1].dx=1
		else
			balls[1].dx=-1
		end
		balls[1].x=pad_x+offset
		balls[1].x=mid(0+rad,balls[1].x,127-rad)
	--	x_prev=x
	--	y_prev=pad_y-3
	else
		
		--check if hit pad
		if check_collision(ball, pad_x,pad_y,pad_w,pad_h) then
			-- check direction
			if collision_direction(ball.x+ball.dx,ball.y+ball.dy,ball.dx,ball.dy,pad_x,pad_y,pad_w,pad_h) then
				ball.dx=-ball.dx
				if ball.x<pad_x+(pad_w/2) then
					ball.x=pad_x-rad
				else
					ball.x=pad_x+pad_w+rad
				end
			else
				ball.dy=-ball.dy
				--bottom
				if ball.y>pad_y then
					ball.y=pad_y+pad_h+rad
				else
				 --top
					ball.y=pad_y-rad
					--change angle
					if abs(pad_dx)>2 then
					 --	flatten angle
						if sgn(pad_dx)==sgn(ball.dx) then
							change_angle(ball, mid(0,ball.ang-1,2))
						else
							--raise angle
							if ball.ang==2 then
								ball.dx=-ball.dx
							else
								change_angle(ball, mid(0,ball.ang+1,2))
							end
						end
					end
				end
			end
			sfx(1)
			combo=1
			if powerup==2 and dy<0 then
				sticky=true
				powerup=0
				offset=ball.x-pad_x
			end
		end
		move_ball(ball)
	end
	for i=1,#bricks do
		-- check if hit brick
		if not(bricks[i].brk) and check_collision(ball,bricks[i].x,bricks[i].y,brick_w,brick_h) then
		-- no collision if megaball
			if powerup!=1 or bricks[i].t=="i" then
			-- check direction
				if collision_direction(ball.x,ball.y,ball.dx,ball.dy,bricks[i].x,bricks[i].y,brick_w,brick_h) then
					ball.dx=-ball.dx
				else
					ball.dy=-ball.dy
				end
			end
			hitbrick(i,true)
			break
		end
	end
end
