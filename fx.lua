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
    local blinkcolors = {5, 13, 6, 7, 6, 13}
    blinkframe += 1
    if blinkframe > blinkspeed then
        blinkframe = 0
        blinkindex += 1
        if blinkindex > #blinkcolors then
            blinkindex = 1
        end
        blink_g = blinkcolors[blinkindex]
    end
end