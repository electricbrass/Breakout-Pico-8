pico-8 cartridge // http://www.pico-8.com
version 35
__lua__
--game loop
function _update60()
	if gamestate=="start" then
		game_start()
	elseif gamestate=="game" then
		update_game()
	elseif gamestate=="gameover" then
		update_gameover()
	elseif gamestate=="levelover" then
		update_levelover()
	end
end

function _draw()
	if gamestate=="start" then
		draw_start()
	elseif gamestate=="game" then
		draw_game()
	elseif gamestate=="gameover" then
		draw_gameover()
	elseif gamestate=="levelover" then
		draw_levelover()
	end
end

function _init()
	cls(0)
	gamestate="start"
	sticky=true
	combo=1
	levelnum=1
	levels={}
	levels[1]="x6b"
 levels[2]="b9bb9bb9bb9bb9bb9b"
	levels[3]="bxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbx"
	levels[1]="bxhxixexp"
	levels[1]="i999999bbbhhhppee"
	levels[1]="e9999999"
	levels[1]="p999"
	levels[1]="b9bi9ii9ii9ibxxxxxb"
end

function serveball()
	x=pad_x+flr(pad_w0/2)
	y=117
	dx=1
	dy=-1
	sticky=true
	last_dir="right"
	angle=1
	resetpickups()
	powerup=0
	powerup_t=0
	offset=flr(pad_w0/2)
	mult=0
end

function update_game()
	move_paddle()
	move_pwp()
	if sticky and btnp(5) then
		sticky=false
		powerup=0
	end
	if sticky then
		if last_dir=="right" then
			dx=1
		else
		 dx=-1
		end
		x=pad_x+offset
		x=mid(0+rad,x,127-rad)
	--	x_prev=x
	--	y_prev=pad_y-3
	else
		
		--check if hit pad
		if check_collision(pad_x,pad_y,pad_w,pad_h) then
			-- check direction
			if collision_direction(x+dx,y+dy,dx,dy,pad_x,pad_y,pad_w,pad_h) then
				dx=-dx
				if x<pad_x+(pad_w/2) then
				 x=pad_x-rad
				else
					x=pad_x+pad_w+rad
				end
			else
				dy=-dy
				--bottom
				if y>pad_y then
				 y=pad_y+pad_h+rad
				else
				 --top
					y=pad_y-rad
					--change angle
					if abs(pad_dx)>2 then
					 --	flatten angle
						if sgn(pad_dx)==sgn(dx) then
							change_angle(mid(0,angle-1,2))
						else
							--raise angle
							if angle==2 then
								dx=-dx
							else
								change_angle(mid(0,angle+1,2))
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
			 offset=x-pad_x
			end
		end
		move_ball()
	end
	for i=1,#bricks_x do
		-- check if hit brick
		if not(bricks_brk[i]) and check_collision(bricks_x[i],bricks_y[i],brick_w,brick_h) then
		 -- check direction
			if collision_direction(x,y,dx,dy,bricks_x[i],bricks_y[i],brick_w,brick_h) then
				dx=-dx
			else
				dy=-dy
			end
			hitbrick(i,true)
			break
		end
	end
	checkexplosions()
	if levelfinished() then
		_draw()
		levelover()
	end
	timer()
end

function draw_game()
	cls(12)
	rectfill(0,0,128,6,8)
	print("lives:"..lives,1,1,7)
	print("score:"..points,40,1,7)
	print("combo:"..combo.."x",85,1,7)
	draw_ball()
	draw_paddle()
	draw_brick()
	drawpickups()
	-- serve preview
	if sticky then
		line(x+dx*4,y+dy*4,x+dx*7,y+dy*7,10)
	end
end

function draw_start()
	cls(3)
	print("breakout",48,50,7)
	print("press ❎ to start",31,70,7)
end

function game_start()
	if btnp(5) then
		gamestate="game"
		pad_x=52
		combo=1
		lives=3
		points=0
		serveball()
		levelnum=1
		buildbricks(levels[levelnum])
	end
end

function nextlevel()
	gamestate="game"
	levelnum+=1
	if levelnum > #levels then
		gamestate="start"
	 return
	end
	pad_x=52
	pad_dx=0
	serveball()
	buildbricks(levels[levelnum])
	combo=1
