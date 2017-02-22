return function(cmd)
--

local function cmdstring(command)
    return command .. " " .. (cmd.commands[command].usage or "")
end

cmd:on( function(command)
    print("->Unknown command: " .. command)
end)

--

cmd:on( "exit", function()
    love.event.quit()
end)

cmd:on( "help", function(command)
    if command then
        if cmd.commands[command] then
            print("->" .. command)
            print( cmdstring(command) )
        else
            print("->Unknown command: " .. command)
        end
    else
        print("->List of commands")
        for command, content in pairs( cmd.commands ) do
            print( cmdstring(command) )
        end
    end
end, "[command]")

cmd:on( "roomlist", function()
    print("->Room list")
    for index, room in pairs( network:getRooms() ) do
        print("#" .. room.id .. " - " .. room:getClientCount() .. "/" .. room:getSettings().maxClients)
    end
end)

cmd:on( "echo", function(roomId, ...)
    roomId = tonumber(roomId)
    if roomId < 0 then return true end

    local arg = {...}
    local string = ""
    for i, v in ipairs( arg ) do string = string .. (string == "" and "" or " ") .. tostring( v ) end
    if roomId == 0 then
        server:sendToAll("message", { text = string, sender = 0 })
    elseif network:getRoom(roomId) then
        server:sendToAllInRoom(roomId, "message", { text = string, sender = 0 })
    end
    print("->Sent \"" .. string .. "\" to room #" .. roomId)
end, "[roomId (0=global)] [message]")

--
end