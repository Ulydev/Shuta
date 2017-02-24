local game = state:new()

local camera
local hud

local player --if playing
local players --if not playing

local function updateCamera(lerp)
  local pos = { x = 0, y = 0 }
  if player then --center camera on player
      pos = player.visual
  elseif players then --center camera on avg position
      for i = 1, #players do
        pos.x, pos.y = pos.x + players[i].visual.x, pos.y + players[i].visual.y
      end
      pos.x, pos.y = pos.x / #players, pos.y / #players
  end
  local x, y = camera:getPosition()
  if not lerp then x, y = pos.x, pos.y end
  camera:setPosition( math.lerp(x, pos.x, .1), math.lerp(y, pos.y, .1) )
end

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

      players = gstate:filterObjects(
        function(o) return ( o.class == "Character" ) end
      )
      for i = 1, #players do
        if players[i].client.id == network:getLocalIndex() then
          player = players[i]
          break;
        end
      end

      updateCamera(false)

    else

      print("Game has ended")
      --TODO handle state reset

    end
  end)

end

function game.update(dt)

  hud:update(dt)

  if network:getRoom():getState():hasStarted() then
    updateCamera()
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

  local x, y = love.mouse.getPosition()
  x, y = push:toGame(x, y)
  if x and y then love.graphics.circle("fill", x, y, 30) end

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

  if not player then return true end --only client-side check, no big deal
  if network:getRoom():getState():isRunning() then return true end --game is running

  x, y = push:toGame(x, y)
  x, y = camera:toWorld(x, y)

  if not x or not y then return true end --push returns nil

  --DEBUG:
  local turn = Turn:new()
  turn:addAction( Action:new({
    time = 1, --first frame
    type = "move",
    data = {
      x = x,
      y = y
    }
  }) )

  client:send( "turn", {
    id = network:getRoom():getState():getTurns():getCurrentTurnIndex(),
    data = turn:serialize()
  } )
end

--[[ End ]]--

return game