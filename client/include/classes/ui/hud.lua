local Class = class('HUD')

function Class:initialize()
    
    self.chat = Chat:new(self)

    self.editor = TurnEditor:new(self)

end

function Class:update(dt)

    self.chat:update(dt)

    self.editor:update(dt)

end

function Class:draw()

    local room = network:getRoom()

    love.graphics.setFont(fonts.small)
    love.graphics.print("Connected to room " .. room.id, 10, 10)
    if #room.clients < room:getSettings().playingClients then
        love.graphics.setFont(fonts.medium)
        love.graphics.printf("Waiting for other players", 0, WHEIGHT*.5 - 48, WWIDTH, "center")
    end

    love.graphics.setFont(fonts.small)
    for i = 1, room:getClientCount() do
        local client = room:getClient( i )
        local me = client.id == network:getLocalIndex()
        local name = client.name or ""
        love.graphics.print( name .. "(" .. client.id .. ")" .. (me and " <-" or ""), 10, i * 40 + 40)
    end

    self.chat:draw()

    self.editor:draw()

end

function Class:mousepressed(...)
    self.editor:mousepressed(...) --TODO:
end

--

return Class