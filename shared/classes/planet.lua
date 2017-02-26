local Class = class('Planet', StaticObject) --FIXME: fix StaticObject class (split into Rectangle, Circle, etc.)

function Class:initialize(args)

  StaticObject.initialize(self, args)

  self.radius = args.radius or 200

  self.class = "Planet"
  
end

function Class:update(dt)
  
  --no need for any update

end

function Class:draw(alpha)

  love.graphics.setLineWidth(5)
  love.graphics.setColor(lue:getColor("back"))
  love.graphics.circle("fill", self.x, self.y, self.radius)
  love.graphics.setColor(lue:getColor("main"))
  love.graphics.circle("line", self.x, self.y, self.radius)
  
end

--

return Class