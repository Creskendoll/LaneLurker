require("keyController")
math.randomseed(os.time())

--white background
love.graphics.setBackgroundColor( 255, 255, 255 )

--lane count - 1 beacuse the arrays
local gameSize = 4
local windowWidth = love.graphics.getWidth()
local windowHeight = love.graphics.getHeight()
--because there is gameSize+1 many lanes
local laneWidth = windowWidth/(gameSize+1)
local playerPositionWidth = laneWidth/2
local playerPostionY = love.graphics.getHeight() - playerPositionWidth

local gameSpeed = 5
local gameStartDifficulty = 5 

--lane variables
local lanes = {}
--new lane colors
local laneColorToReach = {}

--lane color shift interval in seconds
local colorChangeSpeed = 2.5
--select new color every x second
local colorChangeInterval = 1
--temp storage for time period
local colorChangeIntervalCounter = 0

--obstacle spawn interval
local obstacleSpawnInterval = 0.5
local obstacleSpawnIntervalCounter = 0

--x coordinates that the player can be on
local playerPositions = {}

local runEXP = 0
local runGold = 0

--obstacle variables
local obstacles = {}
local obstacleImages = {}

--player is global so that it can be reached from keyController
player = { 
    position = {x = 0, y = playerPostionY, size = 50},
    image = love.graphics.newImage("assets/player.png"),
    distanceToGround = 1;
    isGoingUp = false,
    isAirBorne = false,
    moving = "forward",
    speed = 5,
    jumpSpeed = 0.1,
    lane = 2,
    level = 1,
    gold = 0,
    exp = 0
}

function love.load()

    --initiate lane positions and player positions
    for i=0, gameSize
    do
        local lane = {
            laneLineColor = { 0,0,0 },
            xPos = i*laneWidth,
            innerColor = { 0,0,0 }
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
    updatePlayer()
    updateObstacles(dt)
    updateLanes(dt)
end

function updateLanes(dt)
    --to track time
    colorChangeIntervalCounter = colorChangeIntervalCounter + dt
    if colorChangeIntervalCounter >= colorChangeInterval then
        for i=0, gameSize
        do 
            laneColorToReach[i] = { math.random(0,255), math.random(0,255), math.random(0,255) }
        end
        colorChangeIntervalCounter = 0

    else 

        --iterate through lanes
        for i, lane in pairs(lanes)
        do 
            --receive a lane color tuple 
            local newColor = compareAndAlterColors(lane.innerColor, laneColorToReach[i-1])

            lane.innerColor = newColor
            lane.laneLineColor = newColor
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
        end

        if player.distanceToGround >= 2 then
            player.isGoingUp = false
        end

        if not player.isGoingUp and player.distanceToGround >= 1 then
            player.distanceToGround = player.distanceToGround - player.jumpSpeed
            if player.distanceToGround == 1 then
                player.isAirBorne = false
            end
        end
    end

    if player.moving == "right" then
        if player.position.x <= playerPositions[player.lane] then
            player.position.x = player.position.x + player.speed
        else
            player.position.x = playerPositions[player.lane]
            player.moving = "forward"
        end
    elseif player.moving == "left" then
        if player.position.x >= playerPositions[player.lane] then
            player.position.x = player.position.x - player.speed
        else
            player.position.x = playerPositions[player.lane]
            player.moving = "forward"
        end
    end
end

function updateObstacles(dt)
    obstacleSpawnIntervalCounter = obstacleSpawnIntervalCounter + dt 
    local numberOfObstaclesInFrame = #obstacles

    if numberOfObstaclesInFrame <= gameStartDifficulty and obstacleSpawnIntervalCounter >= obstacleSpawnInterval then

        local randNum = math.random(0, #obstacleImages)
        local obstacleLane = math.random(0, gameSize)

        -- for i, obs in pairs(obstacles)
        -- do
        --     while obs.lane == obstacleLane
        --     do
        --         obstacleLane = math.random(0, gameSize)
        --     end
        -- end

        local types = {}
        types[0] = "brick"
        types[1] = "metal"
        types[2] = "wooden" 

        local obstacle = {
            --start form above the frame
            yPos = -laneWidth,
            lane = obstacleLane,
            image = obstacleImages[randNum],
            type = types[randNum]
        }

        table.insert(obstacles, obstacle)
        obstacleSpawnIntervalCounter = 0

    end

    --move and remove obstacles
    for i, obs in pairs(obstacles)
    do
        obs.yPos = obs.yPos + gameSpeed
        if obs.yPos > windowHeight then
            table.remove(obstacles, i-1)
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
    love.graphics.draw(player.image, player.position.x, player.position.y, math.rad(0),
                    player.distanceToGround, 1, 25, 25)

end