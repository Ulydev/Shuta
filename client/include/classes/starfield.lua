local Class = {}
Class.__index = Class

function Class:new(args)
  local self = args
  setmetatable(self, Class)

  self.count = self.count or 100
  self.layers = self.layers or 3
  
  self.mesh = {}
  
  for i = 1, self.layers do
    local points = {}
    for i = 1, self.count do
      points[i] = { math.random() * WWIDTH, math.random() * WHEIGHT }
    end
    self.mesh[i] = love.graphics.newMesh( points, "points", "static" )
  end
  
  self.offset = { x = 0, y = 0 }

  return self
end

function Class:setOffset(x, y)
  self.offset.x, self.offset.y = x, y
end

function Class:draw()
  
  love.graphics.setPointSize( 5 )
  for i = self.layers, 1, -1 do --draw from last (background) to first (foreground)
    local mesh = self.mesh[i]
    local offset = {
      x = self.offset.x * i * self.offsetScale,
      y = self.offset.y * i * self.offsetScale
    }
    
    love.graphics.setPointSize( i + 1 )
    for j = 1, 2 do
      for k = 1, 2 do
        local x, y = (offset.x % WWIDTH - WWIDTH * (j - 1)), (offset.y % WHEIGHT - WHEIGHT * (k - 1))
        love.graphics.draw( mesh, x, y )
      end
    end
  end
  
end

function Class:setPosition(x, y)
  self.x, self.y = x, y
end

return Class