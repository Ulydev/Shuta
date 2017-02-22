local function addUtilLayer(server)

    --layer on top of sock.lua
    function server:sendToClients(clients, event, data)
        for i = 1, #clients do
            clients[i]:send(event, data)
        end
    end

    function server:sendToAllInRoom(roomId, event, data)
        local clients = {}
        for index, client in pairs( network:getRoom(roomId).clients ) do
            table.insert(clients, client)
        end
        return server:sendToClients(clients, event, data)
    end

    function server:sendRoomMessage(roomId, message)
        return server:sendToAllInRoom(roomId, "message", { text = message, sender = 0}) --id 0 stands for server
    end

end

local function setConnectionCallbacks(server)

    server:on("connect", function(data, client)
        local index = client:getIndex()

        local randname = ""
        for i = 1, math.random(6, 10) do
            randname = randname .. string.char( math.random(65, 90) )
        end
        client.toString = function() --quick, dirty hack
            return "[" .. client.name .. "(" .. index .. ")]"
        end

        client.name = randname --TODO: let player choose their own name

        client:send("init", { id = index, name = client.name })
        client:send("roomList", network:getRoomList())

        log(client.toString() .. " connected")
    end)

    server:on("disconnect", function(data, client)
        local index = client:getIndex()

        local room = client.room
        if (room) then --first remove client from room...
            network:getRoom(room.id):removeClient(client) --at this point client.room is being nil'ed

            server:sendToAllInRoom(room.id, "remoteDisconnect", { id = index }) --notify other clients

            --TODO: if client was playing then room:stopGame()
            --then room:checkNewGame()
        end

        log(client.toString() .. " disconnected")
    end)

end

local function setDataCallbacks(server)

    --TODO: remove redundant code

    server:on("leaveRoom", function(roomId, client)
        local index = client:getIndex()

        local oldRoom = client.room
        if (oldRoom) then
            network:getRoom(oldRoom.id):removeClien(client)
            server:sendToAllInRoom(oldRoom.id, "remoteDisconnect", { id = index })
        end

        client:send("leaveRoom", roomId)

        log("[#" .. roomId .. "] " .. client.toString() .. " left")
    end)

    server:on("joinRoom", function(roomId, client)
        local index = client:getIndex()

        local oldRoom = client.room
        if (oldRoom) then
            oldRoom:removeClient(client)
            server:sendToAllInRoom(oldRoom.id, "remoteDisconnect", { id = index }) --we've already sent name
        end

        local room = network:getRoom(roomId)

        server:sendToAllInRoom(roomId, "remoteConnect", { id = index, name = client.name }) --notify everyone of client connection
        room:addClient(client) --add client to room

        --send client initial data
        --if game hasn't started yet - gameState will be broadcasted when it starts
        --if game has started - gameState will be serialized along with joinRoom
        client:send( "joinRoom", room:serialize() )

        log("[#" .. roomId .. "] " .. client.toString() .. " joined")

        room:checkNewGame() --TODO: fix that ugly naming?
    end)

    server:on("turn", function(turnData, client)
        local index = client:getIndex()

        --store input
        local room = client.room
        if room and room:getState():hasStarted() then
            local added = room:getState():getTurns():addTurn(
                client:getIndex(),
                Turn:new( turnData ),
                false --don't force to prevent cheating
            )

            --DEBUG:
            log("[#" .. room.id .. "] " .. client.toString() .. " turn " .. (added and "registered" or "skipped") )

            if room:getState():getTurns():isReady() then --we got all turns!
                local turns = room:getState():getTurns()
                server:sendToAllInRoom( room.id, "turnList", turns:serialize(turns:getCurrentTurnIndex()) )

                --simulate state
                room:getState():nextTurnFrame()

                log("[#" .. room.id .. "] Simulating to frame " .. room:getState().targetFrame )

                room:getState():fullUpdate()
            end
        end
        
    end)

    server:on("message", function(text, client)
        local room = client.room
        if room then
            server:sendToAllInRoom(room.id, "message", { text = text, sender = client:getIndex() })
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