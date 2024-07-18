function love.load()
    Lume = require("lume") --Lume is an external library used to serialise tables for debugging
    --love.math.setRandomSeed(love.timer.getTime())
    love.graphics.setBackgroundColor(20/255, 141/255, 222/255)
    
    Snake = {
        target = {x = 401, y = 201},
        reachedTarget = false,
        speed = 150,
        speedMod = 1,
        frontVert = {x=0,y=0},
        backVert = {x=0,y=0},
        points = {
            {x=400, y=200, size=28, angle=0},
            {x=430, y=200, size=29, angle=0},
            {x=460, y=200, size=30, angle=0},
            {x=490, y=200, size=30, angle=0},
            {x=520, y=200, size=30, angle=0},
            {x=550, y=200, size=30, angle=0},
            {x=580, y=200, size=30, angle=0},
            {x=610, y=200, size=30, angle=0},
            {x=640, y=200, size=30, angle=0},
            {x=670, y=200, size=30, angle=0},
            {x=700, y=200, size=30, angle=0},
            {x=730, y=200, size=30, angle=0},
            {x=760, y=200, size=30, angle=0},
            {x=790, y=200, size=30, angle=0},
            {x=820, y=200, size=30, angle=0},
            {x=850, y=200, size=30, angle=0},
            {x=880, y=200, size=30, angle=0},
            {x=910, y=200, size=28, angle=0},
            {x=1040, y=200, size=26, angle=0},
            {x=1070, y=200, size=24, angle=0},
            {x=1100, y=200, size=22, angle=0},
            {x=1130, y=200, size=20, angle=0},
            {x=1160, y=200, size=18, angle=0},
            {x=1190, y=200, size=16, angle=0},
            {x=1220, y=200, size=14, angle=0},
            {x=1250, y=200, size=12, angle=0},
            {x=1280, y=200, size=10, angle=0}
        },
        verts = {}
    }

    --print(Lume.serialize(Snake))
end

function love.update(dt)
    if love.mouse.isDown(1) then
        Snake.target.x, Snake.target.y = love.mouse.getPosition()
    end

    moveToTarget(dt)
    trailing()
    updatePointDir()
    createVerts()
    print(love.math.isConvex(Snake.verts))
end

function updatePointDir()
    --Updates the angles for each of the points
    for i,p in ipairs(Snake.points) do
        if i > 1 then
            p.angle = math.atan2(Snake.points[i-1].y - p.y, Snake.points[i-1].x - p.x)
        end
    end
end

function moveToTarget(dt)
    --Calculates the direction to the target
    local dist = getDistance(Snake.target.x, Snake.target.y, Snake.points[1].x, Snake.points[1].y)
    local angle = math.atan2(Snake.target.y - Snake.points[1].y, Snake.target.x - Snake.points[1].x)
    local cos = math.cos(angle)
    local sin = math.sin(angle)
    Snake.points[1].angle = angle
    --Increases speed with distance
    if dist > 1 then -- Allowance of 1 pixel to avoid shaking at target
        if dist > 100 then
            Snake.speedMod = math.sqrt(dist)/10
        end
        Snake.points[1].x = Snake.points[1].x + Snake.speed * Snake.speedMod * cos * dt
        Snake.points[1].y = Snake.points[1].y + Snake.speed * Snake.speedMod * sin * dt
        Snake.reachedTarget = false
    else
        Snake.reachedTarget = true
    end
end

function trailing()
    --Makes the points follow each other
    for i,p in ipairs(Snake.points) do
        if i < table.getn(Snake.points) then
            vec = {Snake.points[i+1].x - p.x, Snake.points[i+1].y - p.y}
            local dist = getDistance(p.x, p.y, Snake.points[i+1].x, Snake.points[i+1].y)
            if not (p.size == dist) then
                local scale = p.size/dist
                Snake.points[i + 1].x = p.x + vec[1] * scale
                Snake.points[i + 1].y = p.y + vec[2] * scale
            end
        end
    end
end

