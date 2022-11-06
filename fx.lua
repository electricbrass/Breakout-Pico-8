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