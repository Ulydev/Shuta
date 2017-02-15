local Class = class('Player', DynamicObject)

function Class:initialize(args)
  DynamicObject.initialize(self, args)
  
  self.acceleration = 14
  self.maxSpeed = 3
  self.jumpHeight = {
    2400,
    2400
  }
  self.currentJump = 0

  --TODO: put in UI manager
  local canvas = love.graphics.newCanvas(64, 64)
  love.graphics.setCanvas(canvas)
  love.graphics.setColor(255, 255, 255)
  love.graphics.circle("fill", canvas:getWidth(), canvas:getHeight() * .5, canvas:getHeight() * .5)
  love.graphics.setCanvas()
  local image = love.graphics.newImage( canvas:newImageData() )
  
  self.trail = trail
    :new({
      type = "mesh",
      content = {
        source = image,
        width = self.radius*2,
        mode = "stretch"
      },
      duration = .4
    })
    :setPosition(self.x, self.y)

end

function Class:update(dt)
  
  --[[ Movement ]]--
  
  local dir = Input:isDown("left") and -1 or Input:isDown("right") and 1 or 0
  
  if dir == 0 then
    self.velocity.x = self.velocity.x * .88
  else
    if math.sgn(self.velocity.x) ~= dir then dir = dir * 5 end
    self.velocity.x = math.clamp(-self.maxSpeed, self.velocity.x + dir * self.acceleration * dt, self.maxSpeed)
  end
  
  --[[ Super update ]]--
  
  DynamicObject.update(self, dt)
  
  --[[ Trail ]]--
  
  self.trail:setPosition( self.x, self.y ):update(dt)
  
  --[[ Reset jump ]]--
  
  if self.isGrounded then self.currentJump = 0 end
  
end

function Class:draw()
  
  love.graphics.setColor(255, 255, 255)
  self.trail:draw()
  
  DynamicObject.draw(self)
  
end

--[[ Player methods ]]--

function Class:jump()
  if self.currentJump >= #self.jumpHeight then return true end
  self.currentJump = self.currentJump + 1
  self.velocity.y = (self.currentJump == 1 and 0 or self.velocity.y*.25) - self.jumpHeight[self.currentJump]
end

function Class:shoot(projectiles)
  
  table.insert(projectiles, Projectile:new({
    x = self.x,
    y = self.y,
    mass = 30,
    radius = 20,
    velocity = { x = 2, y = -2000 },
    bounce = .8,
    friction = .1,
    
    planet = self.planet --TODO: fix
  }))
  
end

return Class