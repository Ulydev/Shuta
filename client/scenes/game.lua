local game = state:new()

g = {}

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
  g.hud = hud

  local w, h = WWIDTH * 10, WHEIGHT * 10
  camera = gamera.new(-w*.5, -h*.5, w, h) --TODO: send arena dimensions server-side
  camera:setWindow(0, 0, WWIDTH, WHEIGHT)
  g.camera = camera

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

      hud.editor:setActive(player and true or false)

      updateCamera(false)

    else

      print("Game has ended")

      hud.editor:setActive(false)

      player = nil
      players = nil

    end
  end)

end

function game.update(dt)

  hud:update(dt)

  if network:getRoom():getState():hasStarted() then
    updateCamera(true)
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
  local editor = hud.editor

  if key == "backspace" then
    chat:removeInput(1) --remove 1 character
  elseif key == "return" then
    chat:sendInput()
    chat:toggleInput()
  elseif key == "escape" then
    chat:toggleInput()
  elseif key == "space" then
    editor:sendTurn()
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

  hud:mousepressed(x, y, button)

end

--[[ End ]]--

return game