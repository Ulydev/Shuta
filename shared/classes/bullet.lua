local Class = class('Bullet', DynamicObject)

function Class:initialize(args)

  args.radius = 5
  args.speed = args.speed or 800

  --

  DynamicObject.initialize(self, args)
  if self.trail then self.trail:setWidth( self.radius ) end --FIXME: ugly

  if args.angle then
    self.velocity = {
        x = math.cos(args.angle) * self.speed,
        y = math.sin(args.angle) * self.speed
    }
  end

  self.client = args.client
  
end

function Class:update(dt)
  DynamicObject.update(self, dt)
  
  --DO NOT FORGET TO PUT PARENT METHODS /!\

end

function Class:draw(alpha)
  DynamicObject.draw(self, alpha)

end

--

function Class:serialize()
  return table.merge(
    DynamicObject.serialize(self),
    {
      client = { id = self.client.id }
    }
  )
end

return Class