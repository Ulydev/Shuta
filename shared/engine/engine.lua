local Class = class('BaseEngine')

function Class:initialize(state)

    self.state = state
  
end

--

function Class:update(dt)

    --DEBUG:
    --print("---frame " .. self:getState():getCurrentFrame())

    if self.applyAction then
        local turnManager = self:getState():getTurns()
        for index, turn in pairs( turnManager:getTurn( turnManager:getCurrentTurnIndex() ) ) do
            local state = self:getState()

            local localFrame =
                state:getCurrentFrame()
                - ( state:getTurns():getCurrentTurnIndex() - 1 )
                * ( state:getSettings().turnLength / fixed:getRate() )
            --TODO: what a fucking mess

            local actions = turn:getActionsAt( localFrame )

            for i = 1, #actions do
                self:applyAction(index, actions[i])
            end
        end
    end

    if self.updateFrame then self:updateFrame(dt) end

    if self.updateObject then
        for index, object in pairs( self.state:getObjects() ) do
            self:updateObject(dt, object)
        end
    end

end

--

function Class:getState()
    return self.state
end

return Class