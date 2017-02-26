local Class = class('TurnEditor')

function Class:initialize()
    
    self:reset()

end

function Class:reset()
    self:setActive(false)
    self.sent = false
end

function Class:update(dt)

    if network:getRoom():getState():getTurns():getTimer() == 0 and not self.sent then
        self:sendTurn() --last chance to send turn before state resumes
    end

end

function Class:draw()
    if not network:getRoom():getState():hasStarted() or not self:isActive() or network:getRoom():getState():isRunning() then
        return true
    end

    local cos = math.cos( love.timer.getTime() * 10 )

    local x, y = love.mouse.getPosition()
    love.graphics.setColor( lue:getColor("main") )
    love.graphics.circle("line", x, y, 20 + cos * 2)

    --

    local time = network:getRoom():getState():getTurns():getTimer()
    time = time / network:getRoom():getSettings().turnTimer

    love.graphics.setColor(255, 255, 255, 100)
    love.graphics.rectangle("fill", WWIDTH*.5-200, 0, 400, 300)

    love.graphics.setColor( lue:getColor("main") )
    local remainingTurns = network:getRoom():getSettings().maxTurns - network:getRoom():getState():getTurns():getCurrentTurnIndex()
    love.graphics.printf(remainingTurns .. " turn" .. (remainingTurns == 1 and "" or "s") .. " remaining", 0, 180, WWIDTH, "center")

    love.graphics.setColor( lue:getColor("back") )
    love.graphics.setLineWidth(20)
    love.graphics.arc("line", "open", WWIDTH*.5, 100, 60 + cos * 2, (1-time) * math.pi * 2 + math.pi*.5, math.pi*2.5)

    love.graphics.setColor( lue:getColor("main") )
    love.graphics.setLineWidth(5)
    love.graphics.arc("line", "open", WWIDTH*.5, 100, 60 + cos * 2, (1-time) * math.pi * 2 + math.pi*.5, math.pi*2.5)

end

--

function Class:setActive(bool)
    self.active = bool
end
function Class:isActive()
    return self.active
end

--

function Class:mousepressed(x, y, button)
    if not self:isActive() or network:getRoom():getState():isRunning() then
        return true
    end

    x, y = g.camera:toWorld(x, y)

    --

    self:ensureCurrentTurnExists()

    local state = network:getRoom():getState()
    local index = state:getTurns():getCurrentTurnIndex()
    local turn = state:getTurns():getTurn( index )[ network:getLocalIndex() ]

    turn:reset()
    if button == 2 then
        turn:addAction( Action:new({
            time = 1, --first frame
            type = "move",
            data = {
                x = x,
                y = y
            }
        }) )
    elseif button == 1 then
        turn:addAction( Action:new({
            time = 1, --first frame TODO: add other frames as well
            type = "shoot",
            data = {
                x = x,
                y = y
            }
        }) )
    end

end

function Class:keypressed(key, scancode, isrepeat)

    --

end

function Class:ensureCurrentTurnExists()
    network:getRoom():getState():getTurns():addTurn(network:getLocalIndex(), Turn:new())
end

function Class:sendTurn()
    if not self.sent then

        self:ensureCurrentTurnExists() --FIXME: ugly

        local turns = network:getRoom():getState():getTurns()

        local index = turns:getCurrentTurnIndex()

        self.sent = true

        client:send( "turn", {
            id = index,
            data = turns:getTurn( index )[ network:getLocalIndex() ]:serialize()
        } )

        --set timer to 0 so player has feedback
        turns:setTimer( 0 )

        sounds.ui.confirm1:play() --TODO: place elsewhere?

    end
end

function Class:resetTurn()
    self.sent = false
end

--

return Class