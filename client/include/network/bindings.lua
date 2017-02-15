local function setConnectionCallbacks(client)

    client:on("connect", function()
        print("connected")
        if state:getName(1) == "connect" then --state:getName(1) -> first page of stack
            print("switching state")
            state:switch("scenes/home")
        end
    end)

    client:on("disconnect", function()
        print("disconnected")
        local msg = "Connection lost"
        if state:getName(1) == "connect" then
            msg = "Couldn't connect to server"
        end
        state:switch("scenes/connect", msg)
    end)

    client:on("init", function(index) --get initial necessary data
        network:setLocalIndex(index)
    end)

end

local function setRoomCallbacks(client)

    client:on("roomList", function(roomList)
        network:setRoomList( roomList )
    end)

    --

    client:on("joinRoom", function(roomData)
        network:setRoom( Room:new( roomData ) )
        state:switch("scenes/game")
    end)

    --

    client:on("remoteConnect", function(remoteClient)
        network:getRoom():addClient( remoteClient )
    end)

    client:on("remoteDisconnect", function(remoteClient)
        for i = 1, network:getRoom():getClientCount() do
            if network:getRoom():getClient(i).id == remoteClient.id then
                network:getRoom():removeClient(i)
                break;
            end
        end
    end)

end

local function setDataCallbacks(client)

    client:on("message", function(message)
        state.messagereceived(message)
    end)

    --

    client:on("gameState", function(stateData)
        local started = network:getRoom():getState():hasStarted() --returns false by default

        pprint(stateData)
        network:getRoom():getState():updateData( stateData )

        if started ~= network:getRoom():getState():hasStarted() then
            event:emit("gameStarted")
        end
    end)

    --

    client:on("turnList", function(turnList)

        pprint(turnList)

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