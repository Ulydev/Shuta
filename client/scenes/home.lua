local scene = state:new()
scene.name = "home"

--[[ State ]]--

local buttons = {
    Button:new({ --TODO: UI manager / button manager
        text = "Quick Play",
        x = WWIDTH*.5,
        y = WHEIGHT*.5 - 100,
        width = 600,
        height = 160,
        font = fonts.light.big,
        action = function ()
            client:send("joinRoom")
        end
    }),
    Button:new({
        text = "Room List",
        x = WWIDTH*.5,
        y = WHEIGHT*.5 + 100,
        width = 600,
        height = 160,
        font = fonts.light.big,
        action = function ()
            state:push("scenes/overlays/roomlist", {})
        end
    }),
    Button:new({
        text = "Quit",
        x = WWIDTH*.5,
        y = WHEIGHT*.5 + 300,
        width = 600,
        height = 160,
        font = fonts.light.big,
        action = function ()
            love.event.push("quit")
        end
    })
}

--

function scene.load(params)

    shaders.values.vignette:to(0)
  
end

function scene.update(dt)

    for i = 1, #buttons do
        buttons[i]:update(dt)
    end

end

function scene.draw()

    love.graphics.setColor( lue:getColor("back") )
    love.graphics.rectangle("fill", 0, 0, WWIDTH, WHEIGHT)

    love.graphics.setColor( lue:getColor("main") )
    for i = 1, #buttons do
        buttons[i]:draw()
    end

    love.graphics.setFont( fonts.light.medium )
    love.graphics.setColor( lue:getColor("mid") )
    love.graphics.printf( "Connected as " .. (network:getLocalName() or "") .. "\nv" .. version, -10, 10, WWIDTH, "right" )

    local offset = math.cos( love.timer.getTime() * 1 )

    love.graphics.setFont( fonts.title )
    love.graphics.setColor( lue:getColor("main") )
    love.graphics.push()

    local x, y = WWIDTH*.5, 100 + offset * 10
    love.graphics.translate(x, y)
    love.graphics.rotate( math.cos(offset * 10) * .02 )
    love.graphics.translate(-x, -y)
    love.graphics.printf( "SHUTA", 0, y, WWIDTH, "center" )
    love.graphics.pop()

end

function scene.unload()
  
  --unload
  
end

--[[ External ]]--

function scene.mousepressed(x, y, button)

    for i = 1, #buttons do
        buttons[i]:mousepressed(x, y, button)
    end

end

function scene.keypressed(key, scancode, isrepeat)

    if key == "p" then --DEBUG:
        client:send("joinRoom") --quick play
    end
  
end

--[[ End ]]--

return scene