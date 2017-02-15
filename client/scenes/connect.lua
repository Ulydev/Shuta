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

    love.graphics.setColor( lue:getColor("back") )
    love.graphics.rectangle("fill", 0, 0, WWIDTH, WHEIGHT)

    local color = lue:getColor("main")
    love.graphics.setColor( color )

    local roomList = network.roomList

    local loading = client:getState() == "connecting"

    love.graphics.printf(message, 0, WHEIGHT*.5 + 120, WWIDTH, "center")

    if loading then
        local time = love.timer.getTime() * 6
        local radius = math.cos(time) * 10 + 60
        love.graphics.circle("line", WWIDTH*.5, WHEIGHT*.5, radius)
        local len = 10
        for i = 1, len do
            local time = time + i * .5
            love.graphics.setColor(color[1], color[2], color[3], (1 - (len - i) / len) * 255)
            love.graphics.circle("line", WWIDTH*.5 + math.cos(time) * radius*2, WHEIGHT*.5 + math.sin(time) * radius*2, radius * .2)
        end
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