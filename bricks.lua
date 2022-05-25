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