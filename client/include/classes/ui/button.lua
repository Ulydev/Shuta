local Class = class('Button')

function Class:initialize(args)
    
    if args.top and args.left then
        args.x = args.top + args.width * .5
        args.y = args.left + args.height * .5
        args.top, args.left = nil, nil
    end --replace top,left with x,y

    table.populate(self, args)

    self.scale = 1
    self.selected = false

end

function Class:update(dt)

    self.selected = self:isHovered( love.mouse.getPosition() )

    self.scale = math.lerp(self.scale, self.selected and 1.6 or 1, .4)

end

function Class:draw()

    love.graphics.setFont( self.font )
    love.graphics.setColor( lue:getColor("main", 200) )

    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    love.graphics.scale(self.scale)
    love.graphics.translate(-self.x, -self.y)
    love.graphics.printf(self.text, self.x - self.width*.5, self.y - 28, self.width, "center")
    love.graphics.pop()

end

--

function Class:isHovered(x, y)
    local inX = (x > self.x - self.width*.5 and x < self.x + self.width*.5)
    local inY = (y > self.y - self.height*.5 and y < self.y + self.height*.5)
    return inX and inY
end

function Class:click()
    return self.action()
end

function Class:mousepressed(x, y, button)

    if self:isHovered(x, y) then
        self:click()
    end

end

--

return Class