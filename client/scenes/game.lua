local game = state:new()

local camera
local hud
local player

--[[ State ]]--

function game.load(params)

  hud = HUD:new()

  local w, h = WWIDTH * 10, WHEIGHT * 10
  camera = gamera.new(-w*.5, -h*.5, w, h) --TODO: send game area dimensions server-side
  camera:setWindow(0, 0, WWIDTH, WHEIGHT)

  event:on("gameStarted", function()
    local started = network:getRoom():getState():hasStarted()
    if started then


      print("Game has started") 

      local gstate = network:getRoom():getState()
      player = gstate:filterObject(
        function(o) return ( o.class == "Character" and o.client.id == network:getLocalIndex() ) end
      )--get local character
      camera:setPosition(player.x, player.y)

    else

      print("Game has ended")
      --TODO handle state reset

    end
  end)

end

function game.update(dt)

  hud:update(dt)

  if network:getRoom():getState():hasStarted() then
    local x, y = camera:getPosition()
    camera:setPosition( math.lerp(x, player.x, .1), math.lerp(y, player.y, .1) )
  end

end

function game.fixedupdate(dt)

  network:getRoom():getState():fixedupdate(dt)

end

--

function game.draw()

  love.graphics.setColor( lue:getColor("back") )
  love.graphics.rectangle("fill", 0, 0, WWIDTH, WHEIGHT)


  camera:draw( game.drawCamera )


  love.graphics.setColor( lue:getColor("main") )

  hud:draw() --waiting for players or game started

end

function game.drawCamera(l, t, w, h)
  
  love.graphics.setColor( lue:getColor("main") )

  local gameState = network:getRoom():getState()
  if gameState:hasStarted() then
    gameState:draw()
  end
  
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
  hud.chat:addMessage(sender, text)
end

function game.mousepressed(x, y, button)

  x, y = push:toGame(x, y)
  x, y = camera:toWorld(x, y)

  --DEBUG
  local turn = Turn:new()
  turn:addAction( Action:new({
    time = 1, --first frame
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