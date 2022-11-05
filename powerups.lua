--powerups
-- 1 - mega ball
-- 2 - sticky
-- 3 - extend paddle
-- 4 - speed down
-- 5 - 1up
-- 6 - multiball
-- 7 - small paddle

function drawpickups()
	for i=1,#powerups do
		spr(powerups[i].t,powerups[i].x,powerups[i].y)
	end
end

function spawn_pwp(_x,_y)
	local _t = flr(rnd(7)) + 1
	-- uncomment to set specific powerup instead of random
	--nums = {2, 6}
	--_t = rnd(nums)
	local _powerup = {
		x = _x,
		y = _y,
		t = _t,
	}
	add(powerups, _powerup)
end

function move_pwp()
	for i=#powerups, 1, -1 do
  		powerups[i].y+=0.5
  		if powerups[i].y > 128 then
			del(powerups, powerups[i])
  		elseif check_collision2(pad_x,pad_y,pad_w,pad_h,powerups[i].x,powerups[i].y-0.5,8,8) then
			sfx(13)
			pwp_get(powerups[i].t)
			del(powerups, powerups[i])
		end
	end
end

function pwp_get(_t)
	powerup_t=0
	if _t == 1 then
		-- mega
		powerup=1
		powerup_t=900
	elseif _t == 2 then
		-- sticky
		if not hasstuck then
			sticky=true
		end
	elseif _t == 3 then
		-- expand
		powerup=3
		powerup_t=600
	elseif _t == 4 then
		-- speed
		powerup=4
		powerup_t=900
	elseif _t == 5 then
		-- life
		powerup=0
		lives+=1
	elseif _t == 6 then
		-- multi
		-- not sure why releasing
		-- releasestuck()
		multiball()
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