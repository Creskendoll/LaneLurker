require("keyController")
require("gameSettings")
require("gameControl")
math.randomseed(os.time())

--player is global so that it can be reached from every file
player = { 
    position = {x = 0, y = playerPostionY, size = 50},
    image = love.graphics.newImage("assets/player.png"),
    distanceToGround = 1;
    isGoingUp = false,
    isAirBorne = false,
    moving = "forward",
    state = "immune",
    isVisible = true,
    immunityTime = 2,
    health = 100,
    speed = 5,
    jumpSpeed = 0.1,
    lane = 2,
    level = 1,
    gold = 0,
    exp = 0
}

function love.load()

    for i=0, gameSize
    do
        obstacleLaneCount[i] = 0
    end

    --initiate lane positions and player positions
    for i=0, gameSize
    do
        local lane = {
            laneLineColor = { 0,0,0 },
            xPos = i*laneWidth,
            innerColor = { 0,0,0 },
            buff = "none",
            buffTimeCounter = 0
        }
        --lane
        table.insert( lanes, lane )
        --player
        playerPositions[i] = playerPositionWidth + i*laneWidth

    end
    
    player.position.x = playerPositions[player.lane]

    obstacleImages[0] = love.graphics.newImage("assets/Blocks/brickBlock.png")
    obstacleImages[1] = love.graphics.newImage("assets/Blocks/metalBlock.png")
    obstacleImages[2] = love.graphics.newImage("assets/Blocks/woodenBlock.png")

    updateObstacles(0)

    for i=0, gameSize
    do 
        laneColorToReach[i] = { math.random(0,255), math.random(0,255), math.random(0,255) }
    end
end

function love.update(dt)
    if not checkCollision(dt) then
        updatePlayer()
        updateObstacles(dt)
        updateLanes(dt)
    end
end

function updateLanes(dt)
    --update lane spawn timer
    laneBuffActiveCounter = laneBuffActiveCounter + dt 

    --to track time
    colorChangeIntervalCounter = colorChangeIntervalCounter + dt
    if colorChangeIntervalCounter >= colorChangeInterval then
        for i=0, gameSize
        do 
            laneColorToReach[i] = { math.random(0,255), math.random(0,255), math.random(0,255) }
        end
        colorChangeIntervalCounter = 0

    else 

        --select lane to buff, reset timer
        if laneBuffActiveCounter > getLaneBuffSpawnRate(math.random( 0, 1 )) then
            laneToBuff = math.random( 1, gameSize + 1 )

            local flag = true

            while flag
            do
                for i, lane in pairs(lanes)
                do
                    if laneToBuff == i and not lane.buff == "none" then
                        laneToBuff = math.random( 1, gameSize + 1 )
                        break
                    end
                    flag = false
                end
            end

            laneBuffActiveCounter = 0
        end

        --check lanes individual buff time
        for i, lane in pairs(buffedLanes)
        do
            if lane.buffTimeCounter > getLaneBuffSpawnRate(math.random( 1, 2 )) then
                lane.buff = "none"
                lane.buffTimeCounter = 0
                table.remove( buffedLanes, i )
            end
        end

        --iterate through lanes
        for i, lane in pairs(lanes)
        do

            --spawn buffed lane
            if i == laneToBuff and lane.buff == "none" then                
                local buffType = -1

                buffType = math.random( 0,1 )

                if buffType == 0 then
                    lane.buff = "heal"
                    lane.buffTimeCounter = lane.buffTimeCounter + dt
                elseif buffType == 1 then
                    lane.buff = "damage"
                    lane.buffTimeCounter = lane.buffTimeCounter + dt
                end

                table.insert( buffedLanes, lane )

            elseif lane.buff == "none" then 
                --receive a lane color tuple 
                local newColor = compareAndAlterColors(lane.innerColor, laneColorToReach[i-1])

                lane.innerColor = newColor

            else
                if lane.buff == "damage" then
                    lane.innerColor = { 255,0,0 }
                    lane.buffTimeCounter = lane.buffTimeCounter + dt
                elseif lane.buff == "heal" then
                    lane.innerColor = { 0,255,0 }
                    lane.buffTimeCounter = lane.buffTimeCounter + dt
                end
            end

                --print("Lane", i, "BuffTimeCounter", lane.buffTimeCounter)

            lane.laneLineColor = lane.innerColor
        end

    end
end

