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

function addparticle(x, y, dx, dy, type, maxage, colors)
    local p = {}
    p.x = x
    p.y = y
    p.dx = dx
    p.dy = dy
    p.type = type
    p.maxage = maxage
    p.age = 0
    p.color = colors[1]
    p.colors = colors
    add(particles, p)
end

function spawntrail(x, y)
    if rnd() < 0.8 then
        local colors
        if t_mega > 0 then
            colors = {8, 9, 10, 11}
        else
            colors = {10, 9}
        end
        addparticle(x + sin(rnd()) * rad * 0.5, y + cos(rnd()) * rad * 0.5, 0, 0, 0, 10 + rnd(15), colors)
    end
end

function brickshatter(brick, balldx, balldy)
    for i = 0, brick_w do
        for j = 0, brick_h do
            local angle = rnd()
            local dx = sin(angle) * rnd(2) + balldx
            local dy = cos(angle) * rnd(2) + balldy
            addparticle(brick.x + i, brick.y + j, dx, dy, 1, 80, {7})
        end
    end
end

function updateparticles()
    for particle in all(particles) do
        particle.age += 1
        if particle.age > particle.maxage then
            -- delete if reached end of lifespan
            del(particles, particle)
        elseif particle.x < -20 or particle.x > 148 then
            -- delete if offscreen
            del(particles, particle)
        elseif particle.y < -20 or particle.y > 148 then
            -- delete if offscreen
            del(particles, particle)
        else
            if #particle.colors > 1 then
                local colorindex = flr((particle.age / particle.maxage) * #particle.colors) + 1
                particle.color = particle.colors[colorindex]
            end
            if particle.type == 1 then
                -- gravity
                particle.dy += 0.05
                -- move particle
                particle.y += particle.dy
                particle.x += particle.dx
            end
        end
    end
end

function drawparticles()
    for particle in all(particles) do
        if particle.type == 0 or particle.type == 1 then
            pset(particle.x, particle.y, particle.color)
        end
    end
end