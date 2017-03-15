local Class = class('Character', DynamicObject)

function Class:initialize(args)

    args.radius = 20
    args.speed = 500

    --

    DynamicObject.initialize(self, args)

    self.client = args.client --server only, pass just client ID to other clients (not entire table)
    --TODO: ClientAttached class?

end

function Class:update(dt) --not executed on server
  DynamicObject.update(self, dt)

  if self.killTime then
    self.visual.radius = self.radius * (1 + self.killTime:get())
    self.lineWidth = (1 - self.killTime:get()) * 5
  end
  
end

--client only
function Class:draw(alpha)
  DynamicObject.draw(self, alpha)
  
end

function Class:kill() --client-only for now, TODO:?
  self.killTime = soft:new(0):to(1)
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
      client = { id = self:getClient().id }
    }
  )
end

return Class