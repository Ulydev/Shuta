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

    if #room.clients < room:getSettings().playingClients then
        love.graphics.setFont(fonts.bold.medium)
        love.graphics.printf("Waiting for other players", 0, WHEIGHT*.5 - 48 + math.cos( love.timer.getTime() * 2 ) * 10, WWIDTH, "center")
    end

    if not room:getState():hasStarted() and room:getState():getWinner() then
        local winnerName
        for i = 1, room:getClientCount() do
            if room:getClient(i).id == room:getState():getWinner().id then winnerName = room:getClient(i).name; break; end
        end
        love.graphics.setFont(fonts.bold.medium)
        love.graphics.printf( (winnerName and (winnerName .. " wins")) or "draw", 0, WHEIGHT*.5 - 48 + math.cos( love.timer.getTime() * 2 ) * 10, WWIDTH, "center")
    end
    --FIXME: please fix me later please please please



    love.graphics.setFont(fonts.bold.small)
    love.graphics.print("Players", 10, 10)

    love.graphics.setFont(fonts.light.small)
    for i = 1, room:getClientCount() do
        local client = room:getClient( i )
        local me = client.id == network:getLocalIndex()
        local name = client.name or ""

        love.graphics.setColor( lue:getColor("main", me and 255 or 100))
        love.graphics.print( name .. "(" .. client.id .. ")", 10, i * 40 + 20 )
    end

    self.chat:draw()

    self.editor:draw()

end

function Class:mousepressed(...)
    self.editor:mousepressed(...) --TODO:
end

--

return Class