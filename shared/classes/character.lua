local Class = class('Character', DynamicObject)

function Class:initialize(args)
    DynamicObject.initialize(self, args)

    self.client = args.client --server only, pass just client ID to other clients (not entire table)
  
    self.class = "Character"

end

function Class:update(dt) --not executed on server
  DynamicObject.update(self, dt)


  
end

function Class:draw(alpha)
  DynamicObject.draw(self, alpha)

  love.graphics.setLineWidth(5)
  love.graphics.setColor(lue:getColor("back"))
  love.graphics.circle("fill", self.visual.x, self.visual.y, self.radius)
  love.graphics.setColor(lue:getColor("main"))
  love.graphics.circle("line", self.visual.x, self.visual.y, self.radius)
  
end

--

function Class:getClient()
    return self.client
end

--

function Class:serialize()
  return table.merge(
    DynamicObject.serialize(self),
    {
      client = { id = self:getClient():getIndex() }
    }
  )
end

return Class