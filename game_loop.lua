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
--	levels[1]="b9bi9ii9ii9ibxxxxxb"
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
		-- no collision if megaball
			if powerup!=1 or bricks_type[i]=="i" then
			-- check direction
				if collision_direction(x,y,dx,dy,bricks_x[i],bricks_y[i],brick_w,brick_h) then
					dx=-dx
				else
					dy=-dy
				end
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