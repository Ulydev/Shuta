local Class = class('DynamicObject', Object)

function Class:initialize(args)
  Object.initialize(self, args)

  self.radius = args.radius or 20
  self.speed = args.speed or 200
  
  self.velocity = {
    x = args.velocity and args.velocity.x or 0,
    y = args.velocity and args.velocity.y or 0
  }

  if args.target then self.target = Target:new(args.target) end

  if client then
  
    self.visual = args.visual and {
      x = args.visual.x, y = args.visual.y
    } or {
      x = self.x, y = self.y
    }
    
    self.visual.radius = self.radius

    self:clientInitialize(args)
  end
  
end

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

    
    if self.visual then --TODO: move to another file? (e.g. Interpolation component)
      self.visual.x = math.lerp(self.visual.x, self.x, .2 * dt * 60)
      self.visual.y = math.lerp(self.visual.y, self.y, .2 * dt * 60)
    end
    if self.trail then
      self.trail:setPosition(self.visual.x, self.visual.y):update(dt)
    end
  end
  
end

function Class:draw(alpha)

  if self.client and self.client.id == network:getLocalIndex() then
    love.graphics.setColor(lue:getColor("mainalt", alpha))
  else
    love.graphics.setColor(lue:getColor("main", alpha))
  end

  --
  
  if self.target then self.target:draw(alpha) end

  if self.trail then --TODO: stop with gamestate
    self.trail:draw()
  end

  local _cr, _cg, _cb, _ca = love.graphics.getColor()
  love.graphics.setLineWidth(self.lineWidth or 5)

  local _alpha = (self.lineWidth and self.lineWidth/5 or 1)
  love.graphics.setColor(lue:getColor("back", alpha))
  love.graphics.circle("fill", self.visual.x, self.visual.y, self.visual.radius)
  love.graphics.setColor(_cr, _cg, _cb, _ca * _alpha)
  love.graphics.circle("line", self.visual.x, self.visual.y, self.visual.radius)
  
end

--

function Class:serialize()
  return table.merge(
    Object.serialize(self),
    {

      visual = client and {
        x = self.visual.x,
        y = self.visual.y
      } or nil, --include visual only client-side

      velocity = {
        x = self.velocity.x,
        y = self.velocity.y
      },

      target = self.target and self.target:serialize() or nil,

    }
  )
end

return Class