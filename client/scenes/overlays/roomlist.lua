local scene = state:new()
scene.name = "roomlist"

--[[ State ]]--

local time = 0
local selection = 1

function scene.load(params)

  --request room list
  client:send("roomList")

  event:on("roomList", function()
    local roomList = 
  end)
  
end

function scene.update(dt)

  time = math.to(time, scene.remove and 0 or 1, dt * 8)

  return true

end

function scene.draw()

  love.graphics.setColor( lue:getColor("back") )
  love.graphics.rectangle("fill", 0, 0, WWIDTH, WHEIGHT)

  --

  local roomList = network:getRoomList()

  local time = ease("cubicout", time)

  love.graphics.push()
  --love.graphics.translate((1 - time) * WWIDTH, 0)

  if roomList then
  
      love.graphics.setFont( fonts.medium )
      love.graphics.setColor( lue:getColor("main") )

      for i = 1, #roomList do
        local room = roomList[i]
        love.graphics.printf(room.name, 0, WHEIGHT * ((i-1) / #roomList), WWIDTH, "center")
      end

  else

    --[[
      love.graphics.setColor( lue:getColor("mid", time * 200) )
      love.graphics.printf("Fetching room list", 0, WHEIGHT*.5, WWIDTH, "center")
    --]]

  end

  love.graphics.pop()

end

function scene.unload()
  
  scene.remove = true
  
end

--[[ External ]]--

function scene.keypressed(key, scancode, isrepeat)

  return true --block propagation
  
end

function scene.mousepressed(x, y, button)



  return true

end

--[[ End ]]--

function scene.removeReady() --give it time to fade out for smoother transition
  return time == 0
end

return scene