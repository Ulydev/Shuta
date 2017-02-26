local Class = class('Room')

function Class:initialize(roomData)
  
    table.populate(self, roomData) --adds settings etc.

    self.state = GameState:new({ room = self, engineType = roomData.state and roomData.state.engineType })

end

--update

function Class:update(dt)
    self:getState():update(dt)
end

--clients

function Class:addClient(client)
    table.insert( self.clients, client )
end

function Class:removeClient(index)
    table.remove( self.clients, index )
end

function Class:filterClient(filter)
    for i = 1, self:getClientCount() do
        if filter( self:getClient(i) ) then return self:getClient(i) end
    end
    --if not found return nothing
end

function Class:getClientCount()
    return #self.clients
end

function Class:getClient(index)
    return self.clients[index]
end

--

function Class:getState()
    return self.state
end

function Class:getSimulation()
    return self.simulation
end

function Class:getSettings()
    return self.settings
end

--

return Class