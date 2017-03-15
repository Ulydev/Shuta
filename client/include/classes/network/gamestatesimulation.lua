local Class = class("GameStateSimulation", GameState)

function Class:initialize(state)

    self.state = state

    GameState.initialize(self, self.state)
    --init engine, objects, etc.

    return self
end

function Class:resetFromState()
    self.objects = {}
    self:updateData( self.state:serialize( "full" ) ) --FIXME: map needed?
end

function Class:startSimulation()
    self.engine.state = self
    self.targetFrame = self.frame + self:getRoom():getSettings().turnLength / fixed:getRate() --e.g. 2 * 30 = 60 frames to update
end

function Class:draw(alpha)
    alpha = (self.targetFrame - self.frame) / (self.targetFrame - self.state.frame) * alpha

    local _blend = love.graphics.getBlendMode()
    love.graphics.setBlendMode("alpha", "premultiplied")

    local objects = self:getObjects()
    for i = 1, #objects do
        local object = objects[i]
        if object:isInstanceOf(DynamicObject) then
            object:draw(alpha)
        end
    end

    love.graphics.setBlendMode(_blend)
end

function Class:update(dt)

    if self:hasStarted() then

        local objects = self:getObjects()
        for i = 1, #objects do
            local object = objects[i]
            if object.update then object:update( dt ) end
        end

    end

end

function Class:fixedupdate(dt)

    if self:hasStarted() then

        if self.frame < self.targetFrame then

            self.frame = self.frame + 1
            self.engine:update(dt)

            if self.frame == self.targetFrame then
                self:resetFromState()
                self:startSimulation()
            end

        end

    end

end

--

function Class:getRoom()
    return self.state:getRoom()
end

function Class:getSettings()
    return self:getRoom():getSettings()
end

function Class:getTurns()
    return self.state:getTurns()
end

--

return Class