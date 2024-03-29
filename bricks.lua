--bricks

brick_w=9
brick_h=4
brick_clr=6

--create the bricks
function buildbricks(lvl)
	local i,j,o,chcr,last
	local brick_y=20
	bricks={}
	-- brick types
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
	local _b = {
		x = 4+((bi-1)%11)*(brick_w+2),
		y = 20+flr((bi-1)/11)*(brick_h+2),
		brk = false,
		t = bt,
		flashtime = 0,
		offx = 0,
		offy = -(128 + rnd(128)),
		dx = 0,
		dy = rnd(32)
	}
	add(bricks, _b)
end

function draw_brick()
	for i=1,#bricks do
		if bricks[i].flashtime > 0 then
			brick_clr=7
		elseif bricks[i].t=="b" then
			brick_clr=6
		elseif bricks[i].t=="h" then
			brick_clr=13
		elseif bricks[i].t=="i" then
			brick_clr=0
		elseif bricks[i].t=="e" then
			brick_clr=9
		elseif bricks[i].t=="p" then
			brick_clr=14
		elseif bricks[i].t=="z" then
			brick_clr=8
		elseif bricks[i].t=="zz" then
			brick_clr=8
		elseif bricks[i].t=="zzz" then
			brick_clr=8
		end
		if not(bricks[i].brk) or bricks[i].flashtime > 0 then
			local x = bricks[i].x + bricks[i].offx
			local y = bricks[i].y + bricks[i].offy
			rectfill(x,y,brick_w+x,brick_h+y,brick_clr)
		end
	end
end

function levelfinished()
	for i=1,#bricks do
		if not(bricks[i].brk) and
		not(bricks[i].t=="i") then
			return false
		end
	end
	return true
end

function hitbrick(brick, docombo, balldx, balldy)
	local flashtime = 10
	if brick.t=="b" then
		sfx(3+combo)
		brick.flashtime = flashtime
		-- spawn particles
		brickshatter(brick, balldx, balldy)
		if docombo then
			points+=10*combo*mult
			combo=mid(1,combo+1,7)
		end
		brick.brk=true
	elseif brick.t=="h" then
		if t_mega > 0 then
			sfx(3+combo)
			brick.flashtime = flashtime
			if docombo then
				points+=10*combo*mult
				combo=mid(1,combo+1,7)
			end
			brick.brk=true
		else
			sfx(12)
			brick.t="b"
		end
	elseif brick.t=="i" then
		sfx(12)
	elseif brick.t=="e" then
		sfx(3+combo)
		if docombo then
			points+=10*combo*mult
			combo=mid(1,combo+1,7)
		end
		brick.t="zzz"
		--explode
	elseif brick.t=="p" then
		sfx(3+combo)
		brick.flashtime = flashtime
		-- spawn particles
		brickshatter(brick, balldx, balldy)
		if docombo then
			points+=10*combo*mult
			combo=mid(1,combo+1,7)
		end
		brick.brk=true
		--spawn powerup
		spawn_pwp(brick.x,brick.y)
	end
end

function checkexplosions()
	for i=1,#bricks do
		if bricks[i].t=="z"
 		and not(bricks[i].brk) then
 			explodebrick(i)
 		elseif bricks[i].t=="zzz"
 		and not(bricks[i].brk) then
 			bricks[i].t="zz"
	 	elseif bricks[i].t=="zz"
 		and not(bricks[i].brk) then
 	 	bricks[i].t="z"
 		end
 	end
end

function explodebrick(_i)
	bricks[_i].brk=true
	for j=1,#bricks do
 		if j!=_i
 		and not(bricks[j].brk)
 		and abs(bricks[j].x-bricks[_i].x) <= brick_w+2
 		and abs(bricks[j].y-bricks[_i].y) <= brick_h+2 then
 	 	hitbrick(bricks[j],false,0,0)
 		end
 	end
	shkamnt = min(0.8, shkamnt + 0.4)
end

function update_bricks()
	for brick in all(bricks) do
		-- check if offset or moving
		if brick.dx != 0 or brick.dy != 0 or brick.offx != 0 or brick.offy != 0 then
			-- update offset
			brick.offx += brick.dx
			brick.offy += brick.dy
			-- slow speed
			brick.dx -= brick.offx/10
			brick.dy -= brick.offy/10
			-- help prevent overshooting
			if abs(brick.dx) > brick.offx then
				brick.dx /= 1.4
			end
			if abs(brick.dy) > brick.offy then
				brick.dy /= 1.4
			end
			-- snap to correct position
			if abs(brick.offy) < 0.2 and abs(brick.dy) < 0.25 then
				brick.dy = 0
				brick.offy = 0
			end
			if abs(brick.offx) < 0.2 and abs(brick.dx) < 0.25 then
				brick.dx = 0
				brick.offx = 0
			end
		end
		if brick.flashtime > 0 then
			brick.flashtime = max(brick.flashtime - 1, 0)
		end
	end
end