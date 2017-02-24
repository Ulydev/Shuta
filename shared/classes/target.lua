local Class = class('Target', Object)

function Class:initialize(args)
    Object.initialize(self, args)

    self.radius = args.radius or 30

    self.time = 0

end

function Class:update(dt)
    self.time = (self.time + dt) % 1
end

function Class:draw()

    love.graphics.setColor(255, 0, 0)
    love.graphics.setLineWidth((1 - self.time) * 10)
    love.graphics.circle("line", self.x, self.y, self.radius * self.time)

end

return Class