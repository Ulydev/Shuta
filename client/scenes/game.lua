local game = state:new()

game.world = {
  width = 8000,
  height = 8000,
  entities = {
    players = {},
    projectiles = {}
  }
}

local world = game.world
local e = world.entities

local hud

--[[ State ]]--

function game.load(params)

  event:on("gameStarted", function()
    local started = network:getRoom():getState():hasStarted()
    if started then
      print("Game just started") 
    else
      print("Game just stopped")
    end
  end)

  hud = HUD:new()

  --[[

  world.camera = gamera.new(0, 0, world.width, world.height)
  world.camera:setWindow(0, 0, WWIDTH, WHEIGHT)
  world.camera:setPosition(e.player.x, e.player.y)
  
  world.starfield = Starfield:new({ count = 200, offsetScale = .02 })

  --]]
  
end

function game.update(dt)

  hud:update(dt)

end

function game.draw()
  
  --world.camera:draw( game.drawCamera )

  love.graphics.setColor( lue:getColor("back") )
  love.graphics.rectangle("fill", 0, 0, WWIDTH, WHEIGHT)

  love.graphics.setColor( lue:getColor("main") )

  local room = network:getRoom()
  if room:getState():hasStarted() then
    local objects = room:getState():getObjects()
    for i = 1, #objects do
      local object = objects[i]
      object:draw()
    end
  end

  hud:draw()

end

function game.drawCamera(l, t, w, h)
  
  
  
end

function game.unload()
  
  event:reset("gameStarted")
  
end

--[[ External ]]--

function game.keypressed(key, scancode, isrepeat)

  local chat = hud.chat
  if key == "backspace" then
    chat:removeInput(1) --remove 1 character
  elseif key == "return" then
    chat:sendInput()
    chat:toggleInput()
  elseif key == "espace" then
    chat:toggleInput()
  end
  
end

function game.textinput(text)

  local chat = hud.chat
  if chat.isWriting then chat:addInput(text) end

end

function game.messagereceived(message)
  local text = message.text
  local sender = message.sender
  hud.chat:addMessage(sender .. ": " .. text)
end

function game.mousepressed(x, y, button)

  --DEBUG
  local turn = Turn:new()
  turn:addAction( Action:new({
    time = 0,
    type = "move",
    data = {
      x = x,
      y = y
    }
  }) )

  client:send( "turn", turn:serialize() )
end

--[[ End ]]--

return game