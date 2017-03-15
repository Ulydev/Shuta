local function leaveRoom(client)
    local room = client.room
    if (room) then
        network:getRoom(room.id):removeClient(client)
        server:sendToAllInRoom(room.id, "remoteDisconnect", { id = client.id })

        log("[#" .. room.id .. "] " .. client.toString() .. " left")

        if room:getState():filterObject(function(o)
            return (o:isInstanceOf(Character) and o.client.id == client.id)
        end) then
            --client was playing, let's reset state and check for new game
            room:getState():reset()
            room:checkNewGame()
        end
    end
end

--

local function addUtilLayer(server)

    --layer on top of sock.lua
    function server:sendToClients(clients, event, data)
        for i = 1, #clients do
            clients[i]:send(event, data)
        end
    end

    function server:sendToAllInRoom(roomId, event, data)
        local clients = {}
        for _, client in pairs( network:getRoom(roomId).clients ) do
            table.insert(clients, client)
        end
        return server:sendToClients(clients, event, data)
    end

    function server:sendRoomMessage(roomId, message)
        return server:sendToAllInRoom(roomId, "message", { text = message, sender = 0}) --id 0 stands for server
    end

end

local function setConnectionCallbacks(server)

    --global

    server:on("connect", function(data, client, test)
        print(data)

        local randname = ""
        for i = 1, math.random(6, 10) do
            randname = randname .. string.char( math.random(65, 90) )
        end
        client.toString = function() --quick, dirty hack
            return "[" .. client.name .. "(" .. client.id .. ")]"
        end

        client.name = randname --TODO: let player choose their own name
        client.id = client:getIndex() --TODO: proper client:init() method

        client:send("init", { id = client.id, name = client.name })

        log(client.toString() .. " connected")
    end)

    server:on("disconnect", function(data, client)
        leaveRoom(client) --when quitting, process doesn't have time to send "leaveRoom"
        log(client.toString() .. " disconnected")
    end)
   
    --room

    server:on("joinRoom", function(roomId, client)
        if not roomId then roomId = 2 end
        --^ TODO: quick play redirects to room #2 for now (fast-paced)

        local oldRoom = client.room
        if (oldRoom) then
            oldRoom:removeClient(client)
            server:sendToAllInRoom(oldRoom.id, "remoteDisconnect", { id = client.id })
            --^ every client should already have a list of names
        end

        local room = network:getRoom(roomId)

        server:sendToAllInRoom(roomId, "remoteConnect", { id = client.id, name = client.name }) --notify everyone of client connection
        room:addClient(client) --add client to room

        --send client initial data
        --if game hasn't started yet - gameState will be broadcasted when it starts
        --if game has started - gameState will be serialized along with joinRoom
        client:send( "joinRoom", room:serialize( room:getState():hasStarted() ) )

        log("[#" .. roomId .. "] " .. client.toString() .. " joined")

        room:checkNewGame() --TODO: fix that ugly naming?
    end)

    server:on("leaveRoom", function(data, client) --data isn't used for now
        leaveRoom(client)
    end)

end

local function setDataCallbacks(server)

    server:on("roomList", function(data, client)
        client:send("roomList", network:getRoomList())
    end)

    server:on("turn", function(turn, client)
        local turnIndex = turn.id
        local turnData = turn.data

        --store input
        local room = client.room
        if room and room:getState():hasStarted() then
            local added

            if turnIndex == room:getState():getTurns():getCurrentTurnIndex() then
                added = room:getState():getTurns():addTurn(
                    client.id,
                    Turn:new( turnData ),
                    false --don't force to prevent cheating
                )
            end

            --DEBUG:
            log("[#" .. room.id .. "] " .. client.toString() .. " turn " .. (added and "registered" or "skipped") )

            if added and room:getState():getTurns():isReady() then --we got all turns!
                
                room:getState():getTurns():setTimer(.5)

            end

        end
        
    end)

    server:on("message", function(text, client)
        local room = client.room
        if room then
            server:sendToAllInRoom(room.id, "message", { text = text, sender = client.id })
        end
    end)

end

local function setCallbacks(server)

    --set basic callbacks
    setConnectionCallbacks(server)

    --set specific callbacks
    setDataCallbacks(server)

end

--

return {

init = function(server)

    addUtilLayer(server)

    setCallbacks(server)

end

}