function createVerts()
    --Calculate the locations of the front and back vertices
    local fp = Snake.points[1]
    Snake.frontVert.x, Snake.frontVert.y = parametricEquation(fp.size, fp.angle)
    Snake.frontVert.x = Snake.frontVert.x + fp.x
    Snake.frontVert.y = Snake.frontVert.y + fp.y
    love.graphics.setColor(1,1,0,0.8)
    love.graphics.circle("fill", Snake.frontVert.x, Snake.frontVert.y, 2.5)

    local bp = Snake.points[table.getn(Snake.points)]
    Snake.backVert.x, Snake.backVert.y = parametricEquation(bp.size, bp.angle + math.pi)
    Snake.backVert.x = Snake.backVert.x + bp.x
    Snake.backVert.y = Snake.backVert.y + bp.y
    love.graphics.setColor(0,0,1,0.8)
    love.graphics.circle("fill", Snake.backVert.x, Snake.backVert.y, 2.5)

    --Add all vertices to the verts table, this is messy and may require optimisation
    --North
    table.insert(Snake.verts, Snake.frontVert.x)
    table.insert(Snake.verts, Snake.frontVert.y)
    --North-east
    table.insert(Snake.verts, fp.x + fp.size * math.cos(fp.angle + degToRad(40)))
    table.insert(Snake.verts, fp.y + fp.size * math.sin(fp.angle + degToRad(40)))
    --East
    for i,p in ipairs(Snake.points) do
        local sideR = {x=0,y=0}
        sideR.x, sideR.y = parametricEquation(p.size, p.angle + math.pi/2)
        table.insert(Snake.verts, sideR.x + p.x)
        table.insert(Snake.verts, sideR.y + p.y)
    end
    --South-east
    table.insert(Snake.verts, bp.x + bp.size * math.cos(bp.angle + degToRad(130)))
    table.insert(Snake.verts, bp.y + bp.size * math.sin(bp.angle + degToRad(130)))
    --South
    table.insert(Snake.verts, Snake.backVert.x)
    table.insert(Snake.verts, Snake.backVert.y)
    --South-west
    table.insert(Snake.verts, bp.x + bp.size * math.cos(bp.angle - degToRad(130)))
    table.insert(Snake.verts, bp.y + bp.size * math.sin(bp.angle - degToRad(130)))
    --West
    for i = table.getn(Snake.points), 1, -1 do
        p = Snake.points[i]
        local sideL = {x=0,y=0}
        sideL.x, sideL.y = parametricEquation(p.size, p.angle - math.pi/2)
        table.insert(Snake.verts, sideL.x + p.x)
        table.insert(Snake.verts, sideL.y + p.y)
    end
    --North-west
    table.insert(Snake.verts, Snake.points[1].x + Snake.points[1].size * math.cos(Snake.points[1].angle - degToRad(40)))
    table.insert(Snake.verts, Snake.points[1].y + Snake.points[1].size * math.sin(Snake.points[1].angle - degToRad(40)))
    --North
    table.insert(Snake.verts, Snake.frontVert.x)
    table.insert(Snake.verts, Snake.frontVert.y)
end

function love.draw()
    love.graphics.setColor(1,0,0,1)
    love.graphics.print(love.timer:getFPS(), 0, 0, 0, 2, 2)

    --Places circle at target
    if not Snake.reachedTarget then
        love.graphics.setColor(176/255, 203/255, 247/255)
        love.graphics.circle("line", Snake.target.x, Snake.target.y, 15)
    end

    
    drawSkeleton()
    drawBody()

    --Clear verts after use
    Snake.verts = {}
end

function drawSkeleton()
    --Draws points and circles at each point
    for i,p in ipairs(Snake.points) do
        love.graphics.setColor(1,1,1)
        love.graphics.circle("fill", p.x, p.y, 2.5)
        love.graphics.setColor(1,0,0,0.8)
        love.graphics.circle("line", p.x, p.y, p.size)
    end

    --Draw vertices
    local vr = 0 --Red value used to show vertex order 
    for i=1, table.getn(Snake.verts), 2 do
        --print(i)
        v = Snake.verts[i]
        love.graphics.setColor(vr,0,1,0.8)
        vr = vr + 1/table.getn(Snake.verts)
        love.graphics.circle("fill", v, Snake.verts[i+1], 5)
    end

    --Draws lines to show angles of each point
    for i,p in ipairs(Snake.points) do
        love.graphics.setColor(0,1,0,1)
        love.graphics.line(p.x, p.y, p.x+math.cos(p.angle)*p.size, p.y+math.sin(p.angle)*p.size)
    end
end

function drawBody()
    --Used to draw the body, line mode works as expected but fill mode acts strangely
    love.graphics.setColor(87/255, 230/255, 111/255, 0.5)
    love.graphics.polygon("fill", Snake.verts)
    love.graphics.setColor(0,0,0,1)
    love.graphics.polygon("line", Snake.verts)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end

function getDistance(x1, y1, x2, y2)
    --Pythagorean theorum
    local horizontal_distance = x1 - x2
    local vertical_distance = y1 - y2

    local a = horizontal_distance^2
    local b = vertical_distance^2

    local c = a + b
    local distance = math.sqrt(c)
    return distance
end

function parametricEquation(radius, rotation)
    --Used for side vertex position calculations
    local x = radius * math.cos(rotation)
    local y = radius * math.sin(rotation)
    return x, y
end

function degToRad(degrees)
    --Degrees to radians conversion
    radians = degrees * math.pi/180
    return radians
end