end

function draw_gameover()
	rectfill(0,47,128,78,0)
	print("game over",46,53,7)
	print("press ❎ to play again",20,68,6)
end

function draw_levelover()
	rectfill(0,47,128,78,0)
	print("level complete!",31,53,7)
	print("press ❎ to continue",20,68,6)
end

function gameover()
	gamestate="gameover"
end

function levelover()
	gamestate="levelover"
end

function update_gameover()
	if btnp(5) then 
		game_start()
	end
end

function update_levelover()
	if btnp(5) then 
		nextlevel()
	end
end

function lose_life()
	lives-=1
	sfx(2)
	if lives<0 then
		gameover()
	else
		serveball()
	end
end
-->8
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
	x=mid(0+rad,x+dx,127-rad)
	y+=dy
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
-->8
--paddle
pad_x=52
pad_y=120
pad_dx=0
pad_w0=24
pad_w=24
pad_h=3
pad_clr=2
last_dir="right"

function draw_paddle()
	rectfill(pad_x,pad_y,pad_x+pad_w,pad_y+pad_h,pad_clr)
	if powerup==2 then
		line(pad_x,pad_y,pad_x+pad_w,pad_y,11)
	end
end

function move_paddle()
 if powerup==3 then
  pad_w=32
 elseif powerup==7 then
  pad_w=16
  mult=2
 else
  pad_w=pad_w0
  mult=1
 end
	if btn(1) then
		pad_dx=3
		last_dir="right"
	elseif btn(0) then
		pad_dx=-3
		last_dir="left"
	end
	pad_x+=pad_dx
	pad_x=mid(0,pad_x,127-pad_w)
	if pad_x==0 or pad_x==(127-pad_w) then
	 -- dont change ball angle if against a wall
		pad_dx=0
	else
		pad_dx=pad_dx/1.3
	end
end
-->8
--bricks

brick_w=9
brick_h=4
brick_clr=6
brick_brk=false

--create the bricks
function buildbricks(lvl)
 local i,j,o,chcr,last
	local brick_y=20
	bricks_x={}
	bricks_y={}
	--is brick broken
	bricks_brk={}
	--brick type
	bricks_type={}
	-- b - normal
	-- x - empty
	-- i - indestructible
	-- h - hard brick
	-- e - exploding
	-- p - powerup brick
	j=0
	for i=1,#lvl do
	 j+=1
	 chcr=sub(lvl,i,i)
	 if chcr=="b"
	 or chcr=="i"
	 or chcr=="h"
	 or chcr=="e"
	 or chcr=="p" then
	 	last=chcr
	 	addbrick(j,last)
	 elseif chcr=="x" then
	 	last="x"
	 elseif chcr=="/" then
	 	j=(flr((j-1)/11)+1)*11
	 elseif chcr>="0" and chcr<="9" then
		 for o=1,chcr+0 do
    if last=="b"
    or last=="i"
			 or last=="h"
			 or last=="e"
			 or last=="p" then
					addbrick(j,last)
			 elseif last=="x" then
     --nothing
    end
    j+=1
   end
 	 j-=1
 	end
	end
end

function addbrick(bi,bt)
	add(bricks_x,4+((bi-1)%11)*(brick_w+2))
	add(bricks_y,20+flr((bi-1)/11)*(brick_h+2))
	add(bricks_brk,false)
	add(bricks_type,bt)
end

function draw_brick()
	for i=1,#bricks_x do
		if bricks_type[i]=="b" then
			brick_clr=6
		elseif bricks_type[i]=="h" then
			brick_clr=13
		elseif bricks_type[i]=="i" then
		 brick_clr=0
		elseif bricks_type[i]=="e" then
			brick_clr=9
		elseif bricks_type[i]=="p" then
			brick_clr=14
		elseif bricks_type[i]=="z" then
			brick_clr=8
		elseif bricks_type[i]=="zz" then
			brick_clr=8
		elseif bricks_type[i]=="zzz" then
			brick_clr=8
		end
		if not(bricks_brk[i]) then
			rectfill(bricks_x[i],bricks_y[i],brick_w+bricks_x[i],brick_h+bricks_y[i],brick_clr)
		end
	end
