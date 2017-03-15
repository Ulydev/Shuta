local scene = state:new()
scene.name = "connect"

local message = "Connecting to server"

--[[ State ]]--

function scene.load(customMessage)

  if customMessage then message = customMessage end
  
end

function scene.update(dt)



end

function scene.draw()

    push:setCanvas("ui")

    love.graphics.setColor( lue:getColor("main") )

    local roomList = network.roomList

    local loading = client:getState() == "connecting"

    love.graphics.setFont(fonts.light.medium)
    love.graphics.printf(message, 0, WHEIGHT*.5 + 120, WWIDTH, "center")

    if loading then
        local time = love.timer.getTime() * 6
        local radius = math.cos(time) * 10 + 60
        
        love.graphics.push()
        love.graphics.translate(WWIDTH*.5, WHEIGHT*.5)
        love.graphics.rotate(time)
        love.graphics.translate(-WWIDTH*.5, -WHEIGHT*.5)

        love.graphics.setLineWidth(5)
        love.graphics.setColor( lue:getColor("main") )
        love.graphics.arc("line", "open", WWIDTH*.5, WHEIGHT*.5, radius, 0, math.pi*1.4 + math.cos(time * .2) * .5)

        love.graphics.pop()

    end

end

function scene.unload()
  
  --unload
  
end

--[[ External ]]--

function scene.keypressed(key, scancode, isrepeat)

  
  
end

--[[ End ]]--

return scene