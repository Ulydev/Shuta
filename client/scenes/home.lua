local scene = state:new()
scene.name = "home"

--[[ State ]]--

buttons = {
    {
        label = "Join Server",
        x = 100,
        y = 100,
        scale = 1,
        action = function ()
            state:push("scenes/overlays/roomlist", {})
        end
    },
    {
        label = "Test",
        x = 100,
        y = 250,
        scale = 1,
        action = function ()
            print("It works!")
        end
    },
    {
        label = "Another Test",
        x = 100,
        y = 400,
        scale = 1,
        action = function ()
            print("ok")
        end
    }
}

selection = 1

--

function scene.load(params)
  
end

function scene.update(dt)

    --no need to take dt into account if it's not critical to gameplay
    for i = 1, #buttons do
        local button = buttons[i]
        local selected = i == selection
        button.scale = math.lerp(button.scale, selected and 1.6 or 1, .4)
    end

end

function scene.draw()

    love.graphics.setColor( lue:getColor("back") )
    love.graphics.rectangle("fill", 0, 0, WWIDTH, WHEIGHT)

    love.graphics.setColor( lue:getColor("main") )
    for i = 1, #buttons do
        local button = buttons[i]
        love.graphics.push()
        love.graphics.translate(button.x, button.y + 20)
        love.graphics.scale(button.scale)
        love.graphics.translate(-button.x, -(button.y + 20))
        love.graphics.print(button.label, button.x, button.y)
        love.graphics.pop()
    end

end

function scene.unload()
  
  --unload
  
end

--[[ External ]]--

function scene.keypressed(key, scancode, isrepeat)

    local dir = key == "up" and -1 or key == "down" and 1 or 0
    selection = (selection + dir - 1) % #buttons + 1

    if key == "space" then
        buttons[selection].action()
    end
  
end

--[[ End ]]--

return scene