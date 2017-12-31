love.window.setMode( 1366, 768, {vsync = true, minwidth=600, minheight=600} )

--time related(!)
deltaTimeOffSet = 15

current = 0

--lane count - 1 beacuse the arrays
gameSize = 4
windowWidth = love.graphics.getWidth()
windowHeight = love.graphics.getHeight()

gameIsRunning = true
--because there is gameSize+1 many lanes
laneWidth = windowWidth/(gameSize+1)

--player related
playerPositionWidth = laneWidth/2

playerPostionY = love.graphics.getHeight() - playerPositionWidth

getPlayerSpeed = function (gameDifficulty)
    return player.speed + gameDifficulty
end
--x coordinates that the player can be on
playerPositions = {}
playerLaneToGo = 2
playerImmunityCounter = 0
playerFlashCounter = 0
playerFlashInvisTime = 0.3

getPlayerJumpSpeed = function ( gameDifficulty )
    return player.jumpSpeed + gameDifficulty/100
end

--game related
gameDifficulty = 1

getGameSpeed = function (gameDifficulty)
    return 4 + gameDifficulty
end

getMaxObstacleOnScreen = function (gameDifficulty)
    return 5 + gameDifficulty 
end

getMaxObstaclePerLane = function ( gameDifficulty )
    return 1 + gameDifficulty/10
end

collisionDamage = 25

--lane variables
lanes = {}
--new lane colors, regular array
laneColorToReach = {}

--lane buffs
--in seconds
getLaneBuffSpawnRate = function (randNum)
    return randNum + 1
end

laneBuffActiveCounter = 0
buffedLanes = {}
--nothing is buffed
laneToBuff = -1

--lane color shift interval in seconds
colorChangeSpeed = 2.5
--select new color every x second
colorChangeInterval = 1
--temp storage for time period
colorChangeIntervalCounter = 0

--spawn obstacle every x seconds
getObstacleSpawnInterval = function (gameDifficulty)
    return 0.5 - 0.01*gameDifficulty
end

obstacleSpawnIntervalCounter = 0

runEXP = 0
runGold = 0

--obstacle variables
obstacles = {}
obstacleImages = {}
obstacleLaneCount = {}