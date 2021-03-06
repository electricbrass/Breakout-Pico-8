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
	_t = 1
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
		powerup_t=900
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
		powerup_t=900
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