local Class = class('Room')

function Class:initialize(roomData)
  
    table.populate(self, roomData) --adds settings etc.

    self.state = GameState:new( self )

end

--clients

function Class:addClient(client)
    table.insert(self.clients, client)
end

function Class:removeClient(index)
    table.remove(self.clients, index)
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

function Class:getSettings()
    return self.settings
end

--

return Class