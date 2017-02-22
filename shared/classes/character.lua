local Class = class('Character', DynamicObject)

function Class:initialize(args)
    DynamicObject.initialize(self, args)

    self.client = args.client --server only, pass just client ID to other clients (not entire table)
  
    self.class = "Character"

end

function Class:update(dt) --not executed on server
  
  if self.target then self.target:update(dt) end
  
end

function Class:draw(alpha)
  
  if self.target then self.target:draw() end

  love.graphics.circle("line", self.x, self.y, self.radius)
  
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