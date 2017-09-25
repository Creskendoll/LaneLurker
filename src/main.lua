require("keyController")
math.randomseed(os.time())

--white background
love.graphics.setBackgroundColor( 255, 255, 255 )

local gameSize = 5
local windowWidth = love.graphics.getWidth()
local laneWidth = windowWidth/gameSize
local playerPositionWidth = laneWidth/2
local playerPostionY = love.graphics.getHeight() - playerPositionWidth

local gameSpeed = 5

--x coordinates that the player can be on
local playerPositions = {}

local runEXP = 0
local runGold = 0

--obstacle variables
local obstacles = {}
local obstacleImages = {}

--lane variables
local lanes = {}
local laneColorsToReach = {}

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
            laneLineColor = { math.random(0,255), math.random(0,255), math.random(0,255) },
            xPos = i*laneWidth,
            innerColor = { math.random(0,255), math.random(0,255), math.random(0,255) },
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

    updateObstacles()

    for i=0, gameSize
    do 
        laneColorsToReach[i] = {math.random(0,255), math.random(0,255), math.random(0,255)}
    end
end

function love.update(dt)
    updatePlayer()
    updateObstacles()
    updateLanes()
end

function updateLanes()
    --TODO
    for i, lane in pairs(lanes)
    do  
        lane.innerColor = { math.random(0,255), math.random(0,255), math.random(0,255) }
        lane.laneLineColor = { math.random(0,255), math.random(0,255), math.random(0,255) }
    end
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

function updateObstacles()
    local randNum = math.random(0, #obstacleImages)

    local types = {}
    types[0] = "brick"
    types[1] = "metal"
    types[2] = "wooden" 

    local obstacle = {
        yPos = -laneWidth,
        lane = math.random(0, gameSize),
        image = obstacleImages[randNum],
        type = types[randNum]
    }

    for i, obs in pairs(obstacles)
    do
        obs.yPos = obs.yPos + gameSpeed
    end

    table.insert(obstacles, obstacle)
end

function love.draw()
    --draw lines and lanes
    for i, lane in pairs(lanes)
    do
        --lane
        love.graphics.setColor(lane.innerColor, 255)
        print(lane)
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