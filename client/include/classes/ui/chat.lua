local Class = class('Chat')

function Class:initialize(hud)
    self.x = 10
    self.y = WHEIGHT-300
    self.width = 300
    self.height = 200

    self.messages = {}
    self.input = ""
    self.isWriting = false

    self.blinkTime = 0
    self.openTime = 0

    self.hud = hud
end

function Class:update(dt)

    self.blinkTime = (self.blinkTime + dt) % 1
    self.openTime = math.to(self.openTime, self.isWriting and 1 or 0, 5 * dt)

end

function Class:draw()

    --TODO: fix that huge mess!!!

    local font = fonts.small --required for font:getWidth()
    love.graphics.setFont(font)

    local color = lue:getColor("main")
    love.graphics.setColor( color )
    
    for i = 1, #self.messages do
        local message = self.messages[i]

        local string = message.text
        if message.prefix then string = message.prefix .. ": " .. string end

        love.graphics.print(string, 10, self.y + self.height - (i-1) * 40 - 6)
    end

    --input bar

    local x = self.x + font:getWidth(self.input) + 2
    local y = self.y + self.height + 46
    local scale = ease("cubicout", self.openTime)

    love.graphics.push()
    love.graphics.translate( 0, (y + 20) )
    love.graphics.scale(1, scale)
    love.graphics.translate( 0, -(y + 20) )

    love.graphics.print(self.input, 10, self.y + self.height + 40)

    love.graphics.setColor(0, 0, 0, self.openTime * 50)
    love.graphics.rectangle("fill", 5, self.y + self.height + 40, self.width * 2, 46)

    if self.blinkTime < .5 then
        local width, height = 5, 40
        love.graphics.push()
        love.graphics.translate(x + width*.5, y + height*.5)
        love.graphics.rotate(math.cos(love.timer.getTime()*12) * .08)
        love.graphics.translate(-(x + width*.5), -(y + height*.5))

        love.graphics.setColor(color[1], color[2], color[3], (.25 - math.abs(self.blinkTime - .25)) * 8 * 100)
        love.graphics.rectangle("fill", x, y - 2, width, height)

        love.graphics.pop()
    end

    love.graphics.pop()

    --/input bar



end

--

function Class:addMessage(id, text)
    local prefix
    if id == 0 then
        prefix = "SERVER"
    else
        local author = network:getRoom():getClient(id)
        if not author then
            prefix = "???" .. "(" .. id .. ")" --FIXME:
        else
            prefix = author.name .. "(" .. id .. ")"
        end
    end

    table.insert(self.messages, 1, {
        prefix = prefix,
        text = text
    })
end

--

function Class:addInput(text)
    self.input = self.input .. text
    self.blinkTime = 0
end

function Class:removeInput(length)
    local byteoffset = utf8.offset(self.input, -1)
    if byteoffset then
        -- remove the last UTF-8 character.
        -- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(text, 1, -2).
        self.input = string.sub(self.input, 1, byteoffset - 1)
    end

    self.blinkTime = 0
end

function Class:toggleInput()
    self.isWriting = not self.isWriting
    self.blinkTime = 0
    love.keyboard.setKeyRepeat(self.isWriting)
end

function Class:sendInput()
    if self.input == "" then return true end

    client:send("message", self.input)
    self.input = ""
end

return Class