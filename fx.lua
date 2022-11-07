-- screenshake

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

-- blinking effects

function doblink()
    local blinkgray = {5, 13, 6, 7, 6, 13}
    blinkframe += 1
    if blinkframe > blinkspeed then
        -- animation of text
        blinkframe = 0
        blinkindex += 1
        if blinkindex > #blinkgray then
            blinkindex = 1
        end
        blink_g = blinkgray[blinkindex]
        blinkindex2 += 1
        if blinkindex2 > 4 then
            blinkindex2 = 1
        end
    end
end

function getblinkcols()
    local blinkwarm = {10, 9, 14, 9}
    -- animation of arrow
    local blink_2 = blinkwarm[blinkindex2 % #blinkwarm + 1]
    local blink_3 = blinkwarm[(blinkindex2 + 1) % #blinkwarm + 1]
    local blink_4 = blinkwarm[(blinkindex2 + 2) % #blinkwarm + 1]
    local blink_5 = blinkwarm[(blinkindex2 + 3) % #blinkwarm + 1]
    return blink_5, blink_4, blink_3, blink_2
end

-- screenfades

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

-- particles

function addparticle(x, y, type, maxage, colors)
    local p = {}
    p.x = x
    p.y = y
    p.type = type
    p.maxage = maxage
    p.age = 0
    p.color = colors[1]
    p.colors = colors
    add(particles, p)
end

function spawntrail(x, y)
    if rnd() < 0.8 then
        addparticle(x + sin(rnd()) * rad * 0.5, y + cos(rnd()) * rad * 0.5, 0, 10 + rnd(15), {10, 9})
    end
end

function updateparticles()
    for particle in all(particles) do
        particle.age += 1
        if particle.age > particle.maxage then
            del(particles, particle)
        elseif #particle.colors > 1 then
            local colorindex = flr((particle.age / particle.maxage) * #particle.colors) + 1
            particle.color = particle.colors[colorindex]
        end
    end
end

function drawparticles()
    for particle in all(particles) do
        if particle.type == 0 then
            pset(particle.x, particle.y, particle.color)
        end
    end
end