local scene = state:new()
scene.name = "roomlist"

--[[ State ]]--

local time = 0
local selection = 1

local buttons = {}

function scene.load(params)

  --request room list
  client:send("roomList")

  event:on("roomList", function()
    --add buttons and stuff TODO:
    local roomList = network:getRoomList()

    buttons = {}
    for i = 1, #roomList do

      local room = roomList[i]
      buttons[i] = Button:new({
        text = room.name,
        x = WWIDTH*.5,
        y = WHEIGHT*.5 - 300 + 200 * (i-1),
        width = 600,
        height = 160,
        font = fonts.light.big,
        action = function ()
            client:send("joinRoom", room.id)
        end
      })

    end
  end)
  
end

function scene.update(dt)

  time = math.to(time, scene.remove and 0 or 1, dt * 8)

  for i = 1, #buttons do
      buttons[i]:update(dt)
  end

  return true

end

function scene.draw()

  love.graphics.setColor( lue:getColor("back") )
  love.graphics.rectangle("fill", 0, 0, WWIDTH, WHEIGHT)

  --

  local time = ease("cubicout", time)

  love.graphics.push()
  --love.graphics.translate((1 - time) * WWIDTH, 0)

  if network:getRoomList() then
  
      love.graphics.setColor( lue:getColor("main") )
      for i = 1, #buttons do
          buttons[i]:draw()
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
  
  event:reset("roomList")

  scene.remove = true
  
end

--[[ External ]]--

function scene.keypressed(key, scancode, isrepeat)

  if key == "escape" then
    state:pop()
  end

  return true --block propagation
  
end

function scene.mousepressed(x, y, button)

  for i = 1, #buttons do
    buttons[i]:mousepressed(x, y, button)
  end

  return true

end

--[[ End ]]--

function scene.removeReady() --give it time to fade out for smoother transition
  return time == 0
end

return scene