local scene = state:new()
scene.name = "roomlist"

--[[ State ]]--

local time = 0
local selection = 1

function scene.load(params)

  
  
end

function scene.update(dt)

  time = math.to(time, scene.remove and 0 or 1, dt * 4)

end

function scene.draw()

  local time = ease("sin", time)

  love.graphics.push()
  love.graphics.translate((1 - time) * WWIDTH, 0)

  local roomList = network:getRoomList()

  for i = 1, #roomList do
    local room = roomList[i]
    love.graphics.printf("Room #" .. room.id .. " " .. room.clientCount, 0, WHEIGHT * ((i-1) / #roomList), WWIDTH, "center")
  end

  love.graphics.pop()

end

function scene.unload()
  
  scene.remove = true
  
end

--[[ External ]]--

function scene.keypressed(key, scancode, isrepeat)

  if key == "escape" then state:pop() end

  if key == "space" then client:send("joinRoom", 1) end

  return true --block propagation
  
end

--[[ End ]]--

function scene.removeReady() --give it time to fade out for smoother transition
  return time == 0
end

return scene