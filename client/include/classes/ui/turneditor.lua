local Class = class('TurnEditor')

function Class:initialize(hud)
    
    self.active = false

    self.hud = hud

end

function Class:update(dt)

    --

end

--[[
local turn = Turn:new()
turn:addAction( Action:new({
    time = 1, --first frame
    type = "move",
    data = {
        x = x,
        y = y
    }
}) )
]]--

function Class:draw()
    if not self:isActive() or network:getRoom():getState():isRunning() then
        return true
    end

    local x, y = love.mouse.getPosition()
    love.graphics.setColor( lue:getColor("main") )
    love.graphics.circle("line", x, y, 20 + math.cos( love.timer.getTime() * 10 ) * 2)

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

    x, y = self.hud.camera:toWorld(x, y)

    --self:addaction("move", x, y... etc") --TODO:

end

function Class:send()
    if not self.sent then

        local turns = network:getRoom():getState():getTurns()

        local index = turns:getCurrentTurnIndex()

        client:send( "turn", {
            id = index,
            data = turns:getTurn( index )[ network:getLocalIndex() ]:serialize()
        } )

        --set timer to 0 so player has feedback
        turns:setTimer( 0 )
    end
end

--

return Class