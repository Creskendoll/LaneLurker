function love.keypressed(key)
    if key == " " then

        if not player.isAirBorne then
            player.isAirBorne = true
            player.isGoingUp = true
        end

    elseif key == "d" then

        if player.lane < 4 and player.moving == "forward" then --can remove player.moving to move more smooth 
            playerLaneToGo = playerLaneToGo + 1
            player.moving = "right"
        end

    elseif key == "a" then

        if player.lane > 0 and player.moving == "forward" then
            playerLaneToGo = playerLaneToGo - 1
            player.moving = "left"
        end

    elseif key == "f11" then
        love.graphics.toggleFullscreen()
    end

end