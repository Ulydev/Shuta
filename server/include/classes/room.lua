local Class = class("Room")

function Class:initialize(id, gameSettings)
    self.clients = {} --1...n indexed table
    self.id = id
    self.state = GameState:new(self) --link state to room
    self.settings = GameSettings:new(gameSettings)

    return self
end

--

function Class:update(dt)

end

function Class:fixedupdate(dt)

end

--

function Class:getClientList()
    local clients = {}
    for i = 1, #self.clients do --Room.clients is sorted
        local client = self.clients[i]
        table.insert(clients, {
            id = client:getIndex()
        })
    end
    return clients
end

--[[
Room.clients is sorted, which means we have to move clients in a cycle to change their play order
(e.g. only client #1 and client #2 will get to play
]]--
function Class:getClient(index)
    return self.clients[index]
end

function Class:getClientCount()
    return #self.clients
end

--

function Class:hasEnoughPlayers()
    return self:getClientCount() >= self:getSettings().playingClients
end

function Class:isFull()
    return self:getClientCount() >= self:getSettings().maxClients
end

--

function Class:addClient(client)

    table.insert( self.clients, client )
    client.room = self

end

function Class:removeClient(client)

    for i = 1, #self.clients do
        if self.clients[i] == client then
            table.remove( self.clients, i )
            break;
        end
    end
    client.room = nil

end

--

function Class:checkNewGame()
    if self:hasEnoughPlayers() and not self:getState():hasStarted() then
        --if room is ready to start, begin match (sets initial state)
        self:startGame()

        --broadcast initial game state (client position, entities, etc.)
        --once the client has this state it can simulate the outcome of the game
        server:sendToAllInRoom(self.id, "gameState", self:getState():serialize("with_map"))
    end
end

function Class:startGame()
    local gameState = self:getState()

    --there are enough players to start game, let's populate state
    gameState:start()
end

function Class:stopGame()
    local gameState = self:getState()

    gameState:stop()

    server:sendToAllInRoom(self.id, "gameState", gameState:serialize())
end

--

function Class:getState()
    return self.state
end

function Class:getSettings()
    return self.settings
end

--

function Class:serialize() --more complete information to send as a whole
    return {
        id = self.id,
        clients = self:getClientList(),
        state = self:getState():serialize(),
        settings = self:getSettings():serialize(),
    }
end

function Class:serializeList() --minimal information for roomList
    return {
        id = self.id,
        clientCount = self:getClientCount(),
    }
end

return Class