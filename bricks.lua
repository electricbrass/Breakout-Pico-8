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
		t = bt
	}
	add(bricks, _b)
end

function draw_brick()
	for i=1,#bricks do
		if bricks[i].t=="b" then
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
		if not(bricks[i].brk) then
			rectfill(bricks[i].x,bricks[i].y,brick_w+bricks[i].x,brick_h+bricks[i].y,brick_clr)
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

function hitbrick(_i,_combo)
	if bricks[_i].t=="b" then
		sfx(3+combo)
		-- spawn particles
		brickshatter(bricks[_i])
		if _combo then
			points+=10*combo*mult
			combo=mid(1,combo+1,7)
		end
		bricks[_i].brk=true
	elseif bricks[_i].t=="h" then
		if t_mega > 0 then
			sfx(3+combo)
			if _combo then
				points+=10*combo*mult
				combo=mid(1,combo+1,7)
			end
			bricks[_i].brk=true
		else
			sfx(12)
			bricks[_i].t="b"
		end
	elseif bricks[_i].t=="i" then
		sfx(12)
	elseif bricks[_i].t=="e" then
		sfx(3+combo)
		if _combo then
			points+=10*combo*mult
			combo=mid(1,combo+1,7)
		end
		bricks[_i].t="zzz"
		--explode
	elseif bricks[_i].t=="p" then
		sfx(3+combo)
		-- spawn particles
		brickshatter(bricks[_i])
		if _combo then
			points+=10*combo*mult
			combo=mid(1,combo+1,7)
		end
		bricks[_i].brk=true
		--spawn powerup
		spawn_pwp(bricks[_i].x,bricks[_i].y)
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
 	 	hitbrick(j,false)
 		end
 	end
	shkamnt = min(0.8, shkamnt + 0.4)
end