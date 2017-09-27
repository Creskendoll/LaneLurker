--returns true if there is collision
function checkCollision(dt)

    if player.state == "immune" then
        playerImmunityCounter = playerImmunityCounter + dt

        --if flash counter has started
        if not player.isVisible then
            if playerFlashCounter > 0 then
                playerFlashCounter = playerFlashCounter + dt
            end

            if playerFlashCounter >= playerFlashInvisTime then
                playerFlashCounter = 0
                player.isVisible = true
            end
        else
            playerFlashCounter = playerFlashCounter + dt
            if playerFlashCounter >= playerFlashInvisTime then
                playerFlashCounter = 0 + dt
                player.isVisible = false
            end
        end
    end

    --change player state to normal
    if playerImmunityCounter > player.immunityTime then
        player.state = "normal"
        playerImmunityCounter = 0
        player.isVisible = true
    end

    for i, obstacle in pairs(obstacles)
    do
        --player takes damage and enters immune mode
        --TODO: expand this
        if not player.isAirBorne then
            if calculateDistance(obstacle) < 50 then
                if player.state == "normal" then
                    player.health = player.health - collisionDamage --not immune and playerImmunityCounter = 0
                    player.state = "immune"
                    playerImmunityCounter = playerImmunityCounter + dt

                    --initialize player flashing
                    playerFlashCounter = playerFlashCounter + dt
                    player.isVisible = false
                end                
            end
        end
    end

    --if player is dead
    if player.health <= 0 then 
        playerImmunityCounter = 0
        playerFlashCounter = 0
        player.state = "dead"
        return true 
    end

    return false
end

--returns distance between player and obstacle
function calculateDistance(obstacle)
    local xDifference = (obstacle.position.x - player.position.x)^2 + (obstacle.position.y - player.position.y)^2
    return math.sqrt( xDifference )
end