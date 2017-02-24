local Class = class('DynamicObject', Object)

function Class:initialize(args)
  Object.initialize(self, args)

  self.radius = args.radius or 20
  
  self.velocity = {
    x = args.velocity and args.velocity.x or 0,
    y = args.velocity and args.velocity.y or 0
  }

  if client then
    self.visual = { x = self.x, y = self.y }
    self:clientInitialize(args)
  end
  
end

local image

function Class:clientInitialize()
  self.trail = trail
    :new({
      type = "mesh",
      content = {
        source = images.trail,
        width = self.radius * 1.5,
        mode = "stretch"
      },
      duration = .4
    })
    :setPosition(self.x, self.y)
end

function Class:update(dt)
  
  if client then
    if self.target then self.target:update(dt) end

    if network:getRoom():getState():isRunning() then
      if self.visual then --TODO: move to another file? (e.g. Interpolation component)
        self.visual.x = math.lerp(self.visual.x, self.x, .2)
        self.visual.y = math.lerp(self.visual.y, self.y, .2)
      end
      if self.trail then
        self.trail:setPosition(self.visual.x, self.visual.y):update(dt)
      end
    end
  end
  
end

function Class:draw(alpha)
  
  if self.target then self.target:draw() end

  if self.trail then --TODO: stop with gamestate
    love.graphics.setColor(lue:getColor("main"))
    self.trail:draw()
  end
  
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