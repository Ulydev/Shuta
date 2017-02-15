local Class = class('HUD')

function Class:initialize()
    
    self.chat = Chat:new()

end

function Class:update(dt)

    self.chat:update(dt)

end

function Class:draw()

    local room = network:getRoom()

    love.graphics.setFont(fonts.small)
    love.graphics.print("Connected to room " .. room.id, 10, 10)
    if #room.clients < room.settings.playingClients then
        love.graphics.setFont(fonts.big)
        love.graphics.printf("Waiting for other players", 0, WHEIGHT*.5 - 48, WWIDTH, "center")
    end

    love.graphics.setFont(fonts.small)
    for i = 1, #room.clients do
        local client = room.clients[i]
        local me = client.id == network:getLocalIndex()
        love.graphics.print(client.id .. (me and " <-" or ""), 10, i * 40 + 40)
    end

    self.chat:draw()

end

--

return Class