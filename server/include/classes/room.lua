local Class = class("Room")

function Class:initialize(args)
    self.clients = {} --1...n indexed table
    self.id = args.id
    self.name = args.name
    self.settings = GameSettings:new(args.settings) --load settings first
    
    self.state = GameState:new({ room = self, map = args.map, engineType = args.engineType or "SimplePhysicsEngine" }) --link state to room

    return self
end

--

function Class:update(dt)
    self:getState():update(dt)
end

function Class:fixedupdate(dt)

end

--

function Class:getClientList()
    local clients = {}
    for i = 1, #self.clients do --Room.clients is sorted
        local client = self.clients[i]
        table.insert(clients, {
            id = client.id,
            name = client.name
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
    end
end

function Class:startGame()
    local gameState = self:getState()

    --there are enough players to start game, let's populate state
    gameState:start()
    --FIXME: state is reset but weird stuff happens when new clients join

    --broadcast initial game state (client position, entities, etc.)
    --once the client has this state it can simulate the outcome of the game
    server:sendToAllInRoom(self.id, "gameState", self:getState():serialize( "full" ))

    log("Game " .. self.id .. " has started")
end

function Class:stopGame()
    local gameState = self:getState()

    gameState:stop()

    log("Game " .. self.id .. " has ended")
end

--

function Class:getState()
    return self.state
end

function Class:getSettings()
    return self.settings
end

--

function Class:serialize( full ) --more complete information to send as a whole
    return {
        id = self.id,
        name = self.name,
        clients = self:getClientList(),
        state = self:getState():serialize( full ),
        settings = self:getSettings():serialize(),
    }
end

function Class:serializeList() --minimal information for roomList
    return {
        id = self.id,
        name = self.name,
        clientCount = self:getClientCount(),
    }
end

return Class