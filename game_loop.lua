--game loop
function _update60()
	updateparticles()
	doblink()
	shakescr()
	if gamestate=="start" then
		update_start()
	elseif gamestate=="game" then
		update_game()
	elseif gamestate=="gameoverwait" then
		update_gameoverwait()
	elseif gamestate=="gameover" then
		update_gameover()
	elseif gamestate=="levelover" then
		update_levelover()
	end
end

function _draw()
	pal()
	if fadeamnt > 0 then
		fadepalette(fadeamnt)
	end
	if gamestate=="start" then
		draw_start()
	elseif gamestate=="game" or gamestate=="gameoverwait" then
		draw_game()
	elseif gamestate=="gameover" then
		draw_gameover()
	elseif gamestate=="levelover" then
		draw_levelover()
	end
end

function _init()
	cls(0)
	shkamnt = 0
	blink_g = 5
	blinkframe = 0
	blinkspeed = 6
	blinkindex = 1
	blinkindex2 = 1
	fadeamnt = 0
	particles = {}
	gamestate="start"
	combo=1
	levelnum=1
	levels={}
	levels[1]="x6b"
	levels[2]="b9bb9bb9bb9bb9bb9b"
	levels[3]="bxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbx"
	levels[1]="bxhxixexp"
	levels[1]="i999999bbbhhhppee"
	-- levels[1]="e9999999"
	levels[1]="p999"
--	levels[1]="b9bi9ii9ii9ibxxxxxb"
--	levels[1]="i99bi9999"
--	levels[1]="b9bb9bb9bxxxpxxx"
end

function serveball()
	balls={ newball() }
	sticky=false
	balls[1].x=pad_x+flr(pad_w0/2)
	balls[1].y=117
	balls[1].dx=1
	balls[1].dy=-1
	balls[1].ang=1
	balls[1].stuck=true
	hasstuck=true
	last_dir="right"
	powerups={}
	t_reduce = 0
	t_expand = 0
	t_speed = 0
	t_mega = 0
	offset=flr(pad_w0/2)
end

function update_game()
	move_paddle()
	move_pwp()
	if btnp(5) then
		releasestuck()
		hasstuck=false
	end
	for ball in all(balls) do
		update_ball(ball)
	-- for i=#balls, 1, -1 do
	-- 	update_ball(balls[i])
	end
	checkexplosions()
	if levelfinished() then
		_draw()
		levelover()
	end
	timer()
	update_bricks()
end

function draw_game()
	if fadeamnt > 0 then
		fadeamnt = max(fadeamnt - 0.05, 0)
	end
	cls()
	rectfill(0,0,127,127,12)
	rectfill(0,0,128,6,8)
	if debug then
		print("debug:"..debug, 1, 1, 7)
	else
		print("lives:"..lives,1,1,7)
		print("score:"..points,40,1,7)
		print("combo:"..combo.."x",85,1,7)
	end
	drawparticles()
	draw_ball()
	draw_paddle()
	draw_brick()
	drawpickups()
end

function draw_start()
	cls()
	print("breakout",48,50,7)
	print("press ❎ to start",31,70,blink_g)
end

function update_start()
	if not titletimer or titletimer < 0 then
		if btnp(5) then
			sfx(14)
			blinkspeed = 1.5
			titletimer = 40
		end
	else
		titletimer -= 1
		fadeamnt = (40 - titletimer) / 40
		if titletimer <= 0 then
			blinkspeed = 8
			titletimer = -1
			game_start()
		end
	end
end

function game_start()
	gamestate="game"
	pad_x=52
	combo=1
	lives=3
	points=0
	serveball()
	levelnum=1
	buildbricks(levels[levelnum])
end

function nextlevel()
	particles = {}
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
	print("press ❎ to play again",20,68,blink_g)
end

function draw_levelover()
	rectfill(0,47,128,78,0)
	print("level complete!",31,53,7)
	print("press ❎ to continue",20,68,6)
end

function gameover()
	gamestate="gameoverwait"
	govertimer = 60
end

function levelover()
	gamestate="levelover"
end

function update_gameover()
	if not titletimer or titletimer < 0 then
		if btnp(5) then
			sfx(14)
			blinkspeed = 1.5
			titletimer = 40
		end
	else
		titletimer -= 1
		fadeamnt = (40 - titletimer) / 40
		if titletimer <= 0 then
			blinkspeed = 8
			titletimer = -1
			game_start()
		end
	end
end

function update_gameoverwait()
	if shkamnt <= 0 then
		blink_g = 5
		blinkframe = 0
		gamestate = "gameover"
	end
	-- govertimer -= 1
	-- if govertimer <= 0 then
	-- 	govertimer = -1
	-- 	gamestate = "gameover"
	-- end
end

function update_levelover()
	if btnp(5) then 
		nextlevel()
	end
end

function lose_life()
	lives-=1
	if lives<0 then
		gameover()
	else
		serveball()
	end
end