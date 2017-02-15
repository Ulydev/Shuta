local Class = class('DynamicObject', Object)

function Class:initialize(args)
  Object.initialize(self, args)

  self.radius = args.radius or 20
  
  self.velocity = {
    x = args.velocity and args.velocity.x or 0,
    y = args.velocity and args.velocity.y or 0
  }
  
end

function Class:update(dt)
  

  
end

function Class:draw(alpha)
  
  
  
end

--

function Class:serialize()
  return table.merge(
    Object.serialize(self),
    {
      velocity = {
        x = self.velocity.x,
        y = self.velocity.y
      }
    }
  )
end

return Class