end

function levelfinished()
	for i=1,#bricks_brk do
		if not(bricks_brk[i]) and
		not(bricks_type[i]=="i") then
			return false
		end
	end
	return true
end

function hitbrick(_i,_combo)
 if bricks_type[_i]=="b" then
		sfx(3+combo)
		if _combo then
			points+=10*combo*mult
			combo=mid(1,combo+1,7)
		end
		bricks_brk[_i]=true
	elseif bricks_type[_i]=="h" then
	 sfx(12)
	 bricks_type[_i]="b"
	elseif bricks_type[_i]=="i" then
		sfx(12)
	elseif bricks_type[_i]=="e" then
		sfx(3+combo)
		if _combo then
			points+=10*combo*mult
			combo=mid(1,combo+1,7)
		end
		bricks_type[_i]="zzz"
		--explode
	elseif bricks_type[_i]=="p" then
		sfx(3+combo)
		if _combo then
			points+=10*combo*mult
			combo=mid(1,combo+1,7)
		end
		bricks_brk[_i]=true
		--spawn powerup
		spawn_pwp(bricks_x[_i],bricks_y[_i])
	end
end

function checkexplosions()
 for i=1,#bricks_x do
	 if bricks_type[i]=="z"
 	and not(bricks_brk[i]) then
 		explodebrick(i)
 	elseif bricks_type[i]=="zzz"
 	and not(bricks_brk[i]) then
 		bricks_type[i]="zz"
	 elseif bricks_type[i]=="zz"
 	and not(bricks_brk[i]) then
 	 bricks_type[i]="z"
 	end
 end
end

function explodebrick(_i)
 bricks_brk[_i]=true
 for j=1,#bricks_x do
 	if j!=_i
 	and not(bricks_brk[j])
 	and abs(bricks_x[j]-bricks_x[_i]) <= brick_w+2
 	and abs(bricks_y[j]-bricks_y[_i]) <= brick_h+2 then
 	 hitbrick(j,false)
 	end
 end
end
-->8
--powerups
-- 1 - mega ball
-- 2 - sticky
-- 3 - extend paddle
-- 4 - speed down
-- 5 - 1up
-- 6 - multiball
-- 7 - small paddle

function resetpickups()
	pwp_x={}
	pwp_y={}
	pwp_v={}
	pwp_t={}
end

function drawpickups()
	for i=1,#pwp_x do
		if pwp_v[i] then
			spr(pwp_t[i],pwp_x[i],pwp_y[i])
		end
	end
end

