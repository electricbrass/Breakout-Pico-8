-- effects including screen shake and particles

function shakescr()
    local shx = 16 - rnd(32)
    local shy = 16 - rnd(32)
    shx *= shkamnt
    shy *= shkamnt
    camera(shx, shy)
    shkamnt *= 0.95
    if shkamnt < 0.05 then
        shkamnt = 0
    end
end

function doblink()
    local blinkgray = {5, 13, 6, 7, 6, 13}
    local blinkwarm = {10, 9, 14, 9}
    blinkframe += 1
    if blinkframe > blinkspeed then
        -- animation of text
        blinkframe = 0
        blinkindex += 1
        if blinkindex > #blinkgray then
            blinkindex = 1
        end
        blink_g = blinkgray[blinkindex]
        -- animation of arrow
        blinkindex2 += 1
        if blinkindex2 > #blinkwarm then
            blinkindex2 = 1
        end
        blink_2 = blinkwarm[blinkindex2 % #blinkwarm + 1]
        blink_3 = blinkwarm[(blinkindex2 + 1) % #blinkwarm + 1]
        blink_4 = blinkwarm[(blinkindex2 + 2) % #blinkwarm + 1]
        blink_5 = blinkwarm[(blinkindex2 + 3) % #blinkwarm + 1]
    end
end

function fadepalette(amnt)
    -- 1 is black
    -- 0 is normal
    local pcnt = flr(mid(0, amnt, 1) * 100)
    local kmax, col, dpal, j, k
    dpal ={ 0, 1, 1, 2, 1, 13, 6, 4, 4, 9, 3, 13, 1, 13, 14 }

    for j = 1, 15 do
        -- get current color
        col = j
        -- calculate fade
        kmax = (pcnt + (j * 1.46)) / 22
        for k = 1, kmax do
            col = dpal[col]
        end
        -- change palette
        pal(j, col, 1)
    end
end