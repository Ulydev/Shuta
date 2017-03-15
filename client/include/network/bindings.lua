local function updateData(data)
    local started = network:getRoom():getState():hasStarted() --returns false by default

    network:getRoom():getState():updateData(data)

    if started ~= network:getRoom():getState():hasStarted() then
        event:emit("gameStarted")
    end
end

local function setConnectionCallbacks(client)

    client:on("connect", function()
        print("connected")
        if state:getName(1) == "connect" then --state:getName(1) -> first page of stack
            state:switch("scenes/home")
        end
    end)

    client:on("disconnect", function()
        print("disconnected")
        local msg = "Connection lost\nPlease try again later"
        if state:getName(1) == "connect" then
            msg = "Couldn't connect to server"
        end
        state:switch("scenes/connect", msg)
    end)

    client:on("init", function(data) --get initial necessary data
        network:setLocalData(data)
    end)

end

local function setRoomCallbacks(client)

    client:on("roomList", function(roomList)
        network:setRoomList( roomList )
        event:emit("roomList")
    end)

    --

    client:on("joinRoom", function(roomData)

        network:setRoom( Room:new( roomData ) )

        state:switch("scenes/game") --fixes order issue TODO:

        if roomData.state then
            updateData( roomData.state )
        end

        love.messagereceived("Connected to room " .. network:getRoom().id)
    end)

    --

    client:on("remoteConnect", function(remoteClient)
        network:getRoom():addClient( remoteClient )
        local name = remoteClient.name or ""
        love.messagereceived(name .. "(" .. remoteClient.id .. ") has joined the game")
    end)

    client:on("remoteDisconnect", function(remoteClient) --only ID is sent

        local name

        for i = 1, network:getRoom():getClientCount() do
            if network:getRoom():getClient(i).id == remoteClient.id then
                name = network:getRoom():getClient(i).name
                network:getRoom():removeClient(i)
                break;
            end
        end
        name = name or ""
        love.messagereceived(name .. "(" .. remoteClient.id .. ") has left the game")

        if network:getRoom():getState():filterObject(function(o)
            return o:isInstanceOf(Character) and o.client.id == remoteClient.id
        end) then

            network:getRoom():getState():reset()
            event:emit("gameStarted") --hasStarted is false

        end

    end)

end

local function setDataCallbacks(client)

    client:on("message", function(message)
        love.messagereceived(message)
    end)

    --

    client:on("gameState", function(stateData) --updates state
        if network:getRoom():getState():getWinner() then
            network:getRoom():getState():reset()
        end

        print("Received game state")

        updateData( stateData )
    end)

    --

    client:on("turnList", function(turnList)

        local room = network:getRoom()
        if room then

            for i = 1, #turnList do
                local el = turnList[i]
                room:getState():getTurns():addTurn(
                    el.id,
                    Turn:new( el.turn ),
                    true --force because server is authoritative
                )
            end
            --once every turn is added, simulate state then go to next /round/

            room:getState():nextTurnFrame()

            sounds.ui.turn.start:play() --TODO: place elsewhere

        end
        
    end)

end

local function setCallbacks(client)

    --set basic callbacks
    setConnectionCallbacks(client)

    --room-related e.g. join/leave
    setRoomCallbacks(client)

    --game-related e.g. state
    setDataCallbacks(client)

end

--

return {

init = function(client)

    setCallbacks(client)

end

}