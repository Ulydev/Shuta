local Class = class('Character', DynamicObject)

function Class:initialize(args)
    DynamicObject.initialize(self, args)

    self.client = args.client --server only, pass just client ID to other clients (not entire table)
  
    self.class = "Character"

end

function Class:update(dt)
  

  
end

function Class:draw(alpha)
  
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
      id = self:getClient():getIndex()
    }
  )
end

return Class