function spawn_pwp(_x,_y)
	local _t = flr(rnd(7)) + 1
	_t = 7
	pwp_x[#pwp_x+1]=_x+1
	pwp_y[#pwp_x]=_y
	pwp_t[#pwp_x]=_t
	pwp_v[#pwp_x]=true
end

function move_pwp()
 for i=1, #pwp_x do
  if pwp_v[i] then
  	pwp_y[i]+=0.5
  	if pwp_y[i] > 128 then
  		pwp_v[i]=false
  	end
  	if check_collision2(pad_x,pad_y,pad_w,pad_h,pwp_x[i],pwp_y[i]-0.5,8,8) then
				pwp_v[i]=false
				sfx(13)
				pwp_get(pwp_t[i])
			end
  end
 end
end

function pwp_get(_t)
	powerup_t=0
	if _t == 1 then
		-- mega
		powerup=1
	elseif _t == 2 then
		-- sticky
		powerup=2
		powerup_t=600
	elseif _t == 3 then
		-- expand
		powerup=3
		powerup_t=600
	elseif _t == 4 then
		-- speed
		powerup=4
	elseif _t == 5 then
		-- life
	 powerup=0
		lives+=1
	elseif _t == 6 then
		-- multi
		powerup=6
	elseif _t == 7 then
		-- reduce
		powerup=7
		powerup_t=400
	end
end

function timer()
	if powerup!=0 then
		powerup_t-=1
		if powerup_t<=0 then
			powerup=0
		end
	end
end

function check_collision2(obj_x,obj_y,obj_w,obj_h,obj2_x,obj2_y,obj2_w,obj2_h)
	--checks collision for not the ball
	if obj2_y > obj_y+obj_h then
		return false
	end
	if obj2_y+obj2_h < obj_y then
		return false
	end
		if obj2_x > obj_x+obj_w then
		return false
	end
	if obj2_x+obj2_w < obj_x then
		return false
	end
	return true
end
__gfx__
00000000005555000055550000555500005555000055550000555500005555000000000000000000000000000000000000000000000000000000000000000000
00000000051111500511115005111150051111500511115005111150051111500000000000000000000000000000000000000000000000000000000000000000
0070070051188115511bb11551133115511ff115511cc115511aa115511221150000000000000000000000000000000000000000000000000000000000000000
000770005188781551bb7b155133731551ff7f1551cc7c1551aa6a15512272150000000000000000000000000000000000000000000000000000000000000000
000770005188881551bbbb155133331551ffff1551cccc1551aaaa15512222150000000000000000000000000000000000000000000000000000000000000000
0070070051188115511bb11551133115511ff115511cc115511aa115511221150000000000000000000000000000000000000000000000000000000000000000
00000000051111500511115005111150051111500511115005111150051111500000000000000000000000000000000000000000000000000000000000000000
00000000005555000055550000555500005555000055550000555500005555000000000000000000000000000000000000000000000000000000000000000000
__label__
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
87888777878787778877888887778888888888888778877887787778777888887888777888888888888888778877877787778877888887788787888888888888
87888878878787888788887888878888888888887888788878787878788887887888787888888888888887888787877787878787887888788787888888888888
87888878878787788777888888778888888888887778788878787788778888887778787888888888888887888787878787788787888888788878888888888888
87888878877787888887887888878888888888888878788878787878788887887878787888888888888887888787878787878787887888788787888888888888
87778777887887778778888887778888888888887788877877887878777888887778777888888888888888778778878787778778888887778787888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccc6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666cccc
cccc6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666cccc
cccc6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666cccc
cccc6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666cccc
cccc6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666cccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccc6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666cccc
cccc6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666cccc
cccc6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666cccc
cccc6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666cccc
cccc6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666cccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccc6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666cccc
cccc6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666cccc
cccc6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666cccc
cccc6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666cccc
cccc6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666cccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccc6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666cccc
cccc6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666cccc
cccc6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666cccc
cccc6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666cccc
cccc6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666cccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccc6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666ccccccccccccccc
cccc6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666ccccccccccccccc
cccc6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666ccccccccccccccc
cccc6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666ccccccccccccccc
cccc6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666ccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccc6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666cccccccccccccccccccccccccc
cccc6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666cccccccccccccccccccccccccc
cccc6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666cccccccccccccccccccccccccc
cccc6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666cccccccccccccccccccccccccc
cccc6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666c6666666666cccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccaaacccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccaaaaaccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccaaaaaccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccaaaaaccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccaaacccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccc2222222222222222222222222ccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccc2222222222222222222222222ccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccc2222222222222222222222222ccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccc2222222222222222222222222ccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

__sfx__
000100000d3700d3400d3300d3200d3100d3101940019400194000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001937019340193301932019310193100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102000027750257502375022750217501f7501f7501d7401d7401b73019720187201670014700014000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000025550205501d5201c51006530035200352012500105000c0000800006000030000000000000020000c4000c4000c4000c4000c4000b4000b400094000540004400044000440004400044003440034400
000100000d4700d4400d4300d4200d4100d4100d4000f400193000030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100000e4700e4400e4300e4200e4100e4100d4000f400193000030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100001047010440104301042010410104100d4000f400193000030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100001147011440114301142011410114100d4000f400193000030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100001347013440134301342013410134100d4000f400193000030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100001547015440154301542015410154100d4000f400193000030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100001747017440174301742017410174100d4000f400193000030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100001047010440104301042010410104100d4000f400193000030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100003735037330373303732037310003003330033400334003340032400324003240000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00060000250501c0501f050210501d050200502405027050290502600026000260002600026000255000030000300000000000000000000000000000000000000000000000000000000000000000000000000000