--this can be private in updateLanes(), old = { 0, 255, 0 }, new = { 0, 255, 0 }
function compareAndAlterColors(old, new)
    local result ={}

    for i, oldVal in pairs(old)
    do
        if oldVal < new[i] and oldVal < 255 - colorChangeSpeed then
            result[i] = oldVal + colorChangeSpeed
        elseif oldVal > new[i] and oldVal > colorChangeSpeed then
            result[i] = oldVal - colorChangeSpeed
        else
            result[i] = oldVal
        end
    end
    return result
end

function updatePlayer()
    if player.isAirBorne then
        if player.isGoingUp then
            player.distanceToGround = player.distanceToGround + player.jumpSpeed

            if player.distanceToGround >= 2 then
                player.isGoingUp = false
            end
        end

        if not player.isGoingUp and player.distanceToGround >= 1 then
            player.distanceToGround = player.distanceToGround - player.jumpSpeed
            if player.distanceToGround <= 1 then
                player.isAirBorne = false
            end
        end
    end

    --move player
    if player.moving == "right" then
        if player.position.x <= playerPositions[playerLaneToGo] then
            player.position.x = player.position.x + getPlayerSpeed(gameDifficulty)
        else
            player.lane = playerLaneToGo
            player.position.x = playerPositions[player.lane]
            player.moving = "forward"
        end
    elseif player.moving == "left" then
        if player.position.x >= playerPositions[playerLaneToGo] then
            player.position.x = player.position.x - getPlayerSpeed(gameDifficulty)
        else
            player.lane = playerLaneToGo
            player.position.x = playerPositions[player.lane]
            player.moving = "forward"
        end
    end
end

function updateObstacles(dt)
    obstacleSpawnIntervalCounter = obstacleSpawnIntervalCounter + dt 
    local numberOfObstaclesInFrame = #obstacles

    if numberOfObstaclesInFrame <= getMaxObstacleOnScreen(gameDifficulty) and obstacleSpawnIntervalCounter >= getObstacleSpawnInterval(gameDifficulty) then

        local randNum = math.random(0, #obstacleImages)
        local obstacleLane = math.random(0, gameSize)

        while true
        do
            if obstacleLaneCount[obstacleLane] > 1 then
                obstacleLane = math.random(0, gameSize)
            else
                break
            end
        end

        local types = {}
        types[0] = "brick"
        types[1] = "metal"
        types[2] = "wooden" 

        --create and add obstacle
        local obstacle = {
            --start form above the frame
            yPos = -laneWidth,
            lane = obstacleLane,
            image = obstacleImages[randNum],
            type = types[randNum],
            speed = math.random( 0, 3 )
        }

        --to keep track of how many obstacles are in one line
        obstacleLaneCount[obstacle.lane] = obstacleLaneCount[obstacle.lane] + 1

        table.insert(obstacles, obstacle)

        --update game settings
        gameDifficulty = gameDifficulty + deltaTimeOffSet*dt
        --reset the time span
        obstacleSpawnIntervalCounter = 0

    end

    --move and remove obstacles
    for i, obs in pairs(obstacles)
    do
        obs.yPos = obs.yPos + getGameSpeed(gameDifficulty) + obs.speed
        if obs.yPos > windowHeight + 50 then
            table.remove(obstacles, i)
            obstacleLaneCount[obs.lane] = obstacleLaneCount[obs.lane] - 1
        end
    end
end

function love.draw()
    --draw lines and lanes
    for i, lane in pairs(lanes)
    do
        --lane
        love.graphics.setColor(lane.innerColor, 255)
        love.graphics.rectangle("fill", lane.xPos, 0, laneWidth, windowWidth )
        --line
        love.graphics.setColor(lane.laneLineColor, 255)
        love.graphics.setLineStyle("smooth")
        love.graphics.line(lane.xPos, 0, lane.xPos, windowWidth)
    end

    --setColor for drawables, white, opac
    love.graphics.setColor(255, 255, 255, 255)
    --draw obstacles
    for i, obstacle in pairs(obstacles)
    do
        love.graphics.draw(obstacle.image, playerPositions[obstacle.lane], obstacle.yPos, math.rad(0),
                    1, 1, 25, 25)
    end

    --draw player
    if player.isVisible or player.state == "dead" then
        love.graphics.draw(player.image, player.position.x, player.position.y, math.rad(0),
                        player.distanceToGround, 1, 25, 25)
    end

    love.graphics.print(player.health)
end