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
	if sticky then
		line(pad_x,pad_y,pad_x+pad_w,pad_y,11)
	end
end

function move_paddle()
	if t_expand > 0 then
		pad_w=32
	elseif t_reduce > 0 then
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