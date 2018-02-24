require "map"

WINDOW_WIDTH = 640
WINDOW_HEIGHT = 480

DARK_GREEN = {0, 64, 0, 255}
LIGHT_GREEN = {0, 128, 0, 255}
BLUE = {0, 0, 64, 255}

function love.load()
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT)
    love.graphics.setBackgroundColor(BLUE)

    posX = 23 
    posY = 23
    dirX = -1
    dirY = 0
    planeX = 0
    planeY = 0.66

    drawScreenLineStart = {}
    drawScreenLineEnd = {}
    drawScreenLineColor = {}
end

function love.update(dt)
    for x = 0, WINDOW_WIDTH, 1 do
        local cameraX = 2 * x / WINDOW_WIDTH - 1
        local rayPosX = posX
        local rayPosY = posY
        local rayDirX = dirX + planeX * cameraX
        local rayDirY = dirY + planeY * cameraX

        local mapX = math.floor(rayPosX) 
        local mapY = math.floor(rayPosY)

        local sideDistX
        local sideDistY

        local deltaDistX = math.sqrt(1 + (rayDirY ^ 2) / (rayDirX ^ 2)) 
        local deltaDistY = math.sqrt(1 + (rayDirX ^ 2) / (rayDirY ^ 2))
        local perWallDist

        local stepX
        local stepY

        local hit = 0
        local side = 0

        if (rayDirX < 0) then
            stepX = -1
            sideDistX = (rayPosX - mapX) * deltaDistX
        else
            stepX = 1
            sideDistX = (mapX + 1.0 - rayPosX) * deltaDistX
        end

        if (rayDirY < 0) then
            stepY = -1
            sideDistY = (rayPosY - mapY) * deltaDistY
        else
            stepY = 1
            sideDistY = (mapY + 1.0 - rayPosY) * deltaDistY
        end

        while (hit == 0) do
            if (sideDistX < sideDistY) then
                sideDistX = sideDistX + deltaDistX
                mapX = mapX + stepX
                side = 0
            else
                sideDistY = sideDistY + deltaDistY
                mapY = mapY + stepY
                side = 1
            end
            if (map[mapX][mapY] > 0) then
                hit = 1
            end
        end

        if (side == 0) then
            perpWallDist = math.abs((mapX - rayPosX + (1 - stepX) / 2) / rayDirX)
        else
            perpWallDist = math.abs((mapY - rayPosY + (1 - stepY) / 2) / rayDirY)
        end

        lineHeight = math.abs(math.floor(WINDOW_HEIGHT / perpWallDist))

        drawStart = -lineHeight / 2 + WINDOW_HEIGHT / 2
        if (drawStart < 0) then drawStart = 0 end
        drawEnd = lineHeight / 2 + WINDOW_HEIGHT / 2
        if (drawEnd >= WINDOW_HEIGHT) then drawEnd = WINDOW_HEIGHT - 1 end

        if (map[mapX][mapY] == 1) then
            if (side == 1) then
                drawScreenLineColor[x] = DARK_GREEN
            else
                drawScreenLineColor[x] = LIGHT_GREEN
            end
        else
            if (side == 1) then
                drawScreenLineColor[x] = {127, 127, 0, 255}
            else
                drawScreenLineColor[x] = {255, 255, 0, 255}
            end
        end

        drawScreenLineStart[x] = drawStart
        drawScreenLineEnd[x] = drawEnd
    end

    moveSpeed = dt * 5.0
    rotSpeed = dt * 3.0

    if love.keyboard.isDown("up") then
        if (map[math.floor(posX + dirX * moveSpeed)][math.floor(posY)] == 0) then
            posX = posX + dirX * moveSpeed
        end

        if (map[math.floor(posX)][math.floor(posY + dirY * moveSpeed)] == 0) then
            posY = posY + dirY * moveSpeed
        end
    end

    if love.keyboard.isDown("down") then
        if (map[math.floor(posX - dirX * moveSpeed)][math.floor(posY)] == 0) then
            posX = posX - dirX * moveSpeed
        end

        if (map[math.floor(posX)][math.floor(posY - dirY * moveSpeed)] == 0) then
            posY = posY - dirY * moveSpeed
        end
    end
    
    if love.keyboard.isDown("left") then
        oldDirX = dirX
        dirX = dirX * math.cos(rotSpeed) - dirY * math.sin(rotSpeed)
        dirY = oldDirX * math.sin(rotSpeed) + dirY * math.cos(rotSpeed)
        oldPlaneX = planeX
        planeX = planeX * math.cos(rotSpeed) - planeY * math.sin(rotSpeed)
        planeY = oldPlaneX * math.sin(rotSpeed) + planeY * math.cos(rotSpeed)
    end

    if love.keyboard.isDown("right") then
        oldDirX = dirX
        dirX = dirX * math.cos(-rotSpeed) - dirY * math.sin(-rotSpeed)
        dirY = oldDirX * math.sin(-rotSpeed) + dirY * math.cos(-rotSpeed)
        oldPlaneX = planeX
        planeX = planeX * math.cos(-rotSpeed) - planeY * math.sin(-rotSpeed)
        planeY = oldPlaneX * math.sin(-rotSpeed) + planeY * math.cos(-rotSpeed)
    end
end

function love.draw()
    for x = 0, WINDOW_WIDTH, 1 do
        love.graphics.setColor(drawScreenLineColor[x])
        love.graphics.line(x, drawScreenLineStart[x], x, drawScreenLineEnd[x])
    